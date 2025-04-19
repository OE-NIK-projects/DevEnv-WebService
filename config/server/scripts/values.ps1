$TimeoutInSeconds = 2

$Users = @(
    @{ 
        Username = "admin"; 
        Email    = "admin@boilerplate.lan"; 
        Password = "admin"; 
        Admin    = $true; 
    },
    @{ 
        Username = "teszt.elek"; 
        Email    = "teszt.elek@boilerplate.lan"; 
        Password = "Password1!"; 
        Admin    = $false; 
    },
    @{ 
        Username = "mezo.gyorgy"; 
        Email    = "mezo.gyorgy@boilerplate.lan"; 
        Password = "Password1!"; 
        Admin    = $false; 
    },
    @{ 
        Username = "toth.laci"; 
        Email    = "toth.laci@boilerplate.lan"; 
        Password = "Password1!"; 
        Admin    = $false; 
    },
    @{ 
        Username = "gabi.roli"; 
        Email    = "gabi.roli@boilerplate.lan"; 
        Password = "Password1!"; 
        Admin    = $false; 
    },
    @{
        Username = "xanax.enjoyer"; 
        Email    = "xanax.enjoyer@boilerplate.lan"; 
        Password = "Password1!"; 
        Admin    = $false; 
    },
    @{ 
        Username = "jungle.diff"; 
        Email    = "jungle.diff@boilerplate.lan"; 
        Password = "Password1!"; 
        Admin    = $false; 
    }
)

#Groups
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
