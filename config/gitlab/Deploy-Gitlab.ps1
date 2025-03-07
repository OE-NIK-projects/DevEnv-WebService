#!/usr/bin/env pwsh

# Configuration Object
$Config = @{
    RemoteUser         = $null
    RemoteHost         = $null
    HomeDir            = $env:HOME ?? $env:USERPROFILE
    SSHKeySize         = 4096
    DockerDir          = "~/docker"
    ServerDomain       = "boilerplate.hu"
    GitlabRootUsername = "root"
    GitlabRootPassword = "Password1!"
    ScriptRoot         = $PSScriptRoot
}

# Derived Paths
$Paths = @{
    SSHKeyPath        = Join-Path $Config.HomeDir ".ssh/gitlab_id_rsa"
    SSHPubKey         = Join-Path $Config.HomeDir ".ssh/gitlab_id_rsa.pub"
    GitlabDir         = Join-Path $Config.DockerDir "gitlab"
    DotEnvFile        = Join-Path $Config.ScriptRoot ".env"
    DockerComposeFile = Join-Path $Config.ScriptRoot "docker-compose.yml"
}

# Domain Configuration
$Domains = @{
    WebApp = "webapp.$($Config.ServerDomain)"
    Gitlab = "gitlab.$($Config.ServerDomain)"
}

# SSH Helper Functions
function Invoke-SSH {
    param ([string]$Command)
    ssh -i $Paths.SSHKeyPath "$($Config.RemoteUser)@$($Config.RemoteHost)" "$Command"
}

function Invoke-SCP {
    param ([string]$Source, [string]$Destination)
    scp -i $Paths.SSHKeyPath $Source "$($Config.RemoteUser)@$($Config.RemoteHost):$Destination"
}

function Test-CommandSuccess {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SuccessMessage,
        
        [Parameter(Mandatory = $true)]
        [string]$FailureMessage,
        
        [Parameter(Mandatory = $false)]
        $Result = ""
    )
    
    $resultString = $(if ($null -eq $Result) { "" } else { $Result | Out-String }).Trim()
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host $SuccessMessage -ForegroundColor Green
        return $true
    }
    else {
        Write-Warning "$FailureMessage$resultString : Exit code $LASTEXITCODE"
        return $false
    }
}

# Core Functions
function Set-RemoteAccess {
    while ($true) {
        try {
            $userInput = Read-Host "Enter remote username"
            if ([string]::IsNullOrWhiteSpace($userInput)) { throw "Username cannot be empty" }

            $hostInput = Read-Host "Enter remote host (IP or hostname)"
            if ([string]::IsNullOrWhiteSpace($hostInput)) { throw "Host cannot be empty" }

            Write-Host "Pinging $hostInput..." -ForegroundColor Yellow
            if (Test-Connection -ComputerName $hostInput -Count 2 -Quiet) {
                $Config.RemoteUser = $userInput
                $Config.RemoteHost = $hostInput
                Write-Host "Remote: $($Config.RemoteUser)@$($Config.RemoteHost)" -ForegroundColor Green
                return
            }
            throw "Host is unreachable"
        }
        catch {
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
}

function New-SSHKey {
    param ([int]$KeySize = $Config.SSHKeySize)
    Write-Host "Generating SSH key ($KeySize bits)..." -ForegroundColor Cyan
    ssh-keygen -t rsa -b $KeySize -f $Paths.SSHKeyPath -N "" | Out-Null
    if (-not (Test-CommandSuccess -SuccessMessage "SSH key generated" -FailureMessage "SSH key generation failed: ")) {
        throw "SSH key generation failed"
    }
}

function Send-SSHKey {
    $pubKeyContent = Get-Content $Paths.SSHPubKey
    Write-Host "Uploading SSH key..." -ForegroundColor Cyan
    $result = Invoke-SSH -Command "mkdir -p ~/.ssh && echo '$pubKeyContent' >> ~/.ssh/authorized_keys"
    Test-CommandSuccess -SuccessMessage "SSH key uploaded" -FailureMessage "SSH key upload failed: " -Result $result | Out-Null
}

function Test-SSHConnection {
    Write-Host "Testing SSH..." -ForegroundColor Cyan
    $result = Invoke-SSH -Command "echo 'SSH connection successful'" 2>&1
    Test-CommandSuccess -SuccessMessage $result -FailureMessage "SSH test failed: " -Result $result | Out-Null
}

function Set-SSHAuthentication {
    $choice = Read-Host "Setup SSH key authentication? (Y/n)"
    if ([string]::IsNullOrWhiteSpace($choice) -or $choice -eq "y") {
        try {
            if (-not (Test-Path $Paths.SSHPubKey)) {
                $sizeInput = Read-Host "SSH key size ($($Config.SSHKeySize))"
                $keySize = if ([int]::TryParse($sizeInput, [ref]$null)) { $sizeInput } else { $Config.SSHKeySize }
                New-SSHKey -KeySize $keySize
            }
            Send-SSHKey
            Test-SSHConnection
        }
        catch {
            Write-Error "SSH setup failed: $_"
        }
    }
    else {
        Write-Host "Operation aborted" -ForegroundColor Red
        exit 1
    }
}

function Set-ServerConfiguration {
    Write-Host "Configuring server..." -ForegroundColor Cyan
    $updateResult = Invoke-SSH "sudo apt update -qq 2>/dev/null && sudo apt upgrade -y -qq 2>/dev/null"
    Test-CommandSuccess -SuccessMessage "Server updated" -FailureMessage "Server update failed: " -Result $updateResult | Out-Null

    $removeResult = Invoke-SSH "sudo apt autoremove -y > /dev/null 2>&1"
    Test-CommandSuccess -SuccessMessage "Unused packages removed" -FailureMessage "Package removal failed: " -Result $removeResult | Out-Null

    $groupResult = Invoke-SSH "sudo groupadd docker; sudo usermod -aG docker,sudo $($Config.RemoteUser)"
    Test-CommandSuccess -SuccessMessage "User groups configured" -FailureMessage "Group configuration failed: " -Result $groupResult | Out-Null
}

function New-GitlabDirectories {
    Write-Host "Creating GitLab directories..." -ForegroundColor Cyan
    $result = Invoke-SSH "mkdir -p $($Paths.GitlabDir)/{config,data,logs}"
    if (-not (Test-CommandSuccess -SuccessMessage "Directories created" -FailureMessage "Failed to create directories: " -Result $result)) {
        throw "Directory creation failed"
    }
}

function Set-GitlabPassword {
    while ($true) {
        $newPass = Read-Host "Initial root password ($($Config.GitlabRootPassword))"
        if ([string]::IsNullOrWhiteSpace($newPass)) { return }
        
        if ($newPass.Length -lt 8 -or
            $newPass -cnotmatch '[A-Z]' -or
            $newPass -cnotmatch '[a-z]' -or
            $newPass -notmatch '\d' -or
            $newPass -notmatch '[!@#$%^&*()]') {
            Write-Host "Password must be 8+ chars with upper, lower, number, and special char" -ForegroundColor Red
            continue
        }
        $Config.GitlabRootPassword = $newPass
        Write-Host "Password set" -ForegroundColor Green
        return
    }
}

function New-EnvironmentFile {
    param ([string]$Domain, [string]$Passwd)
    $envContent = @"
GITLAB_CONTAINER_NAME="gitlab"
GITLAB_URL="$Domain"
GITLAB_SSH_PORT=2424
GITLAB_HOME_DIR="./gitlab"
GITLAB_INITIAL_ROOT_PASSWORD="$Passwd"
GITLAB_PUMA_WORKER_PROCESSES=0
GITLAB_PROMETHEUS_MONITORING=false
GITLAB_SIDEKIQ_MAX_CONCURRENCY=10
"@
    $envContent | Out-File $Paths.DotEnvFile -Encoding UTF8 -Force
}

function Set-GitlabEnvironment {
    Write-Host "Setting up GitLab environment..." -ForegroundColor Cyan
    New-EnvironmentFile -Domain $Config.ServerDomain -Password $Config.GitlabRootPassword
    
    Invoke-SCP -Source $Paths.DotEnvFile -Destination $Config.DockerDir
    Invoke-SCP -Source $Paths.DockerComposeFile -Destination $Config.DockerDir
    
    Test-CommandSuccess -SuccessMessage "Files uploaded" -FailureMessage "Upload failed: " | Out-Null
}

function Start-Gitlab {
    Write-Host "Starting GitLab..." -ForegroundColor Cyan
    $result = Invoke-SSH "sudo docker compose -f $($Config.DockerDir)/docker-compose.yml up -d"
    Test-CommandSuccess -SuccessMessage "GitLab started" -FailureMessage "GitLab start failed: " -Result $result | Out-Null
}

function Write-AccessInfo {
    Write-Host "Web: https://$($Config.ServerDomain)" -ForegroundColor DarkBlue
    Write-Host "WebApp: https://$($Domains.WebApp)" -ForegroundColor DarkBlue
    Write-Host "GitLab: https://$($Domains.Gitlab)" -ForegroundColor DarkBlue
    Write-Host "Username: $($Config.GitlabRootUsername)" -ForegroundColor DarkBlue
    Write-Host "Password: $($Config.GitlabRootPassword)" -ForegroundColor DarkBlue
    Write-Warning "Change initial root password ASAP!"
    Write-Host "Wait a few minutes for GitLab to boot completely..." -ForegroundColor Cyan
}

function Setup-Gitlab {
    try {
        New-GitlabDirectories
        Set-GitlabPassword
        Set-GitlabEnvironment
        Start-Gitlab
    }
    catch {
        Write-Error "GitLab setup failed: $_"
    }
}

# Main Execution
$steps = @(
    @{ Name = "Remote Access"; Function = { Set-RemoteAccess } }
    @{ Name = "SSH Authentication"; Function = { Set-SSHAuthentication } }
    @{ Name = "Server Configuration"; Function = { Set-ServerConfiguration } }
    @{ Name = "Gitlab Configuration"; Function = { Setup-Gitlab } }
    @{ Name = "Access Information"; Function = { Write-AccessInfo } }
)

foreach ($step in $steps) {
    Write-Host "[$($step.Name)]" -ForegroundColor Magenta
    & $step.Function
}
