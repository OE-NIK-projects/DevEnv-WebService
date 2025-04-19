. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

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
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $body = @{
            can_create_org_repo       = $Team.can_create_org_repo
            description               = $Team.description
            includes_all_repositories = $Team.includes_all_repositories
            name                      = $Team.name
            permission                = $Team.permission
            units                     = $Team.units
            units_map                 = $Team.units_map
        } | ConvertTo-Json -Depth 10

        $uri = "$ApiBaseUrl/orgs/$OrganizationUsername/teams"
        Write-Message -Message "Sending POST request to $uri with body:`n$body" -Type Command

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ErrorAction Stop

        Write-Message -Message "Successfully created team: $($Team.name) in organization: $OrganizationUsername" -Type Success
        $response | ConvertTo-Json -Depth 10 | ForEach-Object { Write-Message -Message $_ -Type Default }
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
                 -OrganizationUsername $orgUsername `
                 -Verbose
    }
}
Write-Message -Message "Gitea team creation process completed." -Type Info
