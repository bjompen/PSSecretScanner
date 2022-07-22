---
external help file: PSSecretScanner-help.xml
Module Name: PSSecretScanner
online version:
schema: 2.0.0
---

# New-PSSSConfig

## SYNOPSIS
Creates a new copy of the PSSecretScanner config.json file for custom configurations.

## SYNTAX

```
New-PSSSConfig [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION
This function copies the current modules config.json to a path where you may customise it and include or exclude your own settings.

## EXAMPLES

### EXAMPLE 1
```
New-PSSSConfig -Path C:\MyPWSHRepo\MyCystomSecretScannerConfig.json
This command will copy the default config.json to C:\MyPWSHRepo\MyCystomSecretScannerConfig.json.
```

## PARAMETERS

### -Path
Path where the config.json will be copied to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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
