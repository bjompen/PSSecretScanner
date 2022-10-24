function GetExclusions {
    param (
        $Excludelist
    )
    [string[]]$Exclusions = Get-Content $Excludelist | Where-Object {$_ -and $_ -notlike "#*"}

    [System.Collections.Generic.List[HashTable]]$ExcludeResults = @()

    foreach ($e in $Exclusions) {
        $eObj = ConvertFrom-Csv -InputObject $e -Delimiter ';' -Header 'Path', 'LineNumber', 'Line'

        if ($eObj.Path -match '^\..*') {
            # Path starts with '.', is relative. Replace with root folder
            $BasePath = split-path (Resolve-Path $Excludelist).Path 
            $eobj.Path = $eobj.Path -replace '^\.', $BasePath
        }

        if ([string]::IsNullOrEmpty($eObj.LineNumber) -and [string]::IsNullOrEmpty($eObj.Line)) {
            # Path or fileexclusion
            if ($eObj.Path -match '.*\\\*$') {
                # Full path excluded
                Get-ChildItem -Path $eObj.Path -Recurse -File | ForEach-Object { 
                    $ExcludeResults.Add(@{
                        StringValue = $_.FullName
                        Type = 'File'
                    })
                }
            }
            else {
                # Full filename excluded
                $ExcludeResults.Add(@{
                    StringValue = $eObj.Path
                    Type = 'File'
                })
            }
        }
        else {
            # File, line, and pattern excluded
            $ExcludeResults.Add(@{
                StringValue = "$($eObj.Path);$($eObj.LineNumber);$($eObj.Line)"
                Type = 'LinePattern'
            })
        }
    }

    $ExcludeResults
}