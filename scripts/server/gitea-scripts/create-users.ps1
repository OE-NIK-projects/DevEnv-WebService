. $PSScriptRoot/write-message.ps1
. $PSScriptRoot/values.ps1

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
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $body = @{
            username             = $Username
            email                = $Email
            password             = $Password
            full_name            = $FullName
            must_change_password = $true
        } | ConvertTo-Json

        $uri = "$ApiBaseUrl/admin/users"
        Write-Message -Message "Sending POST request to $uri with body:`n$body" -Type Command

        $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -ErrorAction Stop

        Write-Message -Message "Successfully created user: $Username ($Email)" -Type Success
        $response | ConvertTo-Json | ForEach-Object { Write-Message -Message $_ -Type Default }
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
        -Password $_.Password `
        -Verbose
}
Write-Message -Message "Gitea user creation process completed." -Type Info
