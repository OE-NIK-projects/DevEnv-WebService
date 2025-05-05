. $PSScriptRoot/write-message.ps1

$giteaBaseDir = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "gitea"
$giteaBackupDir = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "gitea-backups"
$configDir = Join-Path -Path $giteaBaseDir -ChildPath "config"
$dataDir = Join-Path -Path $giteaBaseDir -ChildPath "data"
$backupFile = Join-Path -Path $giteaBackupDir -ChildPath "gitea-backup.log"

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

    Write-Message "Gitea directory structure created successfully.`n" -Type Success

    # Create backup directory
    if (-not (Test-Path -Path $giteaBackupDir)) {
        New-Item -Path $giteaBackupDir -ItemType Directory -Force | Out-Null
        Write-Message "Created directory: $giteaBackupDir" -Type Success
    }
    else {
        Write-Message "Directory already exists: $giteaBackupDir" -Type Error
    }

    # Create backup log file
    if (-not (Test-Path -Path $backupFile)) {
        New-Item -ItemType File $backupFile | Out-Null
        Write-Message "Created backup log file: $backupFile" -Type Success
    }
    else {
        Write-Message "File already exists: $backupFile" -Type Error
    }
}
catch {
    Write-Message "Failed to create directories: $_" -Type Error
}
