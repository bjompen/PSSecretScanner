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

It will automatically set the output to red if secrets are found.

If you have a file named `.ignoresecrets` in the rootfolder of your git repo it will use this for exclusions.

---

You _may_ also add this to your oh-my-posh thing, but I don't use it and have no idea how that works.

## EXAMPLES

### EXAMPLE 8

```PowerShell
$GitRoot = git rev-parse --show-toplevel
$IgnoreFile = Join-Path -Path  $GitRoot -ChildPath '.ignoresecrets'
Find-Secret -Path $GitRoot -OutputPreference IgnoreSecrets | Out-File $IgnoreFile -Force
```

This command will find the root folder of the current git repo,
and create a file called .ignoresecrets in it.
It will output _all_ secrets currently found in the repository in to that folder in the correct format for an ignore file.
It will then automatically pick this file up as IgnoreFile when running Write-SecretStatus.

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
