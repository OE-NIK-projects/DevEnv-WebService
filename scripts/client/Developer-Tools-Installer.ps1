# Prerequisite:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Developer-Tools-Installer.ps1
# A PowerShell script to install developer tools using winget and a root CA certificate

# Ensure winget is available
function Test-Winget {
    try {
        winget --version | Out-Null
        return $true
    }
    catch {
        Write-Host "winget is not installed or not found. Please ensure winget is installed."
        Write-Host "You can install it via Microsoft Store or download from https://github.com/microsoft/winget-cli"
        exit 1
    }
}

# Check if running with administrative privileges
function Test-Admin {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# List of programs to install
$programs = @(
    "Google.Chrome",
    "Microsoft.WindowsTerminal",
    "Microsoft.VisualStudioCode",
    "OpenJS.NodeJS",
    "Git.Git",
    "GitHub.GitHubDesktop",
    "VideoLAN.VLC",
    "Python.Python.3.13",
    "Postman.Postman",
    "Docker.DockerDesktop"
)

# Check for winget
if (-not (Test-Winget)) {
    exit 1
}

# Install each program
foreach ($program in $programs) {
    Write-Host "Installing [$($program)]..." -ForegroundColor Magenta
    try {
        winget install --id $program -e --silent --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$($program)] installed successfully." -ForegroundColor Green
        }
        else {
            Write-Host "Failed to install [$($program)]. Exit code: $LASTEXITCODE" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error installing [$($program)]: $_" -ForegroundColor Red
    }
    Write-Host
}

# Enable WSL2
Write-Host "Enabling WSL2..." -ForegroundColor Cyan
try {
    Write-Host "WSL2 installation initiated. Follow any prompts to complete setup." -ForegroundColor Cyan
    wsl --install
}
catch {
    Write-Host "Error enabling WSL2: $_" -ForegroundColor Red
}
Write-Host

# Install root CA certificate
Write-Host "Installing root CA certificate..." -ForegroundColor Cyan
try {
    # Define URL and temporary file path
    $certUrl = "https://raw.githubusercontent.com/OE-NIK-projects/DevEnv-WebService/refs/heads/main/config/certs/rca.crt"
    $tempCertPath = "$env:TEMP\rca.crt"

    # Download the certificate
    Invoke-WebRequest -Uri $certUrl -OutFile $tempCertPath
    Write-Host "Certificate downloaded to $tempCertPath" -ForegroundColor Cyan

    # Import the certificate to the Local Machine Root store
    Import-Certificate -FilePath $tempCertPath -CertStoreLocation Cert:\LocalMachine\Root
    Write-Host "Root CA certificate installed successfully." -ForegroundColor Green

    # Clean up temporary file
    Remove-Item -Path $tempCertPath -Force
    Write-Host "Temporary certificate file removed." -ForegroundColor Cyan
}
catch {
    Write-Host "Error installing root CA certificate: $_" -ForegroundColor Red
    # Clean up temporary file if it exists
    if (Test-Path $tempCertPath) {
        Remove-Item -Path $tempCertPath -Force
    }
}
Write-Host

# Set up git global config in the same PowerShell instance
Write-Host "Configuring git..." -ForegroundColor Cyan
try {
    # Define Git's expected path
    $gitPath = "C:\Program Files\Git\bin"

    # Check if git is available
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        # Check if Git is installed but not in PATH
        if (Test-Path "$gitPath\git.exe") {
            Write-Host "Git found at $gitPath but not in PATH. Updating PATH..." -ForegroundColor Yellow
            $env:PATH += ";$gitPath"
            
            # Verify Git is now recognizable
            if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
                throw "Failed to add Git to PATH. Please restart PowerShell or system."
            }
        }
        else {
            throw "Git is not installed. Ensure Git.Git was installed successfully."
        }
    }

    # Run git config commands in the same instance
    git config --global user.name "mezo.gyorgy"
    git config --global user.email "mezo.gyorgy@boilerplate.lan"
    git config --global user.password "Password1!"
    Write-Host "Git configuration successful." -ForegroundColor Green
}
catch {
    Write-Host "Error configuring git: $_" -ForegroundColor Red
    Write-Host "Ensure Git is installed and available in PATH. If recently installed, try restarting PowerShell or system." -ForegroundColor Yellow
}

Write-Host "Installation process completed. Restart the system!" -ForegroundColor Cyan
