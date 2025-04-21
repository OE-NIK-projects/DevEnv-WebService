. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Install-Certificates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$CertPath
    )

    try {
        Write-Message -Message "Processing input: $CertPath..." -Type Info
        
        $caCertsDir = "/usr/local/share/ca-certificates"

        if (-not (Test-Path -Path $caCertsDir)) {
            Write-Message -Message "Creating CA certificates directory: $caCertsDir" -Type Info
            sudo mkdir -p $caCertsDir
        }

        if (Test-Path -Path $CertPath -PathType Container) {
            $certFiles = Get-ChildItem -Path $CertPath -Filter "*.crt" -File | ForEach-Object { $_.FullName }
            if ($certFiles.Count -eq 0) {
                Write-Message -Message "No .crt files found in directory: $CertPath" -Type Error
                exit 1
            }
        }
        else {
            Write-Message -Message "Path does not exist: $CertPath" -Type Error
            exit 1
        }

        Write-Message -Message "Found $($certFiles.Count) certificate file(s) to install." -Type Success

        foreach ($certFile in $certFiles) {
            Write-Message -Message "Processing certificate: $certFile..." -Type Info

            $certFileName = [System.IO.Path]::GetFileName($certFile)
            $targetCertPath = Join-Path -Path $caCertsDir -ChildPath $certFileName

            Write-Message -Message "Copying $certFile to $targetCertPath..." -Type Info
            sudo cp $certFile $targetCertPath

            if (-not (Test-Path -Path $targetCertPath)) {
                Write-Message -Message "Failed to copy certificate to $targetCertPath" -Type Error
                exit 1
            }
        }

        Write-Message -Message "Updating CA certificates store..." -Type Info
        sudo update-ca-certificates
    }
    catch {
        Write-Message -Message "Failed to install certificates: $($_.Exception.Message)" -Type Error
        throw
    }
}

Write-Message -Message "Starting certificate installation process..." -Type Info

$targetPath = Join-Path -Path $PSScriptRoot -ChildPath $EnvVars.CERTS_DIR
Write-Message -Message "Using path: $targetPath" -Type Info

Install-Certificates -CertPath $targetPath

Write-Message -Message "Certificate installation process completed." -Type Info
