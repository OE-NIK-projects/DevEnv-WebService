#!/usr/bin/env pwsh

# Import write-message.ps1 and values.ps1
. $PSScriptRoot/gitea-scripts/write-message.ps1
. $PSScriptRoot/gitea-scripts/values.ps1

# Configuration Object
$Config = @{
    RemoteUser = $null
    RemoteHost = $null
    HomeDir    = $env:HOME ?? $env:USERPROFILE
    SSHKeySize = 4096
    DockerDir  = "~/services"
}

# Derived Paths
$Paths = @{
    SSHKeyPath        = Join-Path $Config.HomeDir ".ssh/gitea_id_rsa"
    SSHPubKey         = Join-Path $Config.HomeDir ".ssh/gitea_id_rsa.pub"
    GiteaScriptsDir   = Join-Path $PSScriptRoot "gitea-scripts"
    DockerComposeFile = Join-Path $PSScriptRoot "docker-compose.yml"
    LocalCertsDir     = Join-Path $PSScriptRoot "../../config/certs"
    LocalWebappDir    = Join-Path $PSScriptRoot "../../config/server/webapp"
}

# SSH Helper Functions
function Invoke-SSH {
    param ([string]$Command)
    try {
        $result = ssh -q -i $Paths.SSHKeyPath "$($Config.RemoteUser)@$($Config.RemoteHost)" "$Command" 2>&1
        return $result
    }
    catch {
        Write-Message -Message "SSH command failed: $($_.Exception.Message)" -Type Error
        throw
    }
}

function Invoke-SSHWithSU {
    param ([string]$Command)

    $script:PasswordForSudo ??= Read-Host 'Password for sudo' -MaskInput

    # Single-line command to avoid line-ending issues
    $cmd = "echo '$PasswordForSudo' | sudo -S sh -c '$Command' 2>&1"

    try {
        # Use -q to suppress SSH banner, -T to avoid pseudo-terminal allocation for non-interactive commands
        $result = ssh -q -i $Paths.SSHKeyPath -T "$($Config.RemoteUser)@$($Config.RemoteHost)" "$cmd" 2>&1
        return $result
    }
    catch {
        Write-Message -Message "SSH with sudo failed: $($_.Exception.Message)" -Type Error
        throw
    }
}

function Invoke-SCP {
    param ([string]$Source, [string]$Destination)
    try {
        $result = scp -q -i $Paths.SSHKeyPath -r $Source "$($Config.RemoteUser)@$($Config.RemoteHost):$Destination" 2>&1
        return $result
    }
    catch {
        Write-Message -Message "SCP failed: $($_.Exception.Message)" -Type Error
        throw
    }
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

    if ($LASTEXITCODE -eq 0 -and -not $resultString.Contains("error")) {
        Write-Message -Message $SuccessMessage -Type Success
        return $true
    }
    else {
        Write-Message -Message "$FailureMessage$resultString : Exit code $LASTEXITCODE" -Type Error
        return $false
    }
}

function Test-SudoCommandSuccess {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SuccessMessage,

        [Parameter(Mandatory = $true)]
        [string]$FailureMessage,

        [Parameter(Mandatory = $false)]
        $Result = ""
    )

    $resultString = $(if ($null -eq $Result) { "" } else { $Result | Out-String }).Trim()

    if ($resultString) {
        Write-Message -Message "Command output: $resultString" -Type Info
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Message -Message "$FailureMessage Exit code $($LASTEXITCODE): $resultString" -Type Error
        return $false
    }
    else {
        Write-Message -Message $SuccessMessage -Type Success
        return $true
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

            Write-Message -Message "Pinging $hostInput..." -Type Info
            if (Test-Connection -ComputerName $hostInput -Count 2 -Quiet) {
                $Config.RemoteUser = $userInput
                $Config.RemoteHost = $hostInput
                Write-Message -Message "Remote: $($Config.RemoteUser)@$($Config.RemoteHost)" -Type Success
                return
            }
            throw "Host is unreachable"
        }
        catch {
            Write-Message -Message $_.Exception.Message -Type Error
        }
    }
}

function New-SSHKey {
    param ([int]$KeySize = $Config.SSHKeySize)
    Write-Message -Message "Generating SSH key ($KeySize bits)..." -Type Info
    ssh-keygen -t rsa -b $KeySize -f $Paths.SSHKeyPath -N "" | Out-Null
    if (-not (Test-CommandSuccess -SuccessMessage "SSH key generated" -FailureMessage "SSH key generation failed: ")) {
        throw "SSH key generation failed"
    }
}

function Send-SSHKey {
    $pubKeyContent = Get-Content $Paths.SSHPubKey
    Write-Message -Message "Uploading SSH key..." -Type Info
    $result = Invoke-SSH -Command "mkdir -p ~/.ssh && echo '$pubKeyContent' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
    Test-CommandSuccess -SuccessMessage "SSH key uploaded" -FailureMessage "SSH key upload failed: " -Result $result | Out-Null
}

function Test-SSHConnection {
    Write-Message -Message "Testing SSH..." -Type Info
    $result = Invoke-SSH -Command "echo 'SSH connection successful'"
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
            Write-Message -Message "SSH setup failed: $($_.Exception.Message)" -Type Error
            throw
        }
    }
    else {
        Write-Message -Message "Operation aborted" -Type Error
        exit 1
    }
}

function Set-ServerConfiguration {
    Write-Message -Message "Configuring server..." -Type Info

    Write-Message -Message "apt update -qq && apt upgrade -y -qq" -Type Command
    $updateResult = Invoke-SSHWithSU "apt update -qq && apt upgrade -y -qq"
    Test-SudoCommandSuccess -SuccessMessage "Server updated" -FailureMessage "Server update failed: " -Result $updateResult | Out-Null

    Write-Message -Message "apt purge -y docker-compose" -Type Command
    $purgeResult = Invoke-SSHWithSU "apt purge -y docker-compose"
    Test-SudoCommandSuccess -SuccessMessage "Docker Compose V1 purged" -FailureMessage "Docker Compose V1 purge failed: " -Result $purgeResult | Out-Null

    Write-Message -Message "apt install -yqq docker docker-compose-v2" -Type Command
    $installResult = Invoke-SSHWithSU "apt install -yqq docker-compose-v2"
    Test-SudoCommandSuccess -SuccessMessage "Docker and Docker Compose V2 installed" -FailureMessage "Docker and Docker Compose V2 install failed: " -Result $installResult | Out-Null

    Write-Message -Message "apt install -yqq zip" -Type Command
    $installZipResult = Invoke-SSHWithSU "apt install -yqq zip"
    Test-SudoCommandSuccess -SuccessMessage "Zip installed" -FailureMessage "Zip install failed: " -Result $installZipResult | Out-Null

    Write-Message -Message "curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh" -Type Command
    $installScriptDownloadResult = Invoke-SSHWithSU "curl -o webmin-setup-repo.sh https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh"
    Test-SudoCommandSuccess -SuccessMessage "Webmin install script downloaded" -FailureMessage "Webmin install script download failed: " -Result $installScriptDownloadResult | Out-Null

    Write-Message -Message "sh webmin-setup-repo.sh -f" -Type Command
    $webminInstallScriptResult = Invoke-SSHWithSU "sh webmin-setup-repo.sh -f"
    Test-SudoCommandSuccess -SuccessMessage "Webmin repositories set up" -FailureMessage "Webmin repositories set up failed: " -Result $webminInstallScriptResult | Out-Null

    Write-Message -Message "apt install --install-recommends webmin usermin -yqq" -Type Command
    $webminInstallResult = Invoke-SSHWithSU "apt install --install-recommends webmin usermin -yqq"
    Test-SudoCommandSuccess -SuccessMessage "Webmin installed" -FailureMessage "Webmin install failed: " -Result $webminInstallResult | Out-Null

    Write-Message -Message "apt autoremove -y" -Type Command
    $removeResult = Invoke-SSHWithSU "apt autoremove -y"
    Test-SudoCommandSuccess -SuccessMessage "Unused packages removed" -FailureMessage "Package removal failed: " -Result $removeResult | Out-Null

    Write-Message -Message "groupadd -f docker && usermod -aG docker,sudo $($Config.RemoteUser)" -Type Command
    $groupResult = Invoke-SSHWithSU "groupadd -f docker && usermod -aG docker,sudo $($Config.RemoteUser)"
    Test-SudoCommandSuccess -SuccessMessage "User groups configured" -FailureMessage "Group configuration failed: " -Result $groupResult | Out-Null

    Write-Message -Message "ufw allow 22,80,443,10000/tcp" -Type Command
    $firewallTcpResult = Invoke-SSHWithSU "ufw allow 22,80,443,10000/tcp"
    Test-SudoCommandSuccess -SuccessMessage "Allowed 22,80,443,10000/tcp ports" -FailureMessage "Couldn't allow ports: " -Result $firewallTcpResult | Out-Null

    Write-Message -Message "ufw allow 22,80,443,10000/udp" -Type Command
    $firewallUdpResult = Invoke-SSHWithSU "ufw allow 22,80,443,10000/udp"
    Test-SudoCommandSuccess -SuccessMessage "Allowed 22,80,443,10000/udp ports" -FailureMessage "Couldn't allow ports: " -Result $firewallUdpResult | Out-Null

    Write-Message -Message "ufw --force enable" -Type Command
    $firewallUdpResult = Invoke-SSHWithSU "ufw --force enable"
    Test-SudoCommandSuccess -SuccessMessage "Firewall enabled" -FailureMessage "Couldn't enable firewall: " -Result $firewallUdpResult | Out-Null
}

function New-GiteaDirectories {
    Write-Message -Message "Creating Gitea directories on remote server..." -Type Info
    $result = Invoke-SSH "mkdir -p $($Config.DockerDir)/gitea/data $($Config.DockerDir)/gitea/config $($Config.DockerDir)/nginx/logs"
    Test-CommandSuccess -SuccessMessage "Gitea directories created" -FailureMessage "Failed to create Gitea directories: " -Result $result | Out-Null
}

function New-NginxCertsDir {
    Write-Message -Message "Creating Nginx certificates directory on remote server..." -Type Info
    $result = Invoke-SSH "mkdir -p $($Config.DockerDir)/nginx/certs"
    Test-CommandSuccess -SuccessMessage "Nginx certificates directory created" -FailureMessage "Failed to create Nginx certificates directory: " -Result $result | Out-Null
}

function Upload-GiteaScripts {
    Write-Message -Message "Uploading gitea-scripts to remote server..." -Type Info
    if (-not (Test-Path $Paths.GiteaScriptsDir)) {
        Write-Message -Message "Local gitea-scripts directory not found at $($Paths.GiteaScriptsDir)" -Type Error
        throw "gitea-scripts directory missing"
    }
    $result = Invoke-SCP -Source $Paths.GiteaScriptsDir -Destination $Config.DockerDir
    Test-CommandSuccess -SuccessMessage "gitea-scripts uploaded" -FailureMessage "Failed to upload gitea-scripts: " -Result $result | Out-Null
}

function Set-ScriptPermissions {
    Write-Message -Message "Setting executable permissions for setup.ps1 on remote server..." -Type Info
    $setupScriptPath = "$($Config.DockerDir)/gitea-scripts/setup.ps1"
    $result = Invoke-SSH "chmod +x $setupScriptPath"
    Test-CommandSuccess -SuccessMessage "Executable permissions set for setup.ps1" -FailureMessage "Failed to set executable permissions for setup.ps1: " -Result $result | Out-Null
}

function Upload-DockerCompose {
    Write-Message -Message "Uploading docker-compose.yml to remote server..." -Type Info
    if (-not (Test-Path $Paths.DockerComposeFile)) {
        Write-Message -Message "Local docker-compose.yml file not found at $($Paths.DockerComposeFile)" -Type Error
        throw "docker-compose.yml file missing"
    }
    $result = Invoke-SCP -Source $Paths.DockerComposeFile -Destination $Config.DockerDir
    Test-CommandSuccess -SuccessMessage "docker-compose.yml uploaded" -FailureMessage "Failed to upload docker-compose.yml: " -Result $result | Out-Null
}

function Upload-Certs {
    Write-Message -Message "Uploading certificates to remote server..." -Type Info
    if (-not (Test-Path $Paths.LocalCertsDir)) {
        Write-Message -Message "Local certificates directory not found at $($Paths.LocalCertsDir)" -Type Error
        throw "Certificates directory missing"
    }
    $remoteCertsDir = "$($Config.DockerDir)/nginx"
    $result = Invoke-SCP -Source $Paths.LocalCertsDir -Destination $remoteCertsDir
    Test-CommandSuccess -SuccessMessage "Certificates uploaded" -FailureMessage "Failed to upload certificates: " -Result $result | Out-Null
}

function Upload-Webapp {
    Write-Message -Message "Uploading webapp to remote server..." -Type Info
    if (-not (Test-Path $Paths.LocalWebappDir)) {
        Write-Message -Message "Local webapp directory not found at $($Paths.LocalWebappDir)" -Type Error
        throw "Webapp directory missing"
    }
    $remoteWebappDir = "$($Config.DockerDir)/webapp"
    $result = Invoke-SCP -Source $Paths.LocalWebappDir -Destination $remoteWebappDir
    Test-CommandSuccess -SuccessMessage "Webapp uploaded" -FailureMessage "Failed to upload webapp: " -Result $result | Out-Null
}

function Start-Gitea {
    Write-Message -Message "Running setup.ps1 interactively on remote server..." -Type Info
    Write-Message -Message "cd $($Config.DockerDir) && ./gitea-scripts/setup.ps1" -Type Command
    ssh -t -i $Paths.SSHKeyPath "$($Config.RemoteUser)@$($Config.RemoteHost)" "cd $($Config.DockerDir) && ./gitea-scripts/setup.ps1"

    if ($LASTEXITCODE -ne 0) {
        Write-Message -Message "Setup.ps1 failed with exit code $LASTEXITCODE" -Type Error
        throw "Setup.ps1 execution failed"
    }
}

function Write-AccessInfo {
    Write-Message -Message "Web:`thttps://$($Domains.WebApp)" -Type Info
    Write-Message -Message "Webmin:`thttps://$($Domains.Webmin)" -Type Info
    Write-Message -Message "Gitea:`thttps://$($Domains.Gitea)" -Type Info
    Write-Message -Message "Gitea admin credentials:" -Type Info
    Write-Message -Message "`t Username: $($Admins[0].Username)" -Type Info
    Write-Message -Message "`t Password: $($Admins[0].Password)" -Type Info
    Write-Message -Message "Change admin credentials ASAP!" -Type Warning
}

function Setup-Gitea {
    try {
        New-GiteaDirectories
        New-NginxCertsDir
        Upload-GiteaScripts
        Set-ScriptPermissions
        Upload-DockerCompose
        Upload-Certs
        Upload-Webapp
        Start-Gitea
    }
    catch {
        Write-Message -Message "Gitea setup failed: $($_.Exception.Message)" -Type Error
        throw
    }
}

# Main Execution
$steps = @(
    @{ Name = "Remote Access"; Function = { Set-RemoteAccess } }
    @{ Name = "SSH Authentication"; Function = { Set-SSHAuthentication } }
    @{ Name = "Server Configuration"; Function = { Set-ServerConfiguration } }
    @{ Name = "Gitea Configuration"; Function = { Setup-Gitea } }
    @{ Name = "Access Information"; Function = { Write-AccessInfo } }
)

foreach ($step in $steps) {
    Write-Message -Message "[$($step.Name)]" -Type Info
    & $step.Function
}

Write-Message -Message "Deployment completed." -Type Success
