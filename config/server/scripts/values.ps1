$Users = @(
    @{ Username = "admin"; Email = "admin@boilerplate.lan"; Password = "admin"; Admin = $true }
    @{ Username = "teszt.elek"; Email = "teszt.elek@boilerplate.lan"; Password = "Password1!"; Admin = $false }
    @{ Username = "mezo.gyorgy"; Email = "mezo.gyorgy@boilerplate.lan"; Password = "Password1!"; Admin = $false }
    @{ Username = "toth.laci"; Email = "toth.laci@boilerplate.lan"; Password = "Password1!"; Admin = $false }
    @{ Username = "gabi.roli"; Email = "gabi.roli@boilerplate.lan"; Password = "Password1!"; Admin = $false }
    @{ Username = "xanax.enjoyer"; Email = "xanax.enjoyer@boilerplate.lan"; Password = "Password1!"; Admin = $false }
    @{ Username = "jungle.diff"; Email = "jungle.diff@boilerplate.lan"; Password = "Password1!"; Admin = $false }
)

$Organization = @{
    Username                      = "Boilerplate";
    Description                   = "Innovatív, Clean Code elveit betartó Java gyűlölő cég.";
    Full_name                     = "Boilerplate Kft.";
    Email                         = "boilerplate@boilerplate.lan";
    Location                      = "Budapest";
    Repo_admin_change_team_access = $true;
    Visibility                    = "public";
    #TODO: Create DNS, Nginx with SSL
    #Website                       = "https://server.lan"
}

$TimeoutInSeconds = 5
