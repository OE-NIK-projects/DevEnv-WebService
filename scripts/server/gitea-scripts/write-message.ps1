function Write-Message {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('Info', 'Error', 'Command', 'Success', 'Warning', 'Default')]
        [string]$Type = 'Default'
    )

    $prefix = "[$Type]"
    $color = switch ($Type) {
        'Info' { 'Cyan' }
        'Error' { 'Red' }
        'Success' { 'Green' }
        'Command' { 'Magenta' }
        'Warning' { 'Yellow' }
        'Default' { 'White' }
    }

    if ($Type -eq 'Default') {
        Write-Host "$Message" -ForegroundColor White
    }
    else {
        Write-Host "$prefix $Message" -ForegroundColor $color
    }
}
