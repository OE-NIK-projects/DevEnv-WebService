#!/usr/bin/env pwsh

[CmdletBinding()]
param (
	[Parameter(Position = 0)]
	[ValidateSet('All', 'CopyKey', 'CopyConf', 'SetConf', 'TestConn')]
	[string]
	$Task = 'All',

	[Parameter(Position = 1)]
	[string]
	$User = 'admin',

	[Parameter(Position = 2)]
	[string]
	$Address = $null,

	[Parameter(Position = 3)]
	[UInt16]
	$Port = $null
)

function Copy-PubKey {
	Write-Host 'Running copy-pubkey.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/copy-pubkey.ps1" $User $Address $Port
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Copy-Conf {
	Write-Host 'Running copy-scripts.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/copy-scripts.ps1" $User $Address $Port
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Set-Conf {
	Write-Host 'Running set-config.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/set-config.ps1" $User $Address $Port
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Test-Conn {
	Write-Host "Testing $Address`:$Port" -ForegroundColor Yellow
	if (Test-Connection $Address -TcpPort $Port) {
		Write-Host "$Address`:$Port is reachable"
	}
	else {
		Write-Host "Error: $Address`:$Port is unreachable" -ForegroundColor Red
		exit 1
	}
}

if (!$Address) {
	if ((Test-Connection '172.16.0.1' -Count 1 -Ping -TimeoutSeconds 1).Status -eq 'Success') {
		$Address = '172.16.0.1'
	}
	else {
		$Address = '10.0.0.128'
	}
}

if (!$Port) {
	if (Test-Connection $Address -TcpPort 2222 -TimeoutSeconds 1) {
		$Port = 2222
	}
	else {
		$Port = 22
	}
}

switch ($Task) {
	'All' {
		Copy-PubKey
		Copy-Conf
		Set-Conf
	}
	'CopyKey' {
		Copy-PubKey
	}
	'CopyConf' {
		Copy-Conf
	}
	'SetConf' {
		Set-Conf
	}
	'TestConn' {
		Test-Conn
	}
}
