try {
    & "$PSScriptRoot/create-dirs.ps1"

    $originalDir = Get-Location

    Set-Location -Path "~/docker"
    docker compose up -d
    
    Set-Location -Path $originalDir

    & "$PSScriptRoot/create-users.ps1"
    & "$PSScriptRoot/create-organization.ps1"
    & "$PSScriptRoot/create-teams.ps1"
} catch {
    Write-Error "An error occurred during setup: $_"
    exit 1
}
