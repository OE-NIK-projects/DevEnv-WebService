#!/usr/bin/env pwsh

. "$PSScriptRoot/../write-message.ps1"

$serviceName = 'webapp-backup.service'
$timerName = 'webapp-backup.timer'

$serviceFile = "/etc/systemd/system/$serviceName"
$timerFile = "/etc/systemd/system/$timerName"

$backupDir = '/home/ubuntu/services/webapp-backups'
$containerName = 'webapp'
$dbFile = '/app/public/db/services.json'

$commands = "mkdir -p $backupDir && docker cp `"$containerName`:$dbFile`" `"$backupDir/`$(date -Iminutes).json`""

$service = @"
[Unit]
Description=WebApp Backup Service
After=docker.service

[Service]
Type=oneshot
User=ubuntu
ExecStart=/usr/bin/bash -c '$commands'

[Install]
WantedBy=multi-user.target
"@

$timer = @"
[Unit]
Description=Run WebApp Backup Service daily

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
"@

try {
	Write-Message "Creating $serviceFile" Info
	$service | sudo tee $serviceFile >$null

	Write-Message "Creating $timerFile" Info
	$timer | sudo tee $timerFile >$null

	Write-Message "sudo systemctl daemon-reload" Command
	sudo systemctl daemon-reload

	Write-Message "sudo systemctl enable --now $timerName" Command
	sudo systemctl enable --now $timerName

	Write-Message "WebApp Backup Service setup completed" -Type Success
}
catch {
	Write-Message "Failed to setup WebApp Backup Service: $_" -Type Error
	exit 1
}
