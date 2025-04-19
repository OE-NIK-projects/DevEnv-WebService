. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

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
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $body = @{
            username                      = $Organization.Username
            description                   = $Organization.Description
            repo_admin_change_team_access = $Organization.Repo_admin_change_team_access
        } | ConvertTo-Json

        $uri = "$ApiBaseUrl/orgs"
        Write-Message -Message "Sending POST request to $uri" -Type Command

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ErrorAction Stop

        Write-Message -Message "Successfully created organization: $($Organization.Username)" -Type Success
        $response | ConvertTo-Json
    }
    catch {
        Write-Message -Message "Failed to create organization: $($Organization.Username). Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting Gitea organization creation process..." -Type Info
$Organizations | ForEach-Object {
    Add-Organization -Organization $_ `
}
Write-Message -Message "Gitea organization creation process completed." -Type Info
