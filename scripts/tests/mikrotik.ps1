#!/usr/bin/env pwsh

class Test {
	[string] $Message
	[System.Func[bool]] $Expression

	Test([string] $Message, [System.Func[bool]] $Expression) {
		$this.Message = $Message
		$this.Expression = $Expression
	}
}

function Test-Command {
	param($Command)
	if (!(Get-Command $Command -ErrorAction SilentlyContinue)) {
		Write-Host "Command '$Command' not found!"
		exit -1
	}
}

if (!$IsLinux) {
	Write-Host 'Please run this script on a linux host!'
	exit -1
}

Test-Command 'id'
Test-Command 'wg-quick'
Test-Command 'ssh'
Test-Command 'dhcping'

if ($(id -u) -eq 0) {
	Test-Command 'sudo'
}

. "$PSScriptRoot/../router/values.ps1"

$tests = (
	[Test]::new("wg-quick up ran successfully", {
			if ($IsRoot) {
				wg-quick up $tempWgConfigPath 2>$null
			}
			else {
				$PasswordForSudo | sudo -Sp '' wg-quick up $tempWgConfigPath 2>$null
			}
			return 0 -eq $LastExitCode
		}
	),

	[Test]::new("LAN is reachable", {
			return $(Test-Connection '192.168.11.1' -ErrorAction SilentlyContinue)
		}
	),

	[Test]::new("Forwarded HTTPS port ($RouterExternalAddress`:443) is reachable", {
			return $(Test-Connection $RouterExternalAddress -TcpPort 443)
		}
	),

	[Test]::new("External SSH port ($RouterExternalAddress`:22) is unreachable", {
			return !$(Test-Connection $RouterExternalAddress -TcpPort 22)
		}
	),

	[Test]::new("Tunnel SSH port ($RouterTunnelAddress`:22) is reachable", {
			return $(Test-Connection $RouterTunnelAddress -TcpPort 22)
		}
	),

	[Test]::new("Tunnel HTTP port ($RouterTunnelAddress`:80) is reachable", {
			return $(Test-Connection $RouterTunnelAddress -TcpPort 80)
		}
	),

	[Test]::new("DNS name 'boilerplate.lan' resolved successfully", {
			return $(Test-Connection 'boilerplate.lan' -ErrorAction SilentlyContinue)
		}
	),

	[Test]::new("SSH authentication with public key is successful", {
			ssh -o PasswordAuthentication=no "admin@$RouterTunnelAddress" '/quit' 2>$null
			return 0 -eq $LastExitCode
		}
	),

	[Test]::new("wg-quick down ran successfully", {
			if ($IsRoot) {
				wg-quick down $tempWgConfigPath 2>$null
			}
			else {
				$PasswordForSudo | sudo -Sp '' wg-quick down $tempWgConfigPath 2>$null
			}
			return 0 -eq $LastExitCode
		}
	),

	[Test]::new("Router DHCP", {
			if ($IsRoot) {
				dhcping -s 192.168.11.1
			}
			else {
				$PasswordForSudo | sudo -Sp '' dhcping -s 192.168.11.1
			}
			return 0 -eq $LastExitCode
		}
	)
)

if ($(id -u) -ne 0) {
	$PasswordForSudo = Read-Host 'Password for sudo' -MaskInput
	if ([string]::IsNullOrEmpty($PasswordForSudo)) {
		Write-Host 'Empty password provided, exiting...'
		exit -1
	}
}
else {
	$IsRoot = $true
}

$tempWgConfigPath = "$PSScriptRoot/temp.peer1.conf"
Copy-Item "$PSScriptRoot/../../config/wg-peers/peer1.conf" $tempWgConfigPath

$pass = 0
$fail = 0

for ($i = 0; $i -lt $tests.Count; $i++) {
	$msg = "($($i + 1)/$($tests.Count)) Expectation: $($tests[$i].Message)"
	if ($tests[$i].Expression.Invoke()) {
		Write-Host "[PASSED] $msg" -ForegroundColor Green
		$pass++
	}
	else {
		Write-Host "[FAILED] $msg" -ForegroundColor Red
		$fail++
	}
}

Remove-Item $tempWgConfigPath

if ($pass -eq $tests.Count) {
	Write-Host "All $($tests.Count) tests passed!" -ForegroundColor Green
}
else {
	Write-Host "From $($tests.Count) tests $pass passed and $fail failed!" -ForegroundColor Red
}

exit $fail
