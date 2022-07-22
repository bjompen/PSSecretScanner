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

Describe 'Patterns that should be found' {
    BeforeEach {
        if (Test-Path TestDrive:\MatchFile.txt) {
            Remove-Item TestDrive:\MatchFile.txt
        }
    }
    Context 'Should find patterns' {
        It 'Should find pattern <_.Pattern>' -TestCases $ShouldFindPatterns {
            $_.Pattern | Out-File TestDrive:\MatchFile.txt
            $r = Find-Secret -Path TestDrive:\MatchFile.txt -OutputPreference Object
            $r.count | Should -Be 1
        }
    }
    Context 'Should not find patterns' {
        It 'Should not find pattern <_.Pattern>' -TestCases $ShouldNotFindPatterns {
            $_.Pattern | Out-File TestDrive:\MatchFile.txt
            $r = Find-Secret -Path TestDrive:\MatchFile.txt -OutputPreference Object
            $r.count | Should -Be 0
        }
    }
}