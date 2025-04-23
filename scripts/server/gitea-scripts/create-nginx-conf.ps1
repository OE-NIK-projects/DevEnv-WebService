. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Generate-NginxConf {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OutputDir,

        [Parameter(Mandatory = $true)]
        [string]$LogDir,

        [Parameter(Mandatory = $false)]
        [string]$FileName = "nginx.conf",

        [Parameter(Mandatory = $true)]
        [string]$GiteaDomain,

        [Parameter(Mandatory = $true)]
        [string]$GiteaProxyPassHost,

        [Parameter(Mandatory = $true)]
        [string]$GiteaProxyPassPort,

        [Parameter(Mandatory = $true)]
        [string]$WebAppDomain,

        [Parameter(Mandatory = $true)]
        [string]$WebAppProxyPassHost,

        [Parameter(Mandatory = $true)]
        [string]$WebAppProxyPassPort
    )

    try {
        if (-not (Test-Path -Path $LogDir)) {
            New-Item -Path $LogDir -ItemType Directory
            Write-Message -Message "Created directory: $LogDir" -Type Success
        }
        else {
            Write-Message -Message "Directory already exists: $LogDir" -Type Error
        }

        $confFilePath = Join-Path -Path $OutputDir -ChildPath $FileName

        $nginxConf = @"
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    keepalive_timeout  65;

    # Web App: Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name $WebAppDomain;
        return 301 https://`$host`$request_uri;
    }

    # Web App: HTTPS server
    server {
        listen 443 ssl;
        server_name $WebAppDomain;

        # SSL configuration
        ssl_certificate /etc/nginx/certs/domain.crt;
        ssl_certificate_key /etc/nginx/certs/domain.key;

        location / {
            proxy_pass http://$($WebAppProxyPassHost):$($WebAppProxyPassPort);
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
    }

    # Gitea: Redirect HTTP to HTTPS
    server {
        listen 80;
        server_name $GiteaDomain;
        return 301 https://`$host`$request_uri;
    }

    # Gitea: HTTPS server
    server {
        listen 443 ssl;
        server_name $GiteaDomain;

        # SSL configuration
        ssl_certificate /etc/nginx/certs/domain.crt;
        ssl_certificate_key /etc/nginx/certs/domain.key;

        location / {
            client_max_body_size 512M;

            proxy_pass http://$($GiteaProxyPassHost):$($GiteaProxyPassPort);
            proxy_set_header Connection `$http_connection;
            proxy_set_header Upgrade `$http_upgrade;
            proxy_set_header Host `$host;
            proxy_set_header X-Real-IP `$remote_addr;
            proxy_set_header X-Forwarded-For `$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto `$scheme;
        }
    }
}
"@

        $nginxConf | Out-File -FilePath $confFilePath -Encoding utf8 -Force
        Write-Message -Message "Generated nginx.conf at: $confFilePath" -Type Success

        if ($Debug.EnableNginxConfFileLogging) {
            Write-Message -Message "Generated nginx.conf content:`n$nginxConf" -Type Info
        }
    }
    catch {
        Write-Message -Message "Failed to generate nginx.conf at: $confFilePath. Error: $($_.Exception.Message)" -Type Error
        throw
    }
}

Write-Message -Message "Starting nginx.conf generation process..." -Type Info

$targetDir = Join-Path -Path $PSScriptRoot -ChildPath ".." | Join-Path -ChildPath "nginx"
$logDir = Join-Path -Path $targetDir -ChildPath "logs"

Write-Message -Message "Using target directory: $targetDir" -Type Info

Generate-NginxConf -OutputDir $targetDir `
    -LogDir $logDir `
    -GiteaDomain $EnvVars.GITEA__server__DOMAIN `
    -GiteaProxyPassHost $EnvVars.GITEA_CONTAINER_NAME `
    -GiteaProxyPassPort $EnvVars.GITEA__server__HTTP_PORT `
    -WebAppDomain $EnvVars.WEBAPP_DOMAIN `
    -WebAppProxyPassHost $EnvVars.WEBAPP_CONTAINER_NAME `
    -WebAppProxyPassPort $EnvVars.WEBAPP_PORT

Write-Message -Message "nginx.conf generation process completed.`n" -Type Info
