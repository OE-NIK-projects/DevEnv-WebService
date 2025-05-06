# Import Write-Message function
. $PSScriptRoot/../write-message.ps1

# Define paths
$BackupScript = "$($PSScriptRoot)/gitea-backup.ps1"
$BackupDir = "/home/ubuntu/services/gitea-backups"
$ServiceFile = "/etc/systemd/system/gitea-backup.service"
$TimerFile = "/etc/systemd/system/gitea-backup.timer"

try {
    # Validate backup script exists
    if (-not (Test-Path $BackupScript)) {
        Write-Message "Backup script not found at $BackupScript" -Type Error
        throw "Backup script does not exist"
    }

    # Make backup script executable
    Write-Message "chmod +x $BackupScript" -Type Command
    chmod +x $BackupScript
    Write-Message "$BackupScript is now executable" -Type Success

    # Create systemd service file
    Write-Message "Creating $ServiceFile" -Type Command
    $ServiceContent = @"
[Unit]
Description=Gitea Backup Service
After=network.target docker.service

[Service]
Type=oneshot
User=ubuntu
ExecStart=/snap/bin/pwsh $BackupScript
WorkingDirectory=$($BackupDir)
Restart=no

[Install]
WantedBy=multi-user.target
"@
    $ServiceContent | sudo tee $ServiceFile > /dev/null

    # Create systemd timer file
    Write-Message "Creating $TimerFile" -Type Command
    $TimerContent = @"
[Unit]
Description=Run Gitea Backup Daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
"@
    $TimerContent | sudo tee $TimerFile > /dev/null

    # Reload systemd and enable/start timer
    Write-Message "sudo systemctl daemon-reload" -Type Command
    sudo systemctl daemon-reload
    Write-Message "sudo systemctl enable gitea-backup.timer" -Type Command
    sudo systemctl enable gitea-backup.timer
    Write-Message "sudo systemctl start gitea-backup.timer" -Type Command
    sudo systemctl start gitea-backup.timer

    Write-Message "Systemd setup completed" -Type Success
}
catch {
    Write-Message "Systemd setup failed: $_" -Type Error
    exit 1
}
