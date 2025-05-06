#!/usr/bin/env pwsh

Import-Module "$PSScriptRoot/results.psm1"

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

. "$PSScriptRoot/../router/values.ps1"

if ([string]::IsNullOrWhiteSpace($RouterExternalAddress)) {
	$RouterExternalAddress = '10.0.0.128'
}

if ([string]::IsNullOrWhiteSpace($RouterInternalAddress)) {
	$RouterInternalAddress = '192.168.11.1'
}

if ([string]::IsNullOrWhiteSpace($RouterTunnelAddress)) {
	$RouterTunnelAddress = '172.16.0.1'
}

$tests = (
	[Test]::new("'wg-quick up' ran successfully", {
			if ($IsRoot) {
				wg-quick up $tempWgConfigPath 2>$null
			}
			else {
				$PasswordForSudo | sudo -Sp '' wg-quick up $tempWgConfigPath 2>$null
			}
			return 0 -eq $LastExitCode
		}
	),

	[Test]::new("The router's WireGuard interface is reachable", {
			$res = $(Test-Connection $RouterTunnelAddress -Count 1 -ErrorAction SilentlyContinue)
			if (!$res) {
				return $false
			}
			return $res[0].Status -eq 'Success'
		}
	),

	[Test]::new("External SSH port ($RouterExternalAddress`:22) is blocked", {
			return !$(Test-Connection $RouterExternalAddress -TcpPort 22)
		}
	),

	[Test]::new("External HTTPS port ($RouterExternalAddress`:80) is blocked", {
			return !$(Test-Connection $RouterExternalAddress -TcpPort 80)
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

	[Test]::new("DNS name 'router.lan' resolved successfully", {
			$res = $(Test-Connection 'router.lan' -Count 1 -ErrorAction SilentlyContinue)
			if (!$res) {
				return $false
			}
			return $res[0].Status -eq 'Success'
		}
	),

	[Test]::new("SSH authentication with public key is successful", {
			ssh -o ConnectTimeout=3 -o PasswordAuthentication=no "admin@$RouterTunnelAddress" '/quit' 2>$null
			return 0 -eq $LastExitCode
		}
	),

	[Test]::new("'wg-quick down' ran successfully", {
			if ($IsRoot) {
				wg-quick down $tempWgConfigPath 2>$null
			}
			else {
				$PasswordForSudo | sudo -Sp '' wg-quick down $tempWgConfigPath 2>$null
			}
			return 0 -eq $LastExitCode
		}
	),

	[Test]::new("Received address from router via DHCP", {
			if ($IsRoot) {
				dhcping -qs 192.168.11.1
			}
			else {
				$PasswordForSudo | sudo -Sp '' dhcping -qs 192.168.11.1
			}
			return 0 -eq $LastExitCode
		}
	)
)

if ($(id -u) -ne 0) {
	Test-Command 'sudo'

	$PasswordForSudo = Read-Host 'Password for sudo' -MaskInput
	if ([string]::IsNullOrEmpty($PasswordForSudo)) {
		Write-Host 'Empty password provided, exiting...'
		exit -1
	}
}
else {
	$IsRoot = $true
}

$resultsDir = "$PSScriptRoot/_mtr"
$writeResults = Test-Path "$resultsDir/.git"

$tempWgConfigPath = "$PSScriptRoot/temp.peer1.conf"
Copy-Item "$PSScriptRoot/../../config/wg-peers/peer1.conf" $tempWgConfigPath

$passes = 0
$fails = 0

for ($i = 0; $i -lt $tests.Count; $i++) {
	$text = "($($i + 1)/$($tests.Count)) Expectation: $($tests[$i].Message)"
	$file = "$resultsDir/$(($i + 1).ToString("D2")).json"

	if ($tests[$i].Expression.Invoke()) {
		Write-Host "[PASSED] $text" -ForegroundColor Green
		$passes++
		if ($writeResults) {
			Write-Result $file $tests[$i].Message $true
		}
	}
	else {
		Write-Host "[FAILED] $text" -ForegroundColor Red
		$fails++
		if ($writeResults) {
			Write-Result $file $tests[$i].Message $false
		}
	}
}

Remove-Item $tempWgConfigPath

if ($passes -eq $tests.Count) {
	Write-Host "All $($tests.Count) tests passed!" -ForegroundColor Green
}
else {
	Write-Host "From $($tests.Count) tests $passes passed and $fails failed!" -ForegroundColor Red
}

if ($writeResults) {
	Write-Summary "$resultsDir/summary.json" $passes $tests.Count
	Write-Timestamp "$resultsDir/timestamp.json"
}

exit $fails
