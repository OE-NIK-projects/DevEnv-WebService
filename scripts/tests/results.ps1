function Write-Result {
	param([string] $File, [string] $Message, [bool] $Passed)
	@{
		'schemaVersion' = 1
		'label'         = ' '
		'message'       = $Passed ? 'Sikeres' : 'Sikertelen'
		'color'         = $Passed ? '#238636' : '#da3633'
		'style'         = 'flat-square'
	} | ConvertTo-Json | Out-File $File
}

function Write-Summary {
	param([string] $File, [int] $Passes, [int] $Count)
	@{
		'schemaVersion' = 1
		'label'         = 'Sikeres tesztek'
		'message'       = "$Passes / $Count"
		'color'         = $Passes -eq $Count ? '#238636' : '#da3633'
		'style'         = 'flat-square'
	} | ConvertTo-Json | Out-File $File
}

function Write-Timestamp {
	param([string] $File, [System.DateTimeOffset] $Timestamp = [System.DateTimeOffset]::Now)
	@{
		'schemaVersion' = 1
		'label'         = 'Futtatás időpontja'
		'message'       = $Timestamp.ToString([cultureinfo]::new("hu"))
		'color'         = '#9e6a03'
		'style'         = 'flat-square'
	} | ConvertTo-Json | Out-File $File
}
