![PSSecretScanner logo goes here](./images/PSSecretScanner.png)

# PSSecretScanner

Super simple passwordscanner built using PowerShell.

Scan your code, files, folders, and repos for accidentily exposed secrets using PowerShell.

## Features

- Give a list of files to scan and we will check for any pattern matches in those files.

- Outputs the result and metadata. (Use [Get-Member](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-member?view=powershell-7.2) to get all scan data)

![Example output](./images/output.png)

- Use an excludelist to prevent false positives, or if you _really_ want to include secrets in your code, by creating a exclude file and passing it to the `-Excludelist` parameter. Either be specific and include File, LineNumber, Pattern, _or_ use wildcards to exclude entire files or folders.

```Text
# Comments supported

# Relative paths supported (starting with .\)
# NOTE! Relative paths are calculated _relative to the excludelist path.
# If this file is located in c:\mypath\.ignoresecrets
.\Docs\Help\Find-Secret.md
.\Source\config.json
# The resolved exclude paths will be c:\mypath\Docs\Help\Find-Secret.md and c:\mypath\Source\config.json

# Wildcards supported. All files within this and subfolders will be excluded.
.\bin\*

# Paths to files. All matches in these files will be excluded
.\Tests\RegexPatternTests\TestCases.json
C:\MyRepo\PSSecretScanner\README.md

# Patterns on specific lines supported in the format
# <path\to\file>;<line number>;<pattern>
.\ExcludeList.csv;1;"C:\BicepLab\template.json;51;-----BEGIN RSA PRIVATE KEY-----"
C:\MyRepo\PSSecretScanner\Docs\Help\Find-Secret.md;51;"C:\MyFiles\template.json;51;-----BEGIN RSA PRIVATE KEY-----"
```

To have `Write-SecretStatus` automatically pick up and use your ignore list for all your repo, name your excludelist `.ignoresecrets` and put it in your repo root folder!

## Installation

- From the PSGallery, run `Install-Module PSSecretScanner`

- Clone this repo, and run `Invoke-Build` to build the module localy.

## Background

I couldn't find a proper secret scanner for PowerShell so I wrote my own.

From the beginning it was just a list of regex patterns stolen from the [OWASP SEDATED security scanner repo](https://github.com/OWASP/SEDATED) that I ran through `Select-String`, as I thought the OWASP tools was way to advanced for my needs, and way to hard to wrap in a powershell script.
From there it kind of grew, and hopefully it will grow even more.

## About Regex patterns

- The baseline is the list found at the OWASP repo, but converted to PowerShell Regex standard (PCRE I think it's called..)
- Added `_Azure_AccountKey` pattern found at [Detect-secrets from YELP](https://github.com/Yelp/detect-secrets)
- Added patterns from [h33tlit](https://github.com/h33tlit/secret-regex-list#readme) (thank you [Simon Wåhlin](https://github.com/SimonWahlin/) for telling me)

_The added underscore `_` to names in the pattern list is simply to make them easier to work with in PowerShell._

## Features to add

Yes, even keeping it simple there are stuff I might want to add some day, or if you want to, feel free to create a PR.

- Parallelization - make it faster on huge repos.
- More filetypes! I kind of just winged it for now.
