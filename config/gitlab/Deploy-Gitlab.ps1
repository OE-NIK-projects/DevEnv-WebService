$remoteUser = "test"
$remoteHost = "192.168.247.135"
$remoteHostPassword = ""

$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
$sshPubKey = "$env:USERPROFILE\.ssh\id_rsa.pub"
$sshKeySize = 4096

function Execute-SSH-Command {
    [CmdletBinding()]
    param ([string] $Command = "")
    ssh "$remoteUser@$remoteHost" "$Command"
}

function Generate-SSH-Key {
    [CmdletBinding()]
    param([int] $KeySize = $sshKeySize)
    Write-Host "Generating SSH key with size $KeySize bits..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b $KeySize -f $sshKeyPath -N ""
}

function Upload-SSH-Key {
    $pubKeyContent = Get-Content $sshPubKey
    Write-Host "Uploading SSH public key to $remoteHost..." -ForegroundColor Cyan
    Execute-SSH-Command -Command "mkdir -p ~/.ssh && echo '$pubKeyContent' >> ~/.ssh/authorized_keys"
}

function Verify-SSH-Key-Upload {
    Write-Host "Testing SSH connection..." -ForegroundColor Cyan
    $testResult = Execute-SSH-Command -Command "echo 'SSH connection successful'" 2>&1
            
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Success: " -ForegroundColor Green -NoNewline
        Write-Host "$testResult"
    }
    else {
        Write-Warning "SSH authentication test failed. Error: $testResult"
        Write-Host "Tip: Check key permissions and server configuration" -ForegroundColor Yellow
    }
}

function Set-Up-SSH-Auth {
    $generateKey = Read-Host "Do you want to set up SSH public key authentication? (y/n)"
    if ($generateKey -eq "y") {
        if (Test-Path $sshPubKey -PathType Leaf) {
            try {
                Write-Host "Found existing SSH public key at " -NoNewline
                Write-Host "$sshPubKey" -ForegroundColor Cyan
                
                Upload-SSH-Key
                Verify-SSH-Key-Upload
            }
            catch {
                Write-Error "SSH key setup failed: $_"
            }
        }
        else {
            Write-Host "No existing key found, creating new one" -ForegroundColor Yellow
            $keySizeInput = Read-Host "SSH key size ($sshKeySize)"
        
            if ([string]::IsNullOrWhiteSpace($keySizeInput)) {
                Write-Host "Using default key size: $sshKeySize" -ForegroundColor Cyan
                $keySize = $sshKeySize
            }
            elseif (-not [int]::TryParse($keySizeInput, [ref]$null)) {
                Write-Warning "Invalid key size '$keySizeInput'. Using default size $sshKeySize"
                $keySize = $sshKeySize
            }
            else {
                $keySize = [int]$keySizeInput
                Write-Host "Using key size: $keySize" -ForegroundColor Cyan
            }

            Generate-SSH-Key -KeySize $keySize
            Upload-SSH-Key
            Verify-SSH-Key-Upload
        }
    }
    elseif ($generateKey -eq "n") {
        $remoteHostPassword = Read-Host "Remote host password"
        Write-Host "Password authentication selected" -ForegroundColor Cyan
    }
    else {
        Write-Host "Operation aborted" -ForegroundColor Red
        return
    }
}

Set-Up-SSH-Auth