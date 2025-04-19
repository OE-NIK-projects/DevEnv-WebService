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

$pubKey = Get-Content "$($env:HOME ?? $env:USERPROFILE)/.ssh/id_*.pub" -ErrorAction SilentlyContinue | Select-Object -First 1
if (!$pubKey) {
	Exit-WithError 'no suitable public key found!'
}
Write-Host "Public key: `"$pubKey`""

Write-Host "Connecting to $Address`:$Port"
ssh -p $Port "$User@$Address" "/user/ssh-keys/add user=$User key=`"$pubKey`""

if (0 -eq $LastExitCode) {
	Write-Host "Successfully added public key"
}
else {
	Exit-WithError 'failed to add public key!'
}
