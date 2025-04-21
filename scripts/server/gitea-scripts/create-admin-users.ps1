. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Add-GiteaAdminUser {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Password')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [string]$Email,

        [Parameter(Mandatory = $true)]
        [string]$Password,

        [Parameter()]
        [string]$DockerComposeService = "gitea"
    )

    try {
        $command = "gitea admin user create --admin --username '$Username' --email '$Email' --password '$Password'"

        Write-Message -Message "Executing: docker compose exec $DockerComposeService $command" -Type Command
        $result = Invoke-Expression "docker compose exec $DockerComposeService $command 2>&1" | Out-String | ForEach-Object { $_.TrimEnd() }

        if ($LASTEXITCODE -eq 0) {
            Write-Message -Message "Created user: $Username ($Email)" -Type Success
        }
        else {
            Write-Message -Message "$result" -Type Error
        }
    }
    catch {
        Write-Message -Message "Failed to create user: $Username. Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting Gitea admin user creation process in $($TimeoutInSeconds)s..." -Type Info
Start-Sleep -Seconds $TimeoutInSeconds

$Admins | ForEach-Object {
    Add-GiteaAdminUser -Username $_.Username `
        -Email $_.Email `
        -Password $_.Password `
}
Write-Message -Message "Gitea admin user creation process completed.`n" -Type Info
