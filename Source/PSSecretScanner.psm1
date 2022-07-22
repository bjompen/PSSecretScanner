# Set config path
$script:PSSSConfigPath = "$PSScriptRoot\config.json"

# import private functions
foreach ($file in (Get-ChildItem "$PSScriptRoot\Private\*.ps1"))
{
	try {
		Write-Verbose "Importing $($file.FullName)"
		. $file.FullName
	}
	catch {
		Write-Error "Failed to import '$($file.FullName)'. $_"
	}
}

# import public functions
foreach ($file in (Get-ChildItem "$PSScriptRoot\Public\*.ps1"))
{
	try {
		Write-Verbose "Importing $($file.FullName)"
		. $file.FullName
	}
	catch {
		Write-Error "Failed to import '$($file.FullName)'. $_"
	}
}

