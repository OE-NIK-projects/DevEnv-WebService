#!/usr/bin/env pwsh

$global:remoteUser = $null
$global:remoteHost = $null

#$global:remoteUser = "test"
#$global:remoteHost = "192.168.247.135"

$homeDir = $env:HOME ?? $env:USERPROFILE
$sshKeyPath = "$homeDir/.ssh/gitlab_id_rsa"
$sshPubKey = "$sshKeyPath.pub"
$sshKeySize = 4096

$dockerDir = "~/docker"
$gitlabDir = "$dockerDir/gitlab"

$global:serverDomain = "example.com"
$global:webAppDomain = "webapp.$global:serverDomain"
$global:gitlabDomain = "gitlab.$global:serverDomain"
$global:gitlabRootPassword = "Password1!"

$dotEnvFile = "$PSScriptRoot/.env"
$dockerComposeFile = "$PSScriptRoot/docker-compose.yml"

function Set-Remote-Access {
    while ($true) {
        $userInput = Read-Host "Enter remote username"
        if (-not [string]::IsNullOrWhiteSpace($userInput)) {
            $global:remoteUser = $userInput
            break
        }
        Write-Host "Username cannot be empty. Please enter a valid username." -ForegroundColor Red
    }

    while ($true) {
        $hostInput = Read-Host "Enter remote host (IP or hostname)"
        if (-not [string]::IsNullOrWhiteSpace($hostInput)) {
            $global:remoteHost = $hostInput
            break
        }
        Write-Host "Host cannot be empty. Please enter a valid host." -ForegroundColor Red
    }

    Write-Host "Remote user: $global:remoteUser" -ForegroundColor Green
    Write-Host "Remote host: $global:remoteHost" -ForegroundColor Green
    #TODO: Test with ping, and/or start over
}

function Invoke-SSH-Command {
    [CmdletBinding()]
    param ([string] $Command = "")

    ssh -i $sshKeyPath "$global:remoteUser@$global:remoteHost" "$Command"
}

function Invoke-SCP-Command {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Source,
        [Parameter(Mandatory = $true)]
        [string] $Destination
    )

    scp -i $sshKeyPath $Source "${global:remoteUser}@${global:remoteHost}:${Destination}"
}

function New-SSH-Key {
    [CmdletBinding()]
    param([int] $KeySize = $sshKeySize)

    Write-Host "Generating SSH key with size $KeySize bits..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b $KeySize -f $sshKeyPath -N ""
}

function Send-SSH-Key {
    $pubKeyContent = Get-Content $sshPubKey
    Write-Host "Uploading SSH public key to $global:remoteHost..." -ForegroundColor Cyan
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
    $generateKey = Read-Host "Do you want to set up SSH public key authentication? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($generateKey) -or "y" -eq $generateKey) {
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
    else {
        Write-Host "Operation aborted" -ForegroundColor Red
        exit 1
    }
}

function Set-Server-Config {
    Write-Host "Updating repositories..." -ForegroundColor Cyan
    Invoke-SSH-Command "sudo apt update -qq 2>/dev/null && sudo apt upgrade -y -qq 2>/dev/null"

    Write-Host "Removing unused packages..." -ForegroundColor Cyan
    Invoke-SSH-Command "sudo apt autoremove -y > /dev/null 2>&1"

    Write-Host "Adding '$global:remoteUser' user to 'docker' and 'sudo' groups..." -ForegroundColor Cyan
    Invoke-SSH-Command "sudo groupadd docker && sudo usermod -aG docker $USER && sudo usermod -aG sudo $USER"
}

function New-GitLab-Directories {
    try {
        Write-Host "Creating GitLab directories on $global:remoteHost..." -ForegroundColor Cyan
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

function New-Server-Domain {
    [CmdletBinding()]
    param ([string] $Domain)

    $newDomain = Read-Host "Please enter the server domain name ($global:serverDomain)"
    if (-not [string]::IsNullOrWhiteSpace($newDomain)) {
        $global:serverDomain = "$newDomain"
        $global:webAppDomain = "webapp.$newDomain"
        $global:gitlabDomain = "gitlab.$newDomain"
    }
    Write-Host "Server domain: $global:serverDomain" -ForegroundColor Green
    Write-Host "WebApp domain: $global:webAppDomain" -ForegroundColor Green
    Write-Host "GitLab domain: $global:gitlabDomain" -ForegroundColor Green
}

function New-Root-Password {
    while ($true) {
        $newPassword = Read-Host "Initial root password ($global:gitlabRootPassword)"

        # If input is empty, use the predefined password
        if ([string]::IsNullOrWhiteSpace($newPassword)) {
            Write-Host "Using default password: $global:gitlabRootPassword" -ForegroundColor Yellow
            return
        }

        # Validate password length (at least 8 characters)
        if ($newPassword.Length -lt 8) {
            Write-Host "Password must be at least 8 characters long." -ForegroundColor Red
            continue
        }

        # Check for at least one uppercase letter (A-Z)
        if ($newPassword -cnotmatch '[A-Z]') {
            Write-Host "Password must contain at least one UPPERCASE letter (A-Z)." -ForegroundColor Red
            continue
        }

        # Check for at least one lowercase letter (a-z)
        if ($newPassword -cnotmatch '[a-z]') {
            Write-Host "Password must contain at least one lowercase letter (a-z)." -ForegroundColor Red
            continue
        }

        # Check for at least one number (0-9)
        if ($newPassword -notmatch '\d') {
            Write-Host "Password must contain at least one number (0-9)." -ForegroundColor Red
            continue
        }

        # Check for at least one special character
        if ($newPassword -notmatch '[!@#$%^&*()]') {
            Write-Host "Password must contain at least one special character (!@#$%^&*())." -ForegroundColor Red
            continue
        }

        # If password meets all requirements, store it
        $global:gitlabRootPassword = $newPassword
        Write-Host "Initial root password set successfully!" -ForegroundColor Green
        return
    }
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

function Set-GitLab-Environment {
    Write-Host "Creating and Uploading '.env' file to $global:remoteHost..." -ForegroundColor Cyan
    New-Environment-File -Domain $global:serverDomain -RootPasswd $global:gitlabRootPassword
    Invoke-SCP-Command -Source $dotEnvFile -Destination "$dockerDir"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully uploaded '.env'" -ForegroundColor Green
    }
    else {
        Write-Host "Error during file upload. Error code: ${LASTEXITCODE}" -ForegroundColor Red
    }

    Write-Host "Uploading 'docker-compose.yml' to $global:remoteHost..." -ForegroundColor Cyan
    Invoke-SCP-Command -Source $dockerComposeFile -Destination "$dockerDir"

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Successfully uploaded 'docker-compose.yml'" -ForegroundColor Green
    }
    else {
        Write-Host "Error during file upload. Error code: ${LASTEXITCODE}" -ForegroundColor Red
    }
}

function Set-Up-GitLab {
    New-GitLab-Directories
    New-Server-Domain
    New-Root-Password
    Set-GitLab-Environment
}

# Execute functions
Write-Host "[Remote Access]" -ForegroundColor Magenta
Set-Remote-Access

Write-Host "[SSH Public Key Authentication]" -ForegroundColor Magenta
Set-SSH-Auth

Write-Host "[Server Configuration]" -ForegroundColor Magenta
Set-Server-Config

Write-Host "[Gitlab Configuration]" -ForegroundColor Magenta
Set-Up-GitLab