---
external help file: PSSecretScanner-help.xml
Module Name: PSSecretScanner
online version:
schema: 2.0.0
---

# Write-SecretStatus

## SYNOPSIS

This command is created to get a quick and easy way of having secrets found shown in your prompt function.
You can use it side by side with [posh-git](https://github.com/dahlbyk/posh-git), or as a stand alone function.

## SYNTAX

```PowerShell
Write-SecretStatus
```

## DESCRIPTION

This command is created to get a quick and easy way of having secrets found shown in your prompt function.
You can use it side by side with [posh-git](https://github.com/dahlbyk/posh-git), or as a stand alone function.

---

To add output to your default prompt, create or edit your prompt function and add `Write-SecretStatus` where you want it to show.

---

To add this to your posh-git prompt add the following to your `$PROFILE` script **after the `Import-Module posh-git` statement!**

$GitPromptSettings.DefaultPromptBeforeSuffix.Text = ' $(Write-SecretStatus)'

You may also change the default white console output colour by running 
$GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = 'LightBlue' # or any other colour of choice..

---

You _may_ also add this to your oh-my-posh thing, but I don't use it and have no idea how that works.

## EXAMPLES

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
