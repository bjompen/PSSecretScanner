# PSSecretScanner
Scan your repos for accidentily exposed secrets using PowerShell

Super simple passwordscanner built using PowerShell.

The Regex patterns are stolen from [OWASP SEDATED security scanner repo](https://github.com/OWASP/SEDATED) and changed for PowerShell (PCRE? I think so) usage.

Give a list of files to scan and we will check for any pattern matches in those files.

Select output depending on how you want this to behave in f.ex a pipeline, console, or wrap it in a script to create your own handling.

## Why not use OWASP instead then? The original!

Well.. It's super awesome, has loads of features, and works really good.

It's also super advanced, has lots of features, and can't easily be wrapped in a PowerShell script.

## Regex changes from the OWASP list

- Added `_Azure_AccountKey` pattern found at [Detect-secrets from YELP](https://github.com/Yelp/detect-secrets)
- Added underscore `_` to names to make them easier to work with in PowerShell.

## Features to add

Yes, even keeping it simple there are stuff I might want to add some day, or if you want to, feel free to create a PR.

- Exclude lists (Not sure how I would want this to look though.. pattern - File - something else..)
- Error handling.
- Help docs? There really isn't much to write in them right now though, but yeah, we should follow best practices
- More filetypes! I kind of just winged it for now.
- Steal and recreate [testcases from the OWASP page](https://github.com/OWASP/SEDATED/tree/master/testing/regex_testing) to make sure the regexes work as expected!
