function Write-Result {
	param([string] $File, [string] $Message, [bool] $Passed)
	@{
		'schemaVersion' = 1
		'label'         = $Message
		'message'       = $Passed ? 'Passed' : 'Failed'
		'color'         = $Passed ? 'green' : 'red'
	} | ConvertTo-Json | Out-File $File
}

function Write-Summary {
	param([string] $File, [int] $Passes, [int] $Count)
	@{
		'time'   = [datetime]::Now.ToString('yyyy.MM.dd. HH:mm')
		'passes' = $Passes
		'count'  = $Count
	} | ConvertTo-Json | Out-File $File
}
