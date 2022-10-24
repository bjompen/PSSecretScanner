function Find-Secret {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        [Parameter(ParameterSetName = 'Path', Position = 0)]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Path not found." })]
        [string[]]$Path = "$PWD",

        [Parameter(ParameterSetName = 'Path')]
        [string[]]$Filetype,

        [Parameter(ParameterSetName = 'Path')]
        [switch]$NoRecurse,
        
        [Parameter(ParameterSetName = 'File', Position = 0)]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "File not found." })]
        [string]$File,
        
        [Parameter()]
        [string]$ConfigPath = $script:PSSSConfigPath,

        [Parameter()]
        [ValidateScript({ AssertParameter -ScriptBlock {Test-Path $_} -ErrorMessage "Excludelist path not found." })]
        [string]$Excludelist
    )

    $Config = GetConfig -ConfigPath $ConfigPath

    [bool]$Recursive = -not $NoRecurse

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

    if (-not [string]::IsNullOrEmpty($Excludelist)) {
        # Remove the excludelist from scanfiles. Otherwise patternmatches will be found here...
        $ScanFiles = $ScanFiles.Where({
            $_.FullName -ne (Resolve-Path $Excludelist).Path 
        })

        $Exclusions = GetExclusions $Excludelist
        $FileExclusions = $Exclusions.Where({$_.Type -eq 'File'}).StringValue
        $LinePatternExclusions = $Exclusions.Where({$_.Type -eq 'LinePattern'}).StringValue
        Write-Verbose "Using excludelist $Excludelist. Found $($Exclusions.Count) exlude strings."

        if ($FileExclusions.count -ge 1) {
            Write-Verbose "Excluding files from scan:`n$($FileExclusions -join ""`n"")"
            $ScanFiles = $ScanFiles.Where({
                $_.FullName -notin $FileExclusions
            })
        }
    }

    $scanStart = [DateTime]::Now

    if ($ScanFiles.Count -ge 1) {
        Write-Verbose "Scanning files:`n$($ScanFiles.FullName -join ""`n"")"

        $Res = foreach ($key in $Config['regexes'].Keys) {         
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
            if ($LinePatternExclusions.count -ge 1) {
                $Res = $Res | Where-Object {
                    "$($_.Path);$($_.LineNumber);$($_.Line)" -notin $LinePatternExclusions
                }
            }
        }

        $resultSet = [Ordered]@{
            Results       = $res
            ScanFiles     = $ScanFiles
            ScanStart     = $scanStart
        }
    }
    else {
        $resultSet = [Ordered]@{
            Results       = @()
            ScanFiles     = @()
            ScanStart     = $scanStart
        }
    }
    
    
    $scanEnd = [DateTime]::Now
    $scanTook = $scanEnd - $scanStart

    $resultSet.Add('PSTypeName','PSSecretScanner.ResultSet')
    $resultSet.Add('ScanEnd', $scanEnd)
    $resultSet.Add('ScanTimespan', $scanTook)
    
    $result = [PSCustomObject]$resultSet
    
    $Result
}
