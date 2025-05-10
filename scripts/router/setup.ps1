#!/usr/bin/env pwsh

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Password')]
param (
	[ValidateSet('Help', 'CopyKey', 'CopyConf', 'SetConf', 'SetPass', 'Full', 'SSH', 'TestConn')]
	[string]
	$Task = 'Help',

	[string]
	$Address = $null,

	[UInt16]
	$Port = 22,

	[string]
	$User = 'admin',

	[string]
	$Password = $null
)

function Write-Task {
	param ([string] $Name, [string] $Message)
	Write-Host "  $($Name.PadRight(9))" -NoNewline -ForegroundColor Yellow
	Write-Host " - $Message."
}

function Write-Para {
	param ([string] $Name, [string] $Message)
	Write-Host "  -$($Name.PadRight(8))" -NoNewline -ForegroundColor Yellow
	Write-Host " - $Message."
}

function Write-Help {
	Write-Host "Usage: $CurrentScript <Task> [Parameters]"
	Write-Host
	Write-Host "Example: $CurrentScript SetPass -User admin -Password examplePass"
	Write-Host
	Write-Host 'Tasks:'
	Write-Task 'Help' 'Show this message'
	Write-Task 'CopyKey' 'Copy the first suitable public key of the current user onto the router'
	Write-Task 'CopyConf' 'Copy the configuration scripts onto the router'
	Write-Task 'SetConf' 'Apply the configuration scripts onto the router'
	Write-Task 'SetPass' "Set the password of the specified user on the router"
	Write-Task 'Full' 'Run CopyKey, SetPass, CopyConf and SetConf'
	Write-Task 'SSH' 'Connect to the router via SSH'
	Write-Task 'TestConn' "Check if the specified TCP port is reachable on the router"
	Write-Host
	Write-Host 'Parameters:'
	Write-Para 'Address' 'Address of the router'
	Write-Para 'Port' 'SSH port of the router, the default is 22'
	Write-Para 'User' 'SSH user of the router, the default is admin'
	Write-Para 'Password' 'Password of the user'
	Write-Host
}

function Copy-PubKey {
	Write-Host 'Running copy-pubkey.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/cmd/copy-pubkey.ps1" $Address $Port $User
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Copy-Conf {
	Write-Host 'Running copy-scripts.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/cmd/copy-scripts.ps1" $Address $Port $User
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Set-Conf {
	Write-Host 'Running set-config.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/cmd/set-config.ps1" $Address $Port $User
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Set-Pass {
	Write-Host 'Running set-password.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/cmd/set-password.ps1" $Address $Port $User $Password
	if (0 -ne $LastExitCode) {
		exit 1
	}
}

function Invoke-SSH {
	Write-Host 'Running invoke-ssh.ps1' -ForegroundColor Yellow
	& "$PSScriptRoot/cmd/invoke-ssh.ps1" $Address $Port $User
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

$CurrentScript = $MyInvocation.MyCommand.Name

. "$PSScriptRoot/values.ps1"

if ([string]::IsNullOrWhiteSpace($RouterExternalAddress)) {
	$RouterExternalAddress = '10.0.0.128'
}

if ([string]::IsNullOrWhiteSpace($RouterInternalAddress)) {
	$RouterInternalAddress = '192.168.11.1'
}

if ([string]::IsNullOrWhiteSpace($RouterTunnelAddress)) {
	$RouterTunnelAddress = '172.16.0.1'
}

if ([string]::IsNullOrWhiteSpace($Address)) {
	if ((Test-Connection $RouterTunnelAddress -Count 1 -Ping -TimeoutSeconds 1).Status -eq 'Success') {
		$Address = $RouterTunnelAddress
	}
	elseif ((Test-Connection $RouterInternalAddress -Count 1 -Ping -TimeoutSeconds 1).Status -eq 'Success') {
		$Address = $RouterInternalAddress
	}
	elseif ((Test-Connection $RouterExternalAddress -Count 1 -Ping -TimeoutSeconds 1).Status -eq 'Success') {
		$Address = $RouterExternalAddress
	}
	else {
		Write-Host 'Failed to connect to the router! Try specifying its address.' -ForegroundColor Red
		exit 1
	}
}

if ([string]::IsNullOrWhiteSpace($Password)) {
	if ([string]::IsNullOrWhiteSpace($RouterPassword)) {
		Write-Host 'Please specify -Password or set $RouterPassword in the values.ps1 file!'
		exit 1
	}
	$Password = $RouterPassword
}

switch ($Task) {
	'Help' {
		Write-Help
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
	'SetPass' {
		Set-Pass
	}
	'Full' {
		Copy-PubKey
		Set-Pass
		Copy-Conf
		Set-Conf
	}
	'SSH' {
		Invoke-SSH
	}
	'TestConn' {
		Test-Conn
	}
}
