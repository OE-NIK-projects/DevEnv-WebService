. $PSScriptRoot/write-message.ps1

$giteaBaseDir = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "gitea"
$configDir = Join-Path -Path $giteaBaseDir -ChildPath "config"
$dataDir = Join-Path -Path $giteaBaseDir -ChildPath "data"

# Create directories if they don't exist
Write-Message "Creating Gitea directory structure..." -Type Info

try {
    # Create gitea base directory
    if (-not (Test-Path -Path $giteaBaseDir)) {
        New-Item -Path $giteaBaseDir -ItemType Directory -Force | Out-Null
        Write-Message "Created directory: $giteaBaseDir" -Type Success
    }
    else {
        Write-Message "Directory already exists: $giteaBaseDir" -Type Error
    }

    # Create config directory
    if (-not (Test-Path -Path $configDir)) {
        New-Item -Path $configDir -ItemType Directory -Force | Out-Null
        Write-Message "Created directory: $configDir" -Type Success
    }
    else {
        Write-Message "Directory already exists: $configDir" -Type Error
    }

    # Create data directory
    if (-not (Test-Path -Path $dataDir)) {
        New-Item -Path $dataDir -ItemType Directory -Force | Out-Null
        Write-Message "Created directory: $dataDir" -Type Success
    }
    else {
        Write-Message "Directory already exists: $dataDir" -Type Error
    }

    Write-Message "Gitea directory structure created successfully." -Type Success
}
catch {
    Write-Message "Failed to create directories: $_" -Type Error
}
