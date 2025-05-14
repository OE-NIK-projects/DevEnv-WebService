#!/usr/bin/env pwsh

Import-Module -Force "$PSScriptRoot/imports.psm1"
Write-Message 'Setting up Gitea repositories and issues.' Info

$location = Get-Location

# Git values

$domain = $Domains.Gitea

$backendDir = "$PSScriptRoot/backend"
$frontendDir = "$PSScriptRoot/frontend"

$backendName = "$($Repositories[1].OrganizationUsername)/$($Repositories[1].Name)"
$frontendName = "$($Repositories[0].OrganizationUsername)/$($Repositories[0].Name)"

$backendRepo = "$domain/$backendName.git"
$frontendRepo = "$domain/$frontendName.git"

$email = $Users[5].Email
$username = $Users[5].Username
$password = $Users[5].Password

# API values

$apiBaseUrl = "https://$domain/api/v1"

$adminUsername = $Admins[0].Username
$adminPassword = $Admins[0].Password

$authHeader = "Basic $([System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$adminUsername`:$adminPassword")))"

$headers = [System.Collections.Generic.Dictionary[string, string]]::new()
$headers.Add('Authorization', $authHeader)
$headers.Add('Content-Type', 'application/json')

# Functions

function Invoke-GiteaApi {
	param (
		[ValidateSet('Post', 'Get', 'Patch', 'Delete')]
		[string]
		$Method,

		[string]
		$Path,

		[object]
		$Content
	)

	$url = "$apiBaseUrl$Path"
	$body = $Content | ConvertTo-Json

	Invoke-RestMethod -Uri $url -Method $Method -Headers $headers -Body $body -SkipCertificateCheck
}

function Remove-BackendIssues {
	(Invoke-GiteaApi Get "/repos/$backendName/issues") | ForEach-Object {
		Invoke-GiteaApi Delete "/repos/$backendName/issues/$($_.number)" >$null
	}
}

function Remove-FrontendIssues {
	(Invoke-GiteaApi Get "/repos/$frontendName/issues") | ForEach-Object {
		Invoke-GiteaApi Delete "/repos/$frontendName/issues/$($_.number)" >$null
	}
}

function New-BackendIssue {
	param ([string] $Title, [string] $Message)
	Invoke-GiteaApi Post "/repos/$backendName/issues" @{
		body  = $Message
		title = $Title
	} >$null
}

function New-FrontendIssue {
	param ([string] $Title, [string] $Message)
	Invoke-GiteaApi Post "/repos/$frontendName/issues" @{
		body  = $Message
		title = $Title
	} >$null
}

function New-BackendRepo {
	Set-Location $backendDir
	git init >$null
	git remote add origin "https://$backendRepo"
	git config user.name $username
	git config user.email $email
	git config http.sslVerify false

	Set-Content '.gitattributes' "* text=auto eol=lf`n"
	git add '.gitattributes'
	git commit -m 'Initial commit' >$null

	Set-Content 'go.mod' "module boilerplate/backend`n`ngo 1.24`n"
	git add 'go.mod'
	git commit -m 'Created project' >$null

	git checkout -b development *>$null
	Set-Content 'main.go' @"
package main

import "net/http"

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("Ok")) })
	http.ListenAndServe("0.0.0.0:80", nil)
}
"@
	git add .
	git commit -m 'Added main.go' >$null

	git checkout -b testing *>$null

	git push --all -f "https://$username`:$password@$backendRepo" *>$null
}

function New-FrontendRepo {
	Set-Location $frontendDir
	git init >$null
	git remote add origin "https://$frontendRepo"
	git config user.name $username
	git config user.email $email
	git config http.sslVerify false

	Set-Content '.gitattributes' "* text=auto eol=lf`n"
	git add '.gitattributes'
	git commit -m 'Initial commit' >$null

	Set-Content 'index.html' @"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Useless Page</title>
  </head>
  <body>
	This page is useless!
  </body>
</html>
"@
	git add .
	git commit -m 'Created project' >$null

	git checkout -b development *>$null

	git push --all -f "https://$username`:$password@$frontendRepo" *>$null
}

# Create repo directories

if (Test-Path $backendDir) {
	Remove-Item -Force -ProgressAction SilentlyContinue -Recurse $backendDir
}
if (Test-Path $frontendDir) {
	Remove-Item -Force -ProgressAction SilentlyContinue -Recurse $frontendDir
}

New-Item -Force -ItemType Directory $backendDir >$null
New-Item -Force -ItemType Directory $frontendDir >$null

# Set default branch name to main

git config --global init.defaultBranch main

# Setup backend repository

try {
	New-BackendRepo
	Write-Message 'Set up new backend repo' Success
}
catch {
	Write-Message 'Failed to set up new backend repo!' Error
}

# Setup frontend repository

try {
	New-FrontendRepo
	Write-Message 'Set up new frontend repo' Success
}
catch {
	Write-Message 'Failed to set up new frontend repo!' Error
}

# Remove backend issues

try {
	Remove-BackendIssues
	Write-Message 'Removed existing backend repo issues.' Success
}
catch {
	Write-Message 'Failed to remove existing backend repo issues!' Error
}

# Remove frontend issues

try {
	Remove-FrontendIssues
	Write-Message 'Removed existing frontend repo issues.' Success
}
catch {
	Write-Message 'Failed to remove existing frontend repo issues!' Error
}

# Create backend issues

try {
	New-BackendIssue 'Bump go version' 'Bump go language version from 1.24 to latest.'
	New-BackendIssue 'Add README' 'Create a README markdown document for the repository.'
	New-BackendIssue 'Implement http server' 'Implement serving the frontend using "net/http".'
	New-BackendIssue 'Make .gitattributes more specific' 'Replace the * filter with file extensions.'
	New-BackendIssue 'Use ListenAndServeTLS' 'Use ListenAndServeTLS instead of ListenAndServe.'
	Write-Message 'Created backend repo issues.' Success
}
catch {
	Write-Message 'Failed to create frontend repo issues!' Error
}

# Create frontend issues

try {
	New-FrontendIssue 'Add README' 'Create a README markdown document for the repository.'
	New-FrontendIssue 'Update page title and content' 'Set the title and contents of the page to something more appropriate.'
	New-FrontendIssue 'Make .gitattributes more specific' 'Replace the * filter with file extensions.'
	Write-Message 'Created frontend repo issues.' Success
}
catch {
	Write-Message 'Failed to create frontend repo issues!' Error
}

# Reset location

Set-Location $location
