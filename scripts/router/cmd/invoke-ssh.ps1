#!/usr/bin/env pwsh

[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string]
	$Address,

	[Parameter(Mandatory)]
	[UInt16]
	$Port,

	[Parameter(Mandatory)]
	[string]
	$User
)

if (!(Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
	Write-Host 'Error: ssh is not installed!' $Message -ForegroundColor Red
	exit 1
}

Write-Host "Connecting to $Address`:$Port"
ssh -p $Port "$User@$Address"
