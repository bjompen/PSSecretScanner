#Requires -Version 7

Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

Describe 'Find-Secret' {
    Context 'Basic design tests' {
        It 'Should have non mandatory parameter <_>' -TestCases 'Path', 'OutputPreference', 'ConfigPath', 'Excludelist', 'Filetype', 'File' {
            Get-Command Find-Secret | Should -HaveParameter $_ -Because 'If parameters change behaviour we need to do a major bump'
        }

        It 'Path should be the default parameterset' {
            $r = (Get-Command Find-Secret).ParameterSets.Where({$_.IsDefault})
            $r.Name | Should -Be 'Path'
        }
    }

    Context 'Functionality - streams' {
        BeforeAll {
            $TestFile = 'TestDrive:\TestFile.ps1'
            $ScanFolder = Split-Path $TestFile
    
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
            Find-Secret $ScanFolder -ErrorAction SilentlyContinue
            $Error.count | Should -Be 1
        }

        It 'Redirecting output to Output stream' {
            $r = Find-Secret $ScanFolder -OutputPreference Output
            $r.count | Should -Be 1
        }

        It 'Redirecting output to object' {
            $r = Find-Secret $ScanFolder -OutputPreference Object
            $r.count | Should -Be 1
        }
    
    }

    Context 'Functionality - Exclusion list' {
        BeforeAll {
            $TestFile = 'TestDrive:\TestFile.ps1'
            $ScanFolder = Split-Path $TestFile
    
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

        It 'If an exclusion list is given it should excluse matches - zero results' {
            Mock -CommandName GetExclusions -ModuleName PSSecretScanner -MockWith {
                return "$((resolve-path TestDrive:\TestFile.ps1).ProviderPath);1;pat1"
            }
            $r = Find-Secret $ScanFolder -OutputPreference Object -Excludelist 'TestDrive:\TestFile.ps1'
            $r.count | Should -Be 0
        }

        It 'If an exclusion list is given it should excluse matches - one result' {
            "pat1`npat2" | Out-File -FilePath $TestFile -Force
            Mock -CommandName GetExclusions -ModuleName PSSecretScanner -MockWith {
                return "$((resolve-path TestDrive:\TestFile.ps1).ProviderPath);1;pat1"
            }
            $r = Find-Secret $ScanFolder -OutputPreference Object -Excludelist 'TestDrive:\TestFile.ps1'
            $r.count | Should -Be 1
        }
    }

    Context 'Functionality - ParameterSet "File"' {
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
        It 'If given one single file it should scan that file' {
            $r = Find-Secret -File $TestFile -OutputPreference Object
            $r.count | Should -Be 1
        }
    }

    Context 'Functionality - ParameterSet Path' {
        BeforeAll {
            $TestFile = 'TestDrive:\TestFile.ps1'
            $ScanFolder = Split-Path $TestFile
    
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
            } -ParameterFilter {$Path -and $Path -eq $TestFile -and $File -and $Recurse}
            
            # Mock GetConfig - wrapper function to make Find-Secret testable
            Mock -CommandName GetConfig -ModuleName PSSecretScanner -MockWith {
                return '{"regexes":[{"_Pattern1":"pat1"},{"_Pattern2":"pat2"}],"fileextensions":[".ps1",".ps2"]}' | ConvertFrom-Json -AsHashtable
            }
        }

        It 'Given a folder it should scan that folder - Using positional paramneter' {
            $r = Find-Secret $ScanFolder -OutputPreference Object
            $r.count | Should -Be 1
        }

        It 'Given a folder it should scan that folder - Not using positional paramneter' {
            $r = Find-Secret -Path $ScanFolder -OutputPreference Object
            $r.count | Should -Be 1
        }

        It 'Given a folder and a file it should scan both' {
            New-Item 'TestDrive:\Folder1\' -ItemType Directory
            New-Item 'TestDrive:\Folder2\' -ItemType Directory
            'pat1' | Out-File -FilePath TestDrive:\Folder1\file1.ps1 -Force
            'pat1' | Out-File -FilePath TestDrive:\Folder2\file2.ps1 -Force

            $r = Find-Secret 'TestDrive:\Folder1','TestDrive:\Folder2\file2.ps1' -OutputPreference Object
            $r.count | Should -Be 2
        }

        It 'Given only a file it should throw' {
            {Find-Secret 'TestDrive:\Folder2\file2.ps1' -OutputPreference Object} | Should -Throw
        }
    }
}
