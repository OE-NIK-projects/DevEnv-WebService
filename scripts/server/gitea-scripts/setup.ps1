#!/usr/bin/env pwsh

try {
    & "$PSScriptRoot/install-certificates.ps1"
    & "$PSScriptRoot/create-nginx-conf.ps1"
    & "$PSScriptRoot/create-dotenv.ps1"
    & "$PSScriptRoot/create-dirs.ps1"
    & "$PSScriptRoot/start-compose.ps1"
    & "$PSScriptRoot/create-admin-users.ps1"
    & "$PSScriptRoot/create-users.ps1"
    & "$PSScriptRoot/create-organization.ps1"
    & "$PSScriptRoot/create-teams.ps1"
    & "$PSScriptRoot/assign-users-to-teams.ps1"
    & "$PSScriptRoot/create-repos.ps1"
    & "$PSScriptRoot/backup/enable-auto-backup.ps1"
    #TODO:
    #Copy repositories from config/server/repos to server
} catch {
    Write-Error "An error occurred during setup: $_"
    exit 1
}
