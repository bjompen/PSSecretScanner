# OWASP test cases is in the format
# +pattern to search in>>should match
# fail - should be found by scanner
# pass - should not be found by scanner 

Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

$TestCasesFile = (Resolve-Path $PSScriptRoot\TestCases.json).Path
$TestCases = Get-Content $TestCasesFile | ConvertFrom-Json
$ShouldFindPatterns = $TestCases | Where-Object -Property ShouldMatch -EQ $True
$ShouldNotFindPatterns = $TestCases | Where-Object -Property ShouldMatch -EQ $False

Describe 'Pattern verification tests' {
    BeforeEach {
        if (Test-Path TestDrive:\MatchFile.txt) {
            Remove-Item TestDrive:\MatchFile.txt
        }
    }
    Context 'Should find patterns' -Tag 'match' {
        It 'Should find pattern <_.Pattern>' -TestCases $ShouldFindPatterns {
            $_.Pattern | Out-File TestDrive:\MatchFile.txt
            $r = Find-Secret -Path TestDrive:\MatchFile.txt
            $r.count | Should -BeGreaterOrEqual 1
        }
    }
    Context 'Should not find patterns' -Tag 'notmatch' {
        It 'Should not find pattern <_.Pattern>' -TestCases $ShouldNotFindPatterns {
            $_.Pattern | Out-File TestDrive:\MatchFile.txt
            $r = Find-Secret -Path TestDrive:\MatchFile.txt
            $r.count | Should -Be 0
        }
    }
}