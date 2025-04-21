try {
    & "$PSScriptRoot/create-certificates.ps1"
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
    #TODO:
    # - Upload Nginx certs from config/certs to ../nginx/certs
    # - Upload webapp from config/server/webapp to ../webapp
    # - Copy repositories from ../gitea-repos/* to ../gitea/data/git/
    # - Run tests
    # - Cleanup if all tests have passed
} catch {
    Write-Error "An error occurred during setup: $_"
    exit 1
}
