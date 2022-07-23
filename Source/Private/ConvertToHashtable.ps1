function ConvertToHashtable {
    <#
    .SYNOPSIS
        Converts PowerShell object to hashtable

    .DESCRIPTION
        Converts PowerShell objects, including nested objets, arrays etc. to a hashtable

    .PARAMETER InputObject
        The object that you want to convert to a hashtable

    .EXAMPLE
        Get-Content -Raw -Path C:\Path\To\file.json | ConvertFrom-Json | ConvertTo-Hashtable

    .NOTES
        Based on function by Dave Wyatt found on Stack Overflow
        https://stackoverflow.com/questions/3740128/pscustomobject-to-hashtable
    #>
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($object in $InputObject) { ConvertToHashtable -InputObject $object }
            )

            Write-Output -NoEnumerate $collection
        } elseif ($InputObject -is [psobject]) {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertToHashtable -InputObject $property.Value
            }

            $hash
        } else {
            $InputObject
        }
    }
}
