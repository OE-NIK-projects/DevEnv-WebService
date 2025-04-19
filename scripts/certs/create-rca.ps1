#!/usr/bin/env pwsh

if (!(Get-Command 'openssl' -ErrorAction SilentlyContinue)) {
	Write-Host 'Error: openssl is not installed!' -ForegroundColor Red
	exit 1
}

$originalPath = Get-Location
$certsDir = "$PSScriptRoot/../../config/certs"

$caKey = 'rca.key'
$caCer = 'rca.crt'

$domain = 'boilerplate.lan'
$subject = "/C=HU/ST=Pest/L=Budapest/O=Boilerplate Certificate Authority/CN=$domain"

$keySize = 2048
$days = 365

try {
	New-Item $certsDir -Force -ItemType Directory | Out-Null
	Set-Location $certsDir

	Write-Host "Generating $caKey"
	openssl genrsa -out $caKey $keySize

	Write-Host "Creating $caCer"
	openssl req `
		-days $days `
		-key $caKey `
		-new `
		-out $caCer `
		-subj $subject `
		-x509

	Write-Host 'Done!'
}
finally {
	Set-Location $originalPath
}
