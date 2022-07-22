function Find-Secret {
    [CmdletBinding()]
    param (
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Path not found." })]
        [string[]]$Path = "$PWD",

        [ValidateSet('Output','Warning','Error','Object')]
        [string]$OutputPreference = 'Error',

        [string]$ConfigPath = $script:PSSSConfigPath,

        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Excludelist path not found." })]
        [string]$Excludelist,

        [string[]]$Filetype
    )

    try {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $Config = Get-Content $ConfigPath -ErrorAction Stop | ConvertFrom-Json -AsHashtable
        } else {
            $Config = Get-Content $ConfigPath -ErrorAction Stop -Raw | ConvertFrom-Json | ConvertToHashtable
        }
    }
    catch {
        Throw "Failed to get config. $_"
    }

    if ($Filetype -and $Filetype.Contains('*')) {
        $ScanFiles = Get-ChildItem $Path -File -Recurse
    }
    elseif ($Filetype) {
        $ScanExtensions = $Filetype | ForEach-Object {
            if (-not $_.StartsWith('.')) {
                ".$_"
            }
            else {
                $_
            }
        }
        $ScanFiles = Get-ChildItem $Path -File -Recurse | Where-Object -Property Extension -in $ScanExtensions
    
    }
    else {
        $ScanFiles = Get-ChildItem $Path -File -Recurse | Where-Object -Property Extension -in $Config['fileextensions']
    }

    Write-Verbose "Scanning files:`n$($ScanFiles.FullName -join ""`n"")"

    $Res = $Config['regexes'].Keys | ForEach-Object {
        $RegexName = $_
        $Pattern = ($Config['regexes'])."$RegexName"

        Write-Verbose "Performing $RegexName scan`nPattern '$Pattern'`n"

        Get-ChildItem $ScanFiles.FullName | Select-String -Pattern $Pattern
    }
    
    if (-not [string]::IsNullOrEmpty($Excludelist)) {
        [string[]]$Exclusions = Get-Content $Excludelist
        Write-Verbose "Using excludelist $Excludelist. Found $($Exclusions.Count) exlude strings."

        $Res = $Res | Where-Object {
            "$($_.Path);$($_.LineNumber);$($_.Line)" -notin $Exclusions
        }
    }
    
    $Result = "Found $($Res.Count) strings.`n"

    if ($res.Count -gt 0) {
        $Result += "Path`tLine`tLineNumber`tPattern`n"
        foreach ($line in $res) {
            $Result += "$($line.Path)`t$($line.Line)`t$($line.LineNumber)`t$($line.Pattern)`n"
        }
    }

    switch ($OutputPreference) {
        'Output'  { Write-Output $Result }
        'Warning' { Write-Warning $Result }
        'Error'   { Write-Error $Result }
        'Object'  { $res }
    }
}
