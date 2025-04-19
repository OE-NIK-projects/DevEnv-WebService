. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

function Add-Repository {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$OrganizationUsername,

        [Parameter(Mandatory = $true)]
        [string]$RepoName,

        [Parameter(Mandatory = $true)]
        [string]$AdminUsername,

        [Parameter(Mandatory = $true)]
        [string]$AdminPassword,

        [Parameter()]
        [string]$ApiBaseUrl = $Api.BaseUrl,

        [Parameter()]
        [string]$Description = "Main repository for $OrganizationUsername",

        [Parameter()]
        [bool]$Private = $false
    )

    try {
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $body = @{
            name           = $RepoName
            description    = $Description
            private        = $Private
            default_branch = "main"
            auto_init      = $repo.AutoInit
            gitignores     = $repo.Gitignore
            license        = $repo.License
            readme         = $repo.Readme
        } | ConvertTo-Json

        $uri = "$ApiBaseUrl/orgs/$OrganizationUsername/repos"
        Write-Message -Message "Sending POST request to $uri" -Type Command

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ErrorAction Stop

        Write-Message -Message "Successfully created repository '$RepoName' in organization '$OrganizationUsername'" -Type Success
    }
    catch {
        Write-Message -Message "Failed to create repository '$RepoName' in organization '$OrganizationUsername'. Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting repository creation process..." -Type Info

foreach ($repo in $Repositories) {
    $orgUsername = $repo.OrganizationUsername
    $repoName = $repo.Name
    $description = $repo.Description
    $private = $repo.Private

    Write-Message -Message "Creating repository '$repoName' for organization: $orgUsername" -Type Info

    Add-Repository -OrganizationUsername $orgUsername `
        -RepoName $repoName `
        -AdminUsername $Admins[0].Username `
        -AdminPassword $Admins[0].Password `
        -Description $description `
        -Private $private `

}

Write-Message -Message "Repository creation process completed." -Type Info