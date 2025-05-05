$SourceDir = "/home/ubuntu/services/gitea/data/*.zip"
$BackupDir = "/home/ubuntu/services/gitea-backups"
$Log = "/home/ubuntu/services/gitea-backups/gitea-backup.log"

"[Info] Backup started at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $Log -Append

try {
    docker compose -f /home/ubuntu/services/docker-compose.yml exec gitea gitea dump 2>&1 | Out-File -FilePath $Log -Append
    if ($LASTEXITCODE -ne 0) {
        "[Error] Gitea dump failed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $Log -Append
        exit 1
    }

    Move-Item -Path $SourceDir -Destination $BackupDir 2>&1 | Out-File -FilePath $Log -Append
    if ($LASTEXITCODE -eq 0) {
        "[Success] Backup completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $Log -Append
    }
    else {
        throw
    }
}
catch {
    "[Error] Failed to move backup ZIP at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" | Out-File -FilePath $Log -Append
    exit 1
}
