function Find-Secret {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Path not found." })]
        [string[]]$Path = "$PWD",

        [Parameter(ParameterSetName = 'Path')]
        [string[]]$Filetype,

        [Parameter(ParameterSetName = 'Path')]
        [bool]$Recursive = $true,
        
        [Parameter(ParameterSetName = 'File', Position = 0)]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "File not found." })]
        [string]$File,

        [Parameter()]
        [ValidateSet('Output','Warning','Error','Object','IgnoreSecrets')]
        [string]$OutputPreference = 'Error',

        [Parameter()]
        [string]$ConfigPath = $script:PSSSConfigPath,

        [Parameter()]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Excludelist path not found." })]
        [string]$Excludelist
    )

    $Config = GetConfig -ConfigPath $ConfigPath

    switch ($PSCmdLet.ParameterSetName) {
        'Path' { 
            if ( ($Path.Count -eq 1) -and ((Get-Item $Path[0]) -is [System.IO.FileInfo]) ) {
                [Array]$ScanFiles = Get-ChildItem $Path[0] -File 
            }
            else {
                if ($Filetype -and $Filetype.Contains('*')) {
                    [Array]$ScanFiles = Get-ChildItem $Path -File -Recurse:$Recursive
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
                    [Array]$ScanFiles = Get-ChildItem $Path -File -Recurse:$Recursive | Where-Object -Property Extension -in $ScanExtensions
                
                }
                else {
                    [Array]$ScanFiles = Get-ChildItem $Path -File -Recurse:$Recursive | Where-Object -Property Extension -in $Config['fileextensions']
                }
            }
         }
        'File' {
            [Array]$ScanFiles = Get-ChildItem $File -File 
        }
    }

    if ($ScanFiles.Count -ge 1) {
        Write-Verbose "Scanning files:`n$($ScanFiles.FullName -join ""`n"")"

        $scanStart = [DateTime]::Now

        $Res = 
            foreach ($key in $Config['regexes'].Keys) {         
                $RegexName = $key
                $Pattern = ($Config['regexes'])."$RegexName"

                Write-Verbose "Performing $RegexName scan`nPattern '$Pattern'`n"

                $ScanFiles | 
                    Select-String -Pattern $Pattern |
                    Add-Member NoteProperty PatternName (
                        $key -replace '_', ' ' -replace '^\s{0,}'
                    ) -Force -PassThru |
                    & { process {
                        $_.pstypenames.clear()
                        $_.pstypenames.add('PSSecretScanner.Result')
                        $_
                    } }
            }
        
        if (-not [string]::IsNullOrEmpty($Excludelist)) {
            [string[]]$Exclusions = GetExclusions $Excludelist
            Write-Verbose "Using excludelist $Excludelist. Found $($Exclusions.Count) exlude strings."

            $Res = $Res | Where-Object {
                "$($_.Path);$($_.LineNumber);$($_.Line)" -notin $Exclusions
            }
        }

        $scanEnd = [DateTime]::Now
        $scanTook = $scanEnd - $scanStart
        
        $Result = "Found $($Res.Count) strings.`n"

        $resultSet = 
            [Ordered]@{
                PSTypeName    = 'PSSecretScanner.ResultSet'
                Results       = $res
                ScanFiles     = $ScanFiles
                ScanStart     = $scanStart
                ScanTimespan  = $scanTook
                ScanEnd       = $scanEnd
            }

        $result = [PSCustomObject]$resultSet
        <#
        if ($res.Count -gt 0) {
            if ($OutputPreference -eq 'IgnoreSecrets') {
                $Result = [string]::Empty
                foreach ($line in $res) {
                    $Result += "$($line.Path);$($line.LineNumber);$($line.Line)`n"
                }
            }
            else {
                $Result += "Path`tLine`tLineNumber`tPattern`n"
                foreach ($line in $res) {
                    $Result += "$($line.Path)`t$($line.Line)`t$($line.LineNumber)`t$($line.Pattern)`n"
                }
            }
        }#>
    }
    else {
        $Result = 'Found no files to scan'
        $res = @()
    }
        switch ($OutputPreference) {
            'Output'  { $Result }
            'IgnoreSecrets'  { Write-Output $Result }
            'Warning' { Write-Warning ($Result | Out-String) }
            'Error'   { Write-Error ($Result | Out-String) }
            'Object'  { $res }
        }
}
