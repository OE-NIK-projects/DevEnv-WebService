#!/usr/bin/env pwsh

if (!(Get-Command "sftp" -ErrorAction SilentlyContinue)) {
	Write-Host "Error: sftp is not installed!" -ForegroundColor Red
	exit 1
}

$originalPath = Get-Location
Set-Location $PSScriptRoot

@"
put router/*.rsc
bye
"@ | sftp 'admin@192.168.1.254'

Set-Location $originalPath
