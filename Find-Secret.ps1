function Find-Secret {
    [CmdletBinding()]
    param (
        [string[]]$Folder = "$PWD",

        [ValidateSet('Output','Warning','Error','Object')]
        [string]$OutputPreference = 'Error',

        [string[]]$ConfigPath = "$PSScriptRoot\config.json"
    )

    $Config = Get-Content $ConfigPath | ConvertFrom-Json -AsHashtable

    $ScanFiles = Get-ChildItem $Folder -File -Recurse | Where-Object -Property Extension -in $Config['fileextensions']
    Write-Verbose "Scanning files:`n$($ScanFiles.FullName -join ""`n"")"

    $Res = $Config['regexes'].Keys | ForEach-Object {
        $RegexName = $_
        $Pattern = ($Config['regexes'])."$RegexName"

        Write-Verbose "Performing $RegexName scan`nPattern '$Pattern'`n"

        Get-ChildItem $ScanFiles | Select-String -Pattern $Pattern
    }
    
    $Result = "Found $($Res.Count) strings.`n"

    if ($res.Count -gt 0) {
        $Result += "Path`tLine`tLineNumber`tPattern`n"
        foreach ($line in $res) {
            $Result += "$($line.Path)`t$($line.Line)`t$($line.LineNumber)`t$($line.Pattern)`n"
        }
    }

    switch ($OutputPreference) {
        'Output'   { Write-Output $Result }
        'Warning'       { Write-Warning $Result }
        'Error'         { Write-Error $Result }
        'Object'        { $res }
    }
}