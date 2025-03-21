#!/usr/bin/env pwsh

[CmdletBinding()]
param (
	[Parameter(Mandatory = $true, Position = 0)]
	[string]
	$Address,

	[Parameter(Mandatory = $true, Position = 1)]
	[UInt16]
	$Port,

	[Parameter(Mandatory = $true, Position = 2)]
	[string]
	$User
)

function Exit-WithError {
	param($Message)
	Write-Host 'Error:' $Message -ForegroundColor Red
	exit 1
}

if (!(Get-Command 'sftp' -ErrorAction SilentlyContinue)) {
	Exit-WithError 'sftp is not installed!'
}


$cmds = @"
put $(Resolve-Path "$PSScriptRoot/../config/router")/*.rsc
bye
"@

Write-Host "Connecting to $address`:$port"
$cmds | sftp -b- -P $Port "$User@$Address"

if (0 -eq $LastExitCode) {
	Write-Host 'Successfully upload RouterOS scripts'
}
else {
	Exit-WithError 'failed to upload RouterOS scripts!'
}
