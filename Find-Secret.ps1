<#
.SYNOPSIS
    Scans for secrets in one or more folders or files.
.DESCRIPTION
    This function scans for secrets accidently exposed in one or more folder(s) or file(s).
    It requires the config.json file containing regexes and file extensions to scan.

    You can select which oputput stream to use to make it behave the way you want to in a pipeline,
    Or output the result to pipeline as an object to wrap it in your own script.
.EXAMPLE
    PS C:\> Find-Secrets
    This command will scan the current directory, $PWD, for secrets using the default config.json.
.EXAMPLE
    PS C:\> Find-Secret -Path c:\MyPowerShellFiles\, C:\MyBicepFiles\MyModule.bicep
    This command will scan the c:\MyPowerShellFiles\ directory and the C:\MyBicepFiles\MyModule.bicep for secrets using the default config.json.
.EXAMPLE
    PS C:\> Find-Secret -Path c:\MyPowerShellFiles\ -OutputPrefence Output
    This command will scan the c:\MyPowerShellFiles\ directory for secrets using the default config.json.
    Output will be made to the default Output stream instead of Error.
.EXAMPLE
    PS C:\> Find-Secret -Path c:\MyPowerShellFiles\ -OutputPrefence Object
    This command will scan the c:\MyPowerShellFiles\ directory for secrets using the default config.json.
    Instead of outputting a string of the result to any stream, It will output a Select-String object that you can use in your own pipelines.
#>
function Find-Secret {
    [CmdletBinding()]
    param (
        # The folders and files to scan. Folders are recursively scanned.
        [ValidateScript({Test-Path $_}, ErrorMessage = "Path not found.")]
        [string[]]$Path = "$PWD",

        # Set the stream to output data to, or output the Select-String object to create your own handling.
        [ValidateSet('Output','Warning','Error','Object')]
        [string]$OutputPreference = 'Error',

        # Path to the config.json file. If you change this, make sure the format of the custom one is correct.
        [string[]]$ConfigPath = ".\config.json"
    )

    try {
        $Config = Get-Content $ConfigPath | ConvertFrom-Json -AsHashtable
    }
    catch {
        Throw "Failed to get config. Is the format correct? $_"
    }
    $ScanFiles = Get-ChildItem $Path -File -Recurse | Where-Object -Property Extension -in $Config['fileextensions']
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
        'Output'  { Write-Output $Result }
        'Warning' { Write-Warning $Result }
        'Error'   { Write-Error $Result }
        'Object'  { $res }
    }
}