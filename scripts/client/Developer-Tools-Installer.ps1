# Prerequisite:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

# Developer-Tools-Installer.ps1
# A PowerShell script to install developer tools using winget

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
    wsl --install
    Write-Host "WSL2 installation initiated. Follow any prompts to complete setup." -ForegroundColor Cyan
}
catch {
    Write-Host "Error enabling WSL2: $_" -ForegroundColor Red
}

Write-Host "Installation process completed." -ForegroundColor Cyan
