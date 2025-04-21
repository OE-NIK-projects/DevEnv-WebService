. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1
. $PSScriptRoot/send-api-request.ps1

function Add-Organization {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Organization,
        
        [Parameter()]
        [string]$AdminUsername = $Admins[0].Username,
        
        [Parameter()]
        [string]$AdminPassword = $Admins[0].Password,
        
        [Parameter()]
        [string]$ApiBaseUrl = $Api.BaseUrl
    )
        
    try {
        $body = @{
            username                      = $Organization.Username
            description                   = $Organization.Description
            repo_admin_change_team_access = $Organization.Repo_admin_change_team_access
        }
            
        $uri = "$ApiBaseUrl/orgs"

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'response')]
        $response = Send-ApiRequest -Url $uri `
                                    -Method Post `
                                    -AdminUsername $AdminUsername `
                                    -AdminPassword $AdminPassword `
                                    -Body $body

        Write-Message -Message "Created organization: $($Organization.Username)" -Type Success
    }
    catch {
        Write-Message -Message "Failed to create organization: $($Organization.Username). Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting Gitea organization creation process..." -Type Info
$Organizations | ForEach-Object {
    Add-Organization -Organization $_
}
Write-Message -Message "Gitea organization creation process completed.`n" -Type Info
