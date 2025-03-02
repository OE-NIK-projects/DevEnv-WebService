#!/usr/bin/env pwsh

if (!(Get-Command 'sftp' -ErrorAction SilentlyContinue)) {
	Write-Host 'Error: sftp is not installed!' -ForegroundColor Red
	exit 1
}

$originalPath = Get-Location
Set-Location $PSScriptRoot

$address = '10.0.0.128'
if (Test-Connection $address -TcpPort 2222 -TimeoutSeconds 1) {
	$port = 2222
}
else {
	$port = 22
}

Write-Host "Connecting to $address on port $port"

@'
put ../router/*.rsc
bye
'@ | sftp -P $port "admin@$address"

Set-Location $originalPath
