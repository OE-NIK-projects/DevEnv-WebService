#!/usr/bin/env pwsh

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Password')]
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

if (!(Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
	Write-Host 'Error: ssh is not installed!' $Message -ForegroundColor Red
	exit 1
}

Write-Host "Connecting to $Address`:$Port"
ssh -p $Port "$User@$Address"
