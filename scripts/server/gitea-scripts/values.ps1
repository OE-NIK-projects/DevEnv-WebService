[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Debug')]
$Debug =@{
    EnableJsonBodyLogging = $false
    EnableNginxConfFileLogging = $false
    EnableDotEnvFileLogging = $false
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Domains')]
$Domains = @{
    Gitea = "git.boilerplate.lan"
    WebApp = "boilerplate.lan"
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Config')]
$Config = @{
    RemoteUser         = $null
    RemoteHost         = $null
    HomeDir            = $env:HOME ?? $env:USERPROFILE
    SSHKeySize         = 4096
    DockerDir          = "~/docker"
    ServerDomain       = $Domains.WebApp
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'EnvVars')]
$EnvVars = @{
    #Gitea
    GITEA_CONTAINER_NAME                 = "gitea"
    GITEA____APP_NAME                    = "Boilerplate Kft."
    GITEA__database__DB_TYPE             = "sqlite3"
    GITEA__openid__ENABLE_OPENID_SIGNIN  = "false"
    GITEA__openid__ENABLE_OPENID_SIGNUP  = "false"
    GITEA__security__INSTALL_LOCK        = "true"
    GITEA__server__DOMAIN                = $Domains.Gitea
    GITEA__server__HTTP_PORT             = "3000"
    GITEA__server__ROOT_URL              = "https://$($Domains.Gitea)"
    GITEA__server__LANDING_PAGE          = "explore"
    GITEA__server__DISABLE_SSH           = "true"
    GITEA__server__START_SSH_SERVER      = "false"
    GITEA__service__DISABLE_REGISTRATION = "true"
    #Nginx
    NGINX_CONTAINER_NAME                 = "nginx"
    NGINX_HTTP_PORT                      = "80"
    NGINX_HTTPS_PORT                     = "443"
    CERTS_DIR                            = "../nginx/certs"
    #WebApp
    WEBAPP_CONTAINER_NAME                = "webapp"
    WEBAPP_PORT                          = "80"
    WEBAPP_DOMAIN                        = $Domains.WebApp
    WEBAPP_DEVMODE                       = "false"
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Api')]
$Api = @{
    BaseUrl = "$($EnvVars.GITEA__server__ROOT_URL)/api/v1"
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'TimeoutInSeconds')]
$TimeoutInSeconds = 5

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Admins')]
$Admins = @(
    @{ 
        Username = "admin";
        Email    = "admin@boilerplate.lan";
        Password = "admin";
    }
)

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Users')]
$Users = @(
    @{ 
        Full_Name = "Mező György";
        Username  = "mezo.gyorgy";
        Email     = "mezo.gyorgy@boilerplate.lan";
        Password  = "Password1!";
    }
    @{ 
        Full_Name = "Tóth Laci";
        Username  = "toth.laci";
        Email     = "toth.laci@boilerplate.lan";
        Password  = "Password1!";
    }
    @{ 
        Full_Name = "Gábor Roland";
        Username  = "gabi.roli";
        Email     = "gabi.roli@boilerplate.lan";
        Password  = "Password1!";
    }
    @{ 
        Full_Name = "Jungle Diff";
        Username  = "jungle.diff";
        Email     = "jungle.diff@boilerplate.lan";
        Password  = "Password1!";
    }
    @{
        Full_Name = "Demeter Attila"
        Username  = "demeter.attila";
        Email     = "demeter.attila@boilerplate.lan";
        Password  = "Password1!";
    }
    @{ 
        Full_Name = "Benji Coleman";
        Username  = "benji.coleman";
        Email     = "benji.coleman@boilerplate.lan";
        Password  = "Password1!";
    }
)

#Groups
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Organizations')]
$Organizations = @(
    @{
        Username                      = "Frontend";
        Description                   = "Frontendesek";
        Repo_admin_change_team_access = $true;
    }
    @{
        Username                      = "Backend";
        Description                   = "Backendesek";
        Repo_admin_change_team_access = $true;
    }
)

#Roles
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Teams')]
$Teams = @(
    @{
        name                      = "developer"
        description               = "Developers with write access to code and pull requests"
        can_create_org_repo       = $true
        includes_all_repositories = $true
        permission                = "write"
        units                     = @(
            "repo.actions",
            "repo.code",
            "repo.issues",
            "repo.ext_issues",
            "repo.wiki",
            "repo.ext_wiki",
            "repo.pulls",
            "repo.releases",
            "repo.projects",
            "repo.ext_wiki"
        )
        units_map                 = @{
            "repo.actions"    = "write"
            "repo.packages"   = "write"
            "repo.code"       = "write"
            "repo.issues"     = "write"
            "repo.ext_issues" = "none"
            "repo.wiki"       = "write"
            "repo.pulls"      = "write"
            "repo.releases"   = "write"
            "repo.projects"   = "write"
            "repo.ext_wiki"   = "none"
        }
    }
    @{
        name                      = "reporter"
        description               = "Reporters with read access and issue reporting capabilities"
        can_create_org_repo       = $false
        includes_all_repositories = $true
        permission                = "read"
        units                     = @(
            "repo.actions",
            "repo.code",
            "repo.issues",
            "repo.ext_issues",
            "repo.wiki",
            "repo.ext_wiki",
            "repo.pulls",
            "repo.releases",
            "repo.projects",
            "repo.ext_wiki"
        )
        units_map                 = @{
            "repo.actions"    = "none"
            "repo.packages"   = "none"
            "repo.code"       = "read"
            "repo.issues"     = "write"
            "repo.ext_issues" = "none"
            "repo.wiki"       = "read"
            "repo.pulls"      = "read"
            "repo.releases"   = "read"
            "repo.projects"   = "read"
            "repo.ext_wiki"   = "none"
        }
    }
)

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'TeamAssignments')]
$TeamAssignments = @{
    "Frontend" = @{
        "Owners"    = @("benji.coleman")
        "developer" = @("mezo.gyorgy", "toth.laci")
        "reporter"  = @("jungle.diff")
    }
    "Backend"  = @{
        "Owners"    = @("benji.coleman")
        "developer" = @("gabi.roli", "demeter.attila")
        "reporter"  = @("jungle.diff")
    }
}

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'Repositories')]
$Repositories = @(
    @{
        OrganizationUsername = "Frontend"
        Name                 = "Frontend-Repo"
        Description          = "Main repository for Frontend"
        Private              = $false
        AutoInit             = $true
        Gitignore            = "Node,VisualStudioCode,VisualStudio,JetBrains,Linux,macOS,Windows"
        License              = "MIT"
        Readme               = "Default"
    }
    @{
        OrganizationUsername = "Backend"
        Name                 = "Backend-Repo"
        Description          = "Main repository for Backend"
        Private              = $false
        AutoInit             = $true
        Gitignore            = "Node,VisualStudioCode,VisualStudio,JetBrains,Linux,macOS,Windows"
        License              = "MIT"
        Readme               = "Default"
    }
)
