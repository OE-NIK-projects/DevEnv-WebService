try {
    & "$PSScriptRoot/create-dirs.ps1"

    $originalDir = Get-Location

    Set-Location -Path "$PSScriptRoot/../"
    docker compose up -d
    
    Set-Location -Path $originalDir

    & "$PSScriptRoot/create-admin-users.ps1"
    & "$PSScriptRoot/create-users.ps1"
    & "$PSScriptRoot/create-organization.ps1"
    & "$PSScriptRoot/create-teams.ps1"
    & "$PSScriptRoot/assign-users-to-teams.ps1"
} catch {
    Write-Error "An error occurred during setup: $_"
    exit 1
}
