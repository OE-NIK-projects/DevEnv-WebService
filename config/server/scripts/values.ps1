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

