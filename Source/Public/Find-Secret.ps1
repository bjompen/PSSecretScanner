function Find-Secret {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Path not found." })]
        [string[]]$Path = "$PWD",
        
        [Parameter(ParameterSetName = 'File', Position = 0)]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "File not found." })]
        [string]$File,

        [Parameter()]
        [ValidateSet('Output','Warning','Error','Object')]
        [string]$OutputPreference = 'Error',

        [Parameter()]
        [string]$ConfigPath = $script:PSSSConfigPath,

        [Parameter()]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Excludelist path not found." })]
        [string]$Excludelist,

        [Parameter(ParameterSetName = 'Path')]
        [string[]]$Filetype
    )

    $Config = GetConfig -ConfigPath $ConfigPath

    switch ($PSCmdLet.ParameterSetName) {
        'Path' { 
            if ( ($Path.Count -eq 1) -and ((Get-Item $Path[0]) -is [System.IO.FileInfo]) ) {
                [Array]$ScanFiles = Get-ChildItem $Path[0] -File 
            }
            else {
                if ($Filetype -and $Filetype.Contains('*')) {
                    [Array]$ScanFiles = Get-ChildItem $Path -File -Recurse
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
                    [Array]$ScanFiles = Get-ChildItem $Path -File -Recurse | Where-Object -Property Extension -in $ScanExtensions
                
                }
                else {
                    [Array]$ScanFiles = Get-ChildItem $Path -File -Recurse | Where-Object -Property Extension -in $Config['fileextensions']
                }
            }
         }
        'File' {
            [Array]$ScanFiles = Get-ChildItem $File -File 
        }
    }


    Write-Verbose "Scanning files:`n$($ScanFiles.FullName -join ""`n"")"

    $Res = $Config['regexes'].Keys | ForEach-Object {
        $RegexName = $_
        $Pattern = ($Config['regexes'])."$RegexName"

        Write-Verbose "Performing $RegexName scan`nPattern '$Pattern'`n"

        Get-Item $ScanFiles.FullName | Select-String -Pattern $Pattern
    }
    
    if (-not [string]::IsNullOrEmpty($Excludelist)) {
        [string[]]$Exclusions = GetExclusions $Excludelist
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
