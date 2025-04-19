. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Add-Organization {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Organization,
        
        [Parameter(Mandatory = $true)]
        [string]$AdminUsername,
        
        [Parameter(Mandatory = $true)]
        [string]$AdminPassword,

        [Parameter()]
        [string]$ApiBaseUrl = "http://localhost:3000/api/v1"
    )

    try {
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $body = @{
            username                      = $Organization.Username
            description                   = $Organization.Description
            full_name                     = $Organization.Full_name
            location                      = $Organization.Location
            repo_admin_change_team_access = $Organization.Repo_admin_change_team_access
            visibility                    = $Organization.Visibility
            #TODO: Create DNS, Nginx with SSL
            #website                       = $Organization.Website
        } | ConvertTo-Json

        $uri = "$ApiBaseUrl/orgs"
        Write-Message -Message "Sending POST request to $uri with body:`n$body" -Type Command

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ErrorAction Stop

        Write-Message -Message "Successfully created organization: $($Organization.Username)" -Type Success
        $response | ConvertTo-Json | ForEach-Object { Write-Message -Message $_ -Type Default }
    }
    catch {
        Write-Message -Message "Failed to create organization: $($Organization.Username). Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting Gitea organization creation process..." -Type Info
Add-Organization -Organization $Organization `
                -AdminUsername $Users[0].Username `
                -AdminPassword $Users[0].Password `
                -Verbose
Write-Message -Message "Gitea organization creation process completed." -Type Info
