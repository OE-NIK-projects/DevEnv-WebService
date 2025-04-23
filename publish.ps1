#!/usr/bin/env pwsh

$location = Get-Location
Set-Location $PSScriptRoot

$hash = git log --grep='init' --format='%H'
git checkout _mtr
git reset $hash
git add .
git commit -m 'results'
git push -f
git reset --hard $hash

Set-Location $location
