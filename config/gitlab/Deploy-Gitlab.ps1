#!/usr/bin/env pwsh

$remoteUser = "test"
$remoteHost = "192.168.247.135"
$remoteHostPassword = $null

$homeDir = $env:HOME ?? $env:USERPROFILE
$sshKeyPath = "$homeDir/.ssh/gitlab_id_rsa"
$sshPubKey = "$sshKeyPath.pub"
$sshKeySize = 4096

$dockerDir = "~/docker"
$gitlabDir = "$dockerDir/gitlab"
$global:gitlabUrl = "example.com"
$global:gitlabRootPassword = "password"

$dotEnvFile = "$PSScriptRoot/.env"

function Invoke-SSH-Command {
    [CmdletBinding()]
    param ([string] $Command = "")

    ssh -i $sshKeyPath "$remoteUser@$remoteHost" "$Command"
}

function Invoke-SCP-Command {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Source,
        [Parameter(Mandatory = $true)]
        [string] $Destination
    )

    scp -i $sshKeyPath $Source "${remoteUser}@${remoteHost}:${Destination}"
}

function New-SSH-Key {
    [CmdletBinding()]
    param([int] $KeySize = $sshKeySize)

    Write-Host "Generating SSH key with size $KeySize bits..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b $KeySize -f $sshKeyPath -N ""
}

function Send-SSH-Key {
    $pubKeyContent = Get-Content $sshPubKey
    Write-Host "Uploading SSH public key to $remoteHost..." -ForegroundColor Cyan
    Invoke-SSH-Command -Command "mkdir -p ~/.ssh && echo '$pubKeyContent' >> ~/.ssh/authorized_keys"
}

function Test-SSH-Key-Upload {
    Write-Host "Testing SSH connection..." -ForegroundColor Cyan
    $testResult = Invoke-SSH-Command -Command "echo 'SSH connection successful'" 2>&1
            
    if ($LASTEXITCODE -eq 0) {
        Write-Host "$testResult" -ForegroundColor Green
    }
    else {
        Write-Warning "SSH authentication test failed. Error: $testResult"
        Write-Host "Tip: Check key permissions and server configuration" -ForegroundColor Yellow
    }
}

function Set-SSH-Auth {
    $generateKey = Read-Host "Do you want to set up SSH public key authentication? (y/n)"
    if ($generateKey -eq "y") {
        $newKeyPath = Read-Host "Private key path ($sshKeyPath)"
        if (Test-Path $newKeyPath -IsValid -PathType Leaf) {
            $sshKeyPath = $newKeyPath
            $sshPubKey = "$sshKeyPath.pub"
        }

        Write-Host "Using " -NoNewline
        Write-Host $sshKeyPath -ForegroundColor Cyan

        if (Test-Path $sshPubKey -PathType Leaf) {
            try {
                Write-Host "Found existing SSH public key at " -NoNewline
                Write-Host "$sshPubKey" -ForegroundColor Cyan
                
                Send-SSH-Key
                Test-SSH-Key-Upload
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

            New-SSH-Key -KeySize $keySize
            Send-SSH-Key
            Test-SSH-Key-Upload
        }
    }
    elseif ($generateKey -eq "n") {
        Write-Host "Password authentication selected" -ForegroundColor Cyan
        if ([string]::IsNullOrWhiteSpace($remoteHostPassword)) {
            $remoteHostPassword = Read-Host "Remote host password"
        }
    }
    else {
        Write-Host "Operation aborted" -ForegroundColor Red
        return
    }
}

function New-GitLab-Directories {
    try {
        Write-Host "Creating GitLab directories on $remoteHost..." -ForegroundColor Cyan
        $result = Invoke-SSH-Command "mkdir -p $gitlabDir/config && mkdir -p $gitlabDir/data && mkdir -p $gitlabDir/logs"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "GitLab directories created successfully" -ForegroundColor Green
        }
        else {
            Write-Warning "Failed to create GitLab directories. Error: $result"
        }
    }
    catch {
        Write-Error "Error creating GitLab directories: $_"
        throw
    }
}

function New-GitLab-Url {
    [CmdletBinding()]
    param ([string] $Domain)

    $newDomain = Read-Host "Please enter the GitLab domain ($global:gitlabUrl)"
    if (-not [string]::IsNullOrWhiteSpace($newDomain)) {
        $global:gitlabUrl = "gitlab.$newDomain"
    }
    Write-Host "Using GitLab domain: $global:gitlabUrl" -ForegroundColor Cyan
}

function New-Root-Password {
    $newPassword = Read-Host "Initial root password ($global:gitlabRootPassword)"
    if (-not [string]::IsNullOrWhiteSpace($newPassword)) {
        $global:gitlabRootPassword = $newPassword
    }
    
    Write-Host "Initial root password: $global:gitlabRootPassword" -ForegroundColor Cyan
}

function New-Environment-File {
    [CmdletBinding()]
    param ([string] $Domain, [string] $RootPasswd)
    
    $content = @"
#Gitlab pre-configuration
GITLAB_CONTAINER_NAME="gitlab"
GITLAB_URL="${Domain}"
GITLAB_SSH_PORT=2424
GITLAB_HOME_DIR="./gitlab"
GITLAB_INITIAL_ROOT_PASSWORD="${RootPasswd}"

#Restricting Gitlab memory usage
GITLAB_PUMA_WORKER_PROCESSES=0
GITLAB_PROMETHEUS_MONITORING=false
GITLAB_SIDEKIQ_MAX_CONCURRENCY=10
"@
    
    $content | Out-File .env -Encoding UTF8 -Force
}

function Set-GitLab-Environment-File {
    Write-Host "Creating '.env' file" -ForegroundColor Cyan
    New-Environment-File -Domain $global:gitlabUrl -RootPasswd $global:gitlabRootPassword

    Write-Host "Uploading '.env' to $remoteHost" -ForegroundColor Cyan
    Invoke-SCP-Command -Source $dotEnvFile -Destination "$dockerDir"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully uploaded '.env'" -ForegroundColor Green
    }
    else {
        Write-Host "Error during file upload. Error code: ${LASTEXITCODE}" -ForegroundColor Red
    }
}

function Set-Up-GitLab {
    New-GitLab-Directories
    New-GitLab-Url
    New-Root-Password
    Set-GitLab-Environment-File
}

# Execute functions
Write-Host "[SSH Public Key Authentication]" -ForegroundColor Magenta
Set-SSH-Auth

Write-Host "[Gitlab Configuration]" -ForegroundColor Magenta
Set-Up-GitLab