#!/usr/bin/env pwsh

class Test {
	[string] $Message
	[System.Func[bool]] $Expression

	Test([string] $Message, [System.Func[bool]] $Expression) {
		$this.Message = $Message
		$this.Expression = $Expression
	}
}

if (!$IsWindows -and !(Get-Command 'sudo' -ErrorAction SilentlyContinue)) {
	Exit-WithError 'sudo is not installed!'
}

if (!(Get-Command 'wg-quick' -ErrorAction SilentlyContinue)) {
	Exit-WithError 'wg-quick is not installed!'
}

. "$PSScriptRoot/../router/values.ps1"

$tests = (
	[Test]::new("wg-quick up ran successfully", {
			if ($IsWindows) {
				wg-quick up $tempWgConfigPath
			}
			else {
				sudo -S wg-quick up $tempWgConfigPath
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

	[Test]::new("External SSH port ($RouterExternalAddress`:$RouterSSHPort) is unreachable", {
			return !$(Test-Connection $RouterExternalAddress -TcpPort $RouterSSHPort)
		}
	),

	[Test]::new("Tunnel SSH port ($RouterTunnelAddress`:$RouterSSHPort) is reachable", {
			return $(Test-Connection $RouterTunnelAddress -TcpPort $RouterSSHPort)
		}
	),

	[Test]::new("Tunnel HTTP port ($RouterTunnelAddress`:80) is reachable", {
			return $(Test-Connection $RouterTunnelAddress -TcpPort 80)
		}
	),

	[Test]::new("DNS name 'router.lan' is resolved", {
			return $(Test-Connection 'router.lan' -ErrorAction SilentlyContinue)
		}
	),

	[Test]::new("wg-quick down ran successfully", {
			if ($IsWindows) {
				wg-quick down $tempWgConfigPath
			}
			else {
				sudo -S wg-quick down $tempWgConfigPath
			}
			return 0 -eq $LastExitCode
		}
	)
)

$tempWgConfigPath = "$PSScriptRoot/temp-wg-peer1.conf"
Copy-Item "$PSScriptRoot/../../config/wg-peers/peer1.conf" $tempWgConfigPath

$pass = 0
$fail = 0

for ($i = 0; $i -lt $tests.Count; $i++) {
	$msg = "($($i + 1)/$($tests.Count)) $($tests[$i].Message)"
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
	Write-Host "From $($tests.Count) tests $pass passed and $fail failed!" -ForegroundColor Yellow
}
