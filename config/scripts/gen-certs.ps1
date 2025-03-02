#!/usr/bin/env pwsh

if (!(Get-Command 'openssl' -ErrorAction SilentlyContinue)) {
	Write-Host 'Error: openssl is not installed!' -ForegroundColor Red
	exit 1
}

$originalPath = Get-Location
$certsDir = "$PSScriptRoot/../certs"
$tempFile = 'ext.tmp'

$caKey = 'rca.key'
$caCer = 'rca.crt'
$domainKey = 'domain.key'
$domainCer = 'domain.crt'

$domain = 'boilerplate.hu'
$altName = "DNS:$domain,DNS:*.$domain"
$subject = "/C=HU/ST=Pest/L=Budapest/O=Boilerplate Kft./CN=$domain"

$keySize = 2048
$days = 365

try {
	New-Item $certsDir -Force -ItemType Directory | Out-Null
	Set-Location $certsDir

	if (!(Test-Path $caKey) -or !(Test-Path $caCer)) {
		& "$PSScriptRoot/gen-rca.ps1"
	}

	Write-Host 'Writing temp file'
	Set-Content $tempFile "[ext]`n subjectAltName = $altName"

	Write-Host "Generating $domainKey"
	openssl genrsa -out $domainKey $keySize

	Write-Host "Creating $domainCer"
	openssl req `
		-addext "subjectAltName=$altName" `
		-key $domainKey `
		-new `
		-out $domainCer `
		-subj $subject

	Write-Host "Signing $domainCer"
	openssl x509 `
		-CA $caCer `
		-CAkey $caKey `
		-days $days `
		-extfile $tempFile `
		-extensions ext `
		-in $domainCer `
		-out $domainCer `
		-req

	Write-Host 'Done!'
}
finally {
	Remove-Item $tempFile -Force
	Set-Location $originalPath
}
