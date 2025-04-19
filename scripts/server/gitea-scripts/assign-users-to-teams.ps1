. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Get-TeamId {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OrganizationUsername,

        [Parameter(Mandatory = $true)]
        [string]$TeamName,

        [Parameter(Mandatory = $true)]
        [string]$AdminUsername,

        [Parameter(Mandatory = $true)]
        [string]$AdminPassword,

        [Parameter()]
        [string]$ApiBaseUrl = $Api.BaseUrl
    )

    try {
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $uri = "$ApiBaseUrl/orgs/$OrganizationUsername/teams"
        Write-Message -Message "Fetching teams from $uri" -Type Command

        $teams = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers -ErrorAction Stop

        $team = $teams | Where-Object { $_.name -eq $TeamName }
        if ($team) {
            Write-Message -Message "Found team '$TeamName' in organization '$OrganizationUsername' with ID: $($team.id)" -Type Success
            return $team.id
        }
        else {
            Write-Message -Message "Team '$TeamName' not found in organization '$OrganizationUsername'." -Type Error
            return $null
        }
    }
    catch {
        Write-Message -Message "Failed to fetch teams for organization '$OrganizationUsername'. Error: $($_.Exception.Message)" -Type Error
        return $null
    }
}

function Add-UserToTeam {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [int]$TeamId,

        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [string]$AdminUsername,

        [Parameter(Mandatory = $true)]
        [string]$AdminPassword,

        [Parameter()]
        [string]$ApiBaseUrl = $Api.BaseUrl
    )

    try {
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $uri = "$ApiBaseUrl/teams/$TeamId/members/$Username"
        Write-Message -Message "Adding user '$Username' to team ID $TeamId via $uri" -Type Command

        $response = Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -ErrorAction Stop

        Write-Message -Message "Successfully added user '$Username' to team ID $TeamId" -Type Success
    }
    catch {
        Write-Message -Message "Failed to add user '$Username' to team ID $TeamId. Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting user assignment to teams process..." -Type Info

foreach ($org in $Organizations) {
    $orgUsername = $org.Username
    Write-Message -Message "Processing organization: $orgUsername" -Type Info

    foreach ($teamName in $TeamAssignments[$orgUsername].Keys) {
        $teamId = Get-TeamId -OrganizationUsername $orgUsername `
                             -TeamName $teamName `
                             -AdminUsername $Admins[0].Username `
                             -AdminPassword $Admins[0].Password `

        if ($null -eq $teamId) {
            Write-Message -Message "Skipping user assignment for team '$teamName' in '$orgUsername' due to missing team." -Type Error
            continue
        }

        # Assign users to the team
        $usersToAssign = $TeamAssignments[$orgUsername][$teamName]
        foreach ($username in $usersToAssign) {
            Add-UserToTeam -TeamId $teamId `
                           -Username $username `
                           -AdminUsername $Admins[0].Username `
                           -AdminPassword $Admins[0].Password `
        }
    }
}

Write-Message -Message "User assignment to teams process completed." -Type Info
