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
        $certFileName = "rca.crt"
        $certFile = Join-Path -Path $CertPath -ChildPath $certFileName

        if (-not (Test-Path -Path $caCertsDir)) {
            Write-Message -Message "Creating CA certificates directory: $caCertsDir" -Type Info
            sudo mkdir -p $caCertsDir
        }

        Write-Message -Message "Checking for certificate file: $certFile..." -Type Info
        if (-not (Test-Path -Path $certFile -PathType Leaf)) {
            Write-Message -Message "Certificate file not found: $certFile" -Type Error
            exit 1
        }

        Write-Message -Message "Found certificate file: $certFile" -Type Success

        $targetCertPath = Join-Path -Path $caCertsDir -ChildPath $certFileName

        Write-Message -Message "Copying $certFile to $targetCertPath..." -Type Info
        sudo cp $certFile $targetCertPath

        if (-not (Test-Path -Path $targetCertPath)) {
            Write-Message -Message "Failed to copy certificate to $targetCertPath" -Type Error
            exit 1
        }

        Write-Message -Message "Updating CA certificates store..." -Type Info
        sudo update-ca-certificates
    }
    catch {
        Write-Message -Message "Failed to install certificate: $($_.Exception.Message)" -Type Error
        throw
    }
}

Write-Message -Message "Starting certificate installation process..." -Type Info

$targetPath = Join-Path -Path $PSScriptRoot -ChildPath $EnvVars.CERTS_DIR
Write-Message -Message "Using path: $targetPath" -Type Info

Install-Certificates -CertPath $targetPath

Write-Message -Message "Certificate installation process completed." -Type Info
