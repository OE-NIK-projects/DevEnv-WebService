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

if (!(Get-Command 'ssh' -ErrorAction SilentlyContinue)) {
	Exit-WithError 'ssh is not installed!'
}

$cmds = "/system/backup/save name=before-setup"
foreach ($script in Get-ChildItem "$PSScriptRoot/../../config/router/*.rsc" -File) {
	$name = $script.Name
	$cmds += "; :put `"Loading $name`"; /import $name"
}

Write-Host "Connecting to $Address`:$Port"
ssh -p $Port "$User@$Address" $cmds

if (0 -eq $LastExitCode) {
	Write-Host "Successfully run scripts"
}
else {
	Exit-WithError 'failed to run scripts!'
}
