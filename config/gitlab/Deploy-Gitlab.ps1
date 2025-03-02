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
    ssh-keygen -t rsa -b $KeySize -f $sshKeyPath -N ""
}

function Upload-SSH-Key {
    $pubKeyContent = Get-Content $sshPubKey
    Execute-SSH-Command -Command "mkdir -p ~/.ssh && echo '$pubKeyContent' >> ~/.ssh/authorized_keys"
}

function Verify-SSH-Key-Upload {
    $testResult = Execute-SSH-Command -Command "echo 'SSH connection successful'" 2>&1
            
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Result: $testResult"
    }
    else {
        Write-Warning "SSH authentication test failed. Error: $testResult"
        Write-Host "You may need to check the key permissions or server configuration"
    }
}

$generateKey = Read-Host "Do you want to set up SSH public key authentication? (y/n)"
if ($generateKey -eq "y") {
    if (Test-Path $sshPubKey -PathType Leaf) {
        try {
            Write-Host "Existing SSH public key found at $sshPubKey"
            
            Write-Host "Uploading SSH public key..."
            Upload-SSH-Key
            
            Write-Host "Verifying SSH authentication..."
            Verify-SSH-Key-Upload
        }
        catch {
            Write-Error "An error occurred during SSH key setup: $_"
        }
    }
    else {
        $keySizeInput = Read-Host "SSH key size ($sshKeySize)"
        
        if ([string]::IsNullOrWhiteSpace($keySizeInput)) {
            $keySize = $sshKeySize
        }
        else {
            $keySize = [int]$keySizeInput
        }

        Generate-SSH-Key -KeySize $keySize
        Upload-SSH-Key
    }
}
elseif ($generateKey -eq "n") {
    $remoteHostPassword = Read-Host "Remote host password"
}
else {
    Write-Host "Abort."
    return
}

