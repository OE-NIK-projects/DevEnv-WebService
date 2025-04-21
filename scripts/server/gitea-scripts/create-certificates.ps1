. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Create-Certificates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$CertsDir
    )

    try {
        Write-Message -Message "Starting certificate creation process..." -Type Info

        $fullCertsDir = Join-Path -Path $PSScriptRoot -ChildPath $CertsDir
        if (-not (Test-Path -Path $fullCertsDir)) {
            Write-Message -Message "Creating certificates directory: $fullCertsDir" -Type Info
            New-Item -ItemType Directory -Path $fullCertsDir -Force | Out-Null
        }

        $baseSubject = "/C=HU/ST=Pest/L=Budapest/O=Boilerplate Kft./emailAddress=admin@boilerplate.lan"

        foreach ($domainEntry in $Domains.GetEnumerator()) {
            $domain = $domainEntry.Value

            $certCrt = Join-Path -Path $fullCertsDir -ChildPath "$domain.crt"
            $certKey = Join-Path -Path $fullCertsDir -ChildPath "$domain.key"
            $subject = "$baseSubject/CN=$domain"

            Write-Message -Message "Generating certificate for $domain..." -Type Info
            $opensslCmd = "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout `"$certKey`" -out `"$certCrt`" -subj `"$subject`""
            Invoke-Expression $opensslCmd

            if (-not (Test-Path -Path $certCrt) -or -not (Test-Path -Path $certKey)) {
                Write-Message -Message "Failed to generate certificate or key for $domain" -Type Error
                exit 1
            }
            Write-Message -Message "Certificate and key generated: $certCrt, $certKey" -Type Success
        }
    }
    catch {
        Write-Message -Message "Failed to create certificates: $($_.Exception.Message)" -Type Error
        throw
    }
}

Write-Message -Message "Starting certificate creation process..." -Type Info

$targetCertsDir = $EnvVars.CERTS_DIR
Write-Message -Message "Using certificates directory: $targetCertsDir" -Type Info

Create-Certificates -CertsDir $targetCertsDir

Write-Message -Message "Certificate creation completed." -Type Success
