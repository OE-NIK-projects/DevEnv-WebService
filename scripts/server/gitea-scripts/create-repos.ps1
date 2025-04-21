. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1
. $PSScriptRoot/send-api-request.ps1

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
        [bool]$Private = $false,

        [Parameter()]
        [bool]$AutoInit = $false,

        [Parameter()]
        [string]$Gitignore = "",

        [Parameter()]
        [string]$Readme = ""
    )

    try {
        $body = @{
            name           = $RepoName
            description    = $Description
            private        = $Private
            default_branch = "main"
            auto_init      = $AutoInit
        }

        if ($Gitignore) {
            $body["gitignores"] = $Gitignore
        }
        if ($Readme) {
            $body["readme"] = $Readme
        }

        $uri = "$ApiBaseUrl/orgs/$OrganizationUsername/repos"

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'response')]
        $response = Send-ApiRequest -Url $uri `
                                    -Method Post `
                                    -AdminUsername $AdminUsername `
                                    -AdminPassword $AdminPassword `
                                    -Body $body

        Write-Message -Message "Created repository '$RepoName' in organization '$OrganizationUsername'" -Type Success
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
    $autoInit = $repo.AutoInit
    $gitignore = $repo.Gitignore
    $readme = $repo.Readme

    Write-Message -Message "Creating repository '$repoName' for organization: $orgUsername" -Type Info

    Add-Repository -OrganizationUsername $orgUsername `
                   -RepoName $repoName `
                   -AdminUsername $Admins[0].Username `
                   -AdminPassword $Admins[0].Password `
                   -Description $description `
                   -Private $private `
                   -AutoInit $autoInit `
                   -Gitignore $gitignore `
                   -Readme $readme `
}

Write-Message -Message "Repository creation process completed.`n" -Type Info
