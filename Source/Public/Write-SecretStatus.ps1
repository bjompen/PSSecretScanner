function Write-SecretStatus {
    param (
        [switch]$Chatty
    )
    
    try {
        [array]$IsGit = (git status *>&1).ToString()
        if ( $IsGit[0] -eq 'fatal: not a git repository (or any of the parent directories): .git' ) {
            break
        }
        else {
            $SecretsCount = (Find-Secret -Recursive:$false -OutputPreference Object).Count
            Write-Output "[$SecretsCount]" 
        }
    }
    catch {}
}