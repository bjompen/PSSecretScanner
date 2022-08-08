function Write-SecretStatus {
    param ()
    
    try {
        [array]$IsGit = (git status *>&1).ToString()
        if ( $IsGit[0] -eq 'fatal: not a git repository (or any of the parent directories): .git' ) {
            break
        }
        else {
            $FindSplat = @{
                Recursive = $false
                OutputPreference = 'Object'
            }

            $ExcludePath = Join-Path -Path  (git rev-parse --show-toplevel) -ChildPath '.ignoresecrets'
            if (Test-Path $ExcludePath) {
                $FindSplat.Add('Excludelist',$ExcludePath)
            }

            $Secrets = Find-Secret @FindSplat
            $SecretsCount = $Secrets.Count

            if ((Get-Command Prompt).ModuleName -eq 'posh-git') {
                if ($SecretsCount -ge 1) {
                    $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = 'Red'
                }
                else {
                    $GitPromptSettings.DefaultPromptBeforeSuffix.ForegroundColor = 'LightBlue'
                }
            }
            
            Write-Output "[$SecretsCount]" 
        }
    }
    catch {}
}