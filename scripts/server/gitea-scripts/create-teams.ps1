. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1
. $PSScriptRoot/send-api-request.ps1

function Add-Team {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Team,
        
        [Parameter(Mandatory = $true)]
        [string]$OrganizationUsername,
        
        [Parameter()]
        [string]$AdminUsername = $Admins[0].Username,
        
        [Parameter()]
        [string]$AdminPassword = $Admins[0].Password,

        [Parameter()]
        [string]$ApiBaseUrl = $Api.BaseUrl
    )

    try {
        $body = @{
            can_create_org_repo       = $Team.can_create_org_repo
            description               = $Team.description
            includes_all_repositories = $Team.includes_all_repositories
            name                      = $Team.name
            permission                = $Team.permission
            units                     = $Team.units
            units_map                 = $Team.units_map
        }

        $uri = "$ApiBaseUrl/orgs/$OrganizationUsername/teams"

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'response')]
        $response = Send-ApiRequest -Url $uri `
                                    -Method Post `
                                    -AdminUsername $AdminUsername `
                                    -AdminPassword $AdminPassword `
                                    -Body $body
                                    
        Write-Message -Message "Created team: $($Team.name) in organization: $OrganizationUsername" -Type Success
    }
    catch {
        Write-Message -Message "Failed to create team: $($Team.name) in organization: $OrganizationUsername. Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting Gitea team creation process..." -Type Info
$Organizations | ForEach-Object {
    $orgUsername = $_.Username
    $Teams | ForEach-Object {
        Add-Team -Team $_ `
                 -OrganizationUsername $orgUsername
    }
}
Write-Message -Message "Gitea team creation process completed.`n" -Type Info
