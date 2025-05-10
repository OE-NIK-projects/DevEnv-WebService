#!/usr/bin/env pwsh

[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Password')]
param (
	[Parameter(Mandatory)]
	[string]
	$Address,

	[Parameter(Mandatory)]
	[UInt16]
	$Port,

	[Parameter(Mandatory)]
	[string]
	$User,

	[Parameter(Mandatory)]
	[string]
	$Password
)

function Exit-WithError {
	param($Message)
	Write-Host 'Error:' $Message -ForegroundColor Red
	exit 1
}

if (!(Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
	Exit-WithError 'ssh is not installed!'
}

Write-Host "Connecting to $Address`:$Port"
ssh -p $Port "$User@$Address" "/user/set $User password=`"$Password`""

if (0 -eq $LastExitCode) {
	Write-Host "Successfully set $User password"
}
else {
	Exit-WithError "failed to set $User password!"
}
