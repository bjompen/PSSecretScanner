---
external help file: PSSecretScanner-help.xml
Module Name: PSSecretScanner
online version:
schema: 2.0.0
---

# Find-Secret

## SYNOPSIS

Scans for secrets in one or more folders or files.

## SYNTAX

### Path (Default)

```
Find-Secret [[-Path] <String[]>] [-Filetype <String[]>] [-Recursive <Boolean>] [-OutputPreference <String>]
 [-ConfigPath <String>] [-Excludelist <String>] [<CommonParameters>]
```

### File

```
Find-Secret [[-File] <String>] [-OutputPreference <String>] [-ConfigPath <String>] [-Excludelist <String>]
 [<CommonParameters>]
```

## DESCRIPTION

This function scans for secrets accidently exposed in one or more folder(s) or file(s).
It requires the config.json file containing regexes and file extensions to scan.

You can select which output stream to use to make it behave the way you want to in a pipeline,
Or output the result to pipeline as an object to wrap it in your own script.

Excludelist can be used to ignore false positives
Exclusions must then be in the format
\<Full\path\to\file.txt\>;\<linenumber\>;\<Line\>
Ex.
    "C:\MyFiles\template.json;51;-----BEGIN RSA PRIVATE KEY-----"
    "C:\MyRepo\MyModule.psm1:18:password = supersecret!!"

## EXAMPLES

### EXAMPLE 1

```PowerShell
Find-Secret
```

This command will scan the current directory, $PWD, and all subfolders for secrets using the default config.json.

### EXAMPLE 2

```PowerShell
Find-Secret -Path c:\MyPowerShellFiles\, C:\MyBicepFiles\MyModule.bicep
```

This command will scan the c:\MyPowerShellFiles\ directory recursively and the C:\MyBicepFiles\MyModule.bicep for secrets using the default config.json.

### EXAMPLE 3

```PowerShell
Find-Secret -Path c:\MyPowerShellFiles\ -Recurse:$False
```

This command will scan only the c:\MyPowerShellFiles\ directory for secrets using the default config.json.
Any subfolders will be excluded from scan.

### EXAMPLE 4

```PowerShell
Find-Secret -Path c:\MyPowerShellFiles\ -OutputPrefence Output
```

This command will scan the c:\MyPowerShellFiles\ directory for secrets using the default config.json.
Output will be made to the default Output stream instead of Error.

### EXAMPLE 5

```PowerShell
Find-Secret -Path c:\MyPowerShellFiles\ -OutputPrefence Object
```

This command will scan the c:\MyPowerShellFiles\ directory recursively for secrets using the default config.json.
Instead of outputting a string of the result to any stream, It will output a Select-String object that you can use in your own pipelines.

### EXAMPLE 6

```PowerShell
Find-Secret -Path c:\MyPowerShellFiles\ -Filetype 'bicep','.json'
```

This command will scan the c:\MyPowerShellFiles\ directory recursively for secrets using the default config.json.
It will only scan files with the '.bicep' or '.json' extensions

### EXAMPLE 7

```PowerShell
Find-Secret -Path c:\MyPowerShellFiles\ -Filetype '*'
```

This command will scan the c:\MyPowerShellFiles\ directory recursively for secrets using the default config.json.
It will try to scan all filetypes in this folder including non clear text. This might be very slow.

### EXAMPLE 8

```PowerShell
Find-Secret -OutputPreference IgnoreSecrets | Out-File .\.ignoresecrets -Force
```

This command will scan the current directory, $PWD, and all subfolders for secrets using the default config.json.
It will output the result in the correct format for an ExcludeList, and output the result to a the .\.ignoresecrets file.
If this file exists _in a git root folder_ it will then be automatically read and used by Write-SecretStatus.

## PARAMETERS

### -ConfigPath

Path to the config.json file.
If you change this, make sure the format of the custom one is correct.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: "$PSScriptRoot\config.json"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Excludelist

Path to exclude list.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -File

This parameter should be used to scan single files.

In some cases using the -Path parameter for single file scans alongside extension patterns behaves unexpected.

```yaml
Type: String
Parameter Sets: File
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Filetype

Filetype(s) to scan.
If this parameter is set we will only scan files of type in thes list.
Use '*' to scan all filetypes.
(This will even try to scan non clear text files, and may be slow.)

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OutputPreference

Set the stream to output data to, or output the Select-String object to create your own handling.

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Output, Warning, Error, Object, IgnoreSecrets

Required: False
Position: Named
Default value: Error
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

The folders and files to scan.
Folders are recursively scanned.

```yaml
Type: String[]
Parameter Sets: Path
Aliases:

Required: False
Position: 0
Default value: "$PWD"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Recursive

This parameter can be set to $false to prevent recursive folder scans
*NOTE: Since this is a bool, set it by using `-Recursive:$false`

```yaml
Type: Boolean
Parameter Sets: Path
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
