. $PSScriptRoot/write-message.ps1

function Send-ApiRequest {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', 'AdminPassword')]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Url,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Get", "Post", "Put", "Delete")]
        [string]$Method,

        [Parameter(Mandatory = $true)]
        [string]$AdminUsername,

        [Parameter(Mandatory = $true)]
        [string]$AdminPassword,

        [Parameter()]
        [object]$Body = $null
    )

    try {
        $base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($AdminUsername):$($AdminPassword)"))
        
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add("Content-Type", "application/json")
        $headers.Add("Authorization", "Basic $base64Auth")

        $bodyJson = if ($Body) { $Body | ConvertTo-Json -Depth 10 } else { $null }

        Write-Message -Message "Sending $Method request to $Url" -Type Command
        if ($bodyJson) {
            Write-Message -Message "Request body:`n$bodyJson" -Type Command
        }

        $response = Invoke-RestMethod -Uri $Url -Method $Method -Headers $headers -Body $bodyJson -ErrorAction Stop

        Write-Message -Message "Request to $Url succeeded" -Type Success
        return $response
    }
    catch {
        Write-Message -Message "Request to $Url failed. Error: $($_.Exception.Message)" -Type Error
        throw
    }
}
