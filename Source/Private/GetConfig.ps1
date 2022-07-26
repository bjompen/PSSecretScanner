function GetConfig {
    param (
        $ConfigPath
    )
    
    try {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $Config = Get-Content $ConfigPath -ErrorAction Stop | ConvertFrom-Json -AsHashtable
        } 
        else {
            $Config = Get-Content $ConfigPath -ErrorAction Stop -Raw | ConvertFrom-Json | ConvertToHashtable
        }
    }
    catch {
        Throw "Failed to get config. $_"
    }

    $Config
}