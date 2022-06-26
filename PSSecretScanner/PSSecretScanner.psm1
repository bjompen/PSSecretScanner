function Find-Secret {
    <#
    .SYNOPSIS
        Scans for secrets in one or more folders or files.
    .DESCRIPTION
        This function scans for secrets accidently exposed in one or more folder(s) or file(s).
        It requires the config.json file containing regexes and file extensions to scan.

        You can select which output stream to use to make it behave the way you want to in a pipeline,
        Or output the result to pipeline as an object to wrap it in your own script.

        Excludelist can be used to ignore false positives
        Exclusions must then be in the format
        <Full\path\to\file.txt>;<linenumber>;<Line>
        Ex. 
            "C:\MyFiles\template.json;51;-----BEGIN RSA PRIVATE KEY-----"
            "C:\MyRepo\MyModule.psm1:18:password = supersecret!!"
    .EXAMPLE
        PS C:\> Find-Secret
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
    .EXAMPLE
        PS C:\> Find-Secret -Path c:\MyPowerShellFiles\ -Filetype 'bicep','.json'
        This command will scan the c:\MyPowerShellFiles\ directory for secrets using the default config.json.
        It will only scan files with the '.bicep' or '.json' extensions
    .EXAMPLE
        PS C:\> Find-Secret -Path c:\MyPowerShellFiles\ -Filetype '*'
        This command will scan the c:\MyPowerShellFiles\ directory for secrets using the default config.json.
        It will try to scan all filetypes in this folder including non clear text. This might be very slow.
    #>
    [CmdletBinding()]
    param (
        # The folders and files to scan. Folders are recursively scanned.
        [ValidateScript({Test-Path $_}, ErrorMessage = "Path not found.")]
        [string[]]$Path = "$PWD",

        # Set the stream to output data to, or output the Select-String object to create your own handling.
        [ValidateSet('Output','Warning','Error','Object')]
        [string]$OutputPreference = 'Error',

        # Path to the config.json file. If you change this, make sure the format of the custom one is correct.
        [string]$ConfigPath = "$PSScriptRoot\config.json",

        # Path to exclude list. 
        [ValidateScript({Test-Path $_}, ErrorMessage = "Excludelist path not found.")]
        [string]$Excludelist,

        # Filetype(s) to scan. If this parameter is set we will only scan files of type in thes list. Use '*' to scan all filetypes. (This will even try to scan non clear text files, and may be slow.) 
        [string[]]$Filetype
    )

    try {
        $Config = Get-Content $ConfigPath -ErrorAction Stop | ConvertFrom-Json -AsHashtable
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

        Get-ChildItem $ScanFiles | Select-String -Pattern $Pattern
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

function New-PSSSConfig {
    <#
    .SYNOPSIS
        Creates a new copy of the PSSecretScanner config.json file for custom configurations.
    .DESCRIPTION
        This function copies the current modules config.json to a path where you may customise it and include or exclude your own settings. 
    .EXAMPLE
        PS C:\> New-PSSSConfig -Path C:\MyPWSHRepo\MyCystomSecretScannerConfig.json
        This command will copy the default config.json to C:\MyPWSHRepo\MyCystomSecretScannerConfig.json.
    #>
    param (
        [Parameter(Mandatory)]
        [ValidateScript({-not (Test-Path $_)}, ErrorMessage = "File already exists.")]
        [string]$Path
    )

    Copy-Item $PSScriptRoot\config.json -Destination $Path   
}
