. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Generate-EnvFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$EnvVars,

        [Parameter(Mandatory = $true)]
        [string]$OutputDir,

        [Parameter(Mandatory = $false)]
        [string]$FileName = ".env"
    )

    try {
        if (-not (Test-Path -Path $OutputDir)) {
            New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
            Write-Message -Message "Created directory: $OutputDir" -Type Success
        }
        else {
            Write-Message -Message "Directory already exists: $OutputDir" -Type Info
        }

        $envFilePath = Join-Path -Path $OutputDir -ChildPath $FileName

        $envContent = @()
        foreach ($key in $EnvVars.Keys) {
            $value = $EnvVars[$key]
            $envContent += "$key=$value"
        }

        $envContent | Out-File -FilePath $envFilePath -Encoding utf8 -Force
        Write-Message -Message "Generated .env file at: $envFilePath" -Type Success

        if ($Debug.EnableDotEnvFileLogging) {
            Write-Message -Message "Generated .env content:`n$($envContent -join "`n")" -Type Info
        }
    }
    catch {
        Write-Message -Message "Failed to generate .env file at: $envFilePath. Error: $($_.Exception.Message)" -Type Error
        throw
    }
}

Write-Message -Message "Starting .env file generation process..." -Type Info

$targetDir = Join-Path -Path $PSScriptRoot -ChildPath ".."
Write-Message -Message "Using target directory: $targetDir" -Type Info

Generate-EnvFile -EnvVars $EnvVars -OutputDir $targetDir
Write-Message -Message ".env file generation process completed.`n" -Type Info
