function GetExclusions {
    param (
        $Excludelist
    )
    [string[]]$Exclusions = Get-Content $Excludelist
    $Exclusions
}