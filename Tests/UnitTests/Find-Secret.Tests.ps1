Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

Describe 'Find-Secret' {
    Context 'Basic design tests' {
        It 'Should have non mandatory parameter <_>' -TestCases 'Path', 'OutputPreference', 'ConfigPath', 'Excludelist', 'Filetype' {
            Get-Command Find-Secret | Should -HaveParameter $_ -Because 'If parameters change behaviour we need to do a major bump'
        }
    }

    Context 'Functionality - streams' {
        BeforeAll {
            $TestFile = 'TestDrive:\TestFile.ps1'
    
            # Create a test file
            'pat1' | Out-File -FilePath $TestFile -Force
    
            # Mock for parameter validation. Tested in separate test file
            Mock -CommandName AssertParameter -ModuleName PSSecretScanner -MockWith {
                return $true
            }
            
            # Mock to always return one file to scan
            Mock -CommandName Get-ChildItem -ModuleName PSSecretScanner -MockWith {
                @{
                    FullName = $TestFile 
                    Extension = '.ps1'
                }
            } -ParameterFilter {$Path -and $File -and $Recurse}
            
            # Mock GetConfig - wrapper function to make Find-Secret testable
            Mock -CommandName GetConfig -ModuleName PSSecretScanner -MockWith {
                return '{"regexes":[{"_Pattern1":"pat1"},{"_Pattern2":"pat2"}],"fileextensions":[".ps1",".ps2"]}' | ConvertFrom-Json -AsHashtable
            }
        }
    
        It 'Given no outputpreference, should return one match to the error stream' {
            $Error.Clear()
            Find-Secret $TestFile -ErrorAction SilentlyContinue
            $Error.count | Should -Be 1
        }

        It 'Redirecting output to Output stream' {
            $r = Find-Secret $TestFile -OutputPreference Output
            $r.count | Should -Be 1
        }

        It 'Redirecting output to object' {
            $r = Find-Secret $TestFile -OutputPreference Object
            $r.count | Should -Be 1
        }
    }
}