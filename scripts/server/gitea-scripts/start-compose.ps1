. $PSScriptRoot/write-message.ps1

Write-Message -Message "Starting $($PSScriptRoot)/../docker-compose.yml" -Type Info
$originalDir = Get-Location
Set-Location -Path "$PSScriptRoot/../"
docker compose up -d
Set-Location -Path $originalDir
