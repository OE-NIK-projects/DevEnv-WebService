. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1
. $PSScriptRoot/send-api-request.ps1

function Add-GiteaUser {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'Password')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$FullName,

        [Parameter(Mandatory = $true)]
        [string]$Username,

        [Parameter(Mandatory = $true)]
        [string]$Email,

        [Parameter(Mandatory = $true)]
        [string]$Password,

        [Parameter()]
        [string]$ApiBaseUrl = $Api.BaseUrl,

        [Parameter()]
        [string]$AdminUsername = $Admins[0].Username,

        [Parameter()]
        [string]$AdminPassword = $Admins[0].Password
    )

    try {
        $body = @{
            username             = $Username
            email                = $Email
            password             = $Password
            full_name            = $FullName
            must_change_password = $false
        }

        $uri = "$ApiBaseUrl/admin/users"

        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'response')]
        $response = Send-ApiRequest -Url $uri `
                                    -Method Post `
                                    -AdminUsername $AdminUsername `
                                    -AdminPassword $AdminPassword `
                                    -Body $body

        Write-Message -Message "Created user: $Username ($Email)" -Type Success
    }
    catch {
        Write-Message -Message "Failed to create user: $Username. Error: $($_.Exception.Message)" -Type Error
    }
}

Write-Message -Message "Starting Gitea user creation process in $($TimeoutInSeconds)s..." -Type Info
Start-Sleep -Seconds $TimeoutInSeconds

$Users | ForEach-Object {
    Add-GiteaUser -FullName $_.Full_Name `
                  -Username $_.Username `
                  -Email $_.Email `
                  -Password $_.Password
}
Write-Message -Message "Gitea user creation process completed.`n" -Type Info
