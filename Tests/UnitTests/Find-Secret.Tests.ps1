#Requires -Version 7

Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

Describe 'Find-Secret' {
    Context 'Basic design tests' {
        It 'Should have non mandatory parameter <_>' -TestCases 'Path', 'ConfigPath', 'Excludelist', 'Filetype', 'File', 'NoRecurse' {
            Get-Command Find-Secret | Should -HaveParameter $_ -Because 'If parameters change behaviour we need to do a major bump'
        }

        It 'Path should be the default parameterset' {
            $r = (Get-Command Find-Secret).ParameterSets.Where({$_.IsDefault})
            $r.Name | Should -Be 'Path'
        }
    }

    Context 'Version 2.0 - Output object' {
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

        It 'Output object should be of type "PSCustomObject"' {
            $r = Find-Secret $TestFile
            $r | Should -BeOfType PSCustomObject
        }

        It 'Output object typenames should be "PSSecretScanner.ResultSet"' {
            $r = Find-Secret $TestFile
            'PSSecretScanner.ResultSet' | Should -BeIn $r.pstypenames 
        }

        It 'Each result should be of type "MatchInfo"' {
            $r = Find-Secret $TestFile
            $r.Results[0] | Should -BeOfType Microsoft.PowerShell.Commands.MatchInfo
        }

        It 'Each result object typename should be "PSSecretScanner.Result"' {
            $r = Find-Secret $TestFile
            'PSSecretScanner.Result' | Should -BeIn $r.Results[0].pstypenames
        }

        It 'Result should always contain property <_> - no scanresults' -TestCases 'Results', 'ScanEnd', 'ScanFiles', 'ScanStart', 'ScanTimespan', 'Count', 'FailedFailCount', 'FileCount' {
            $r = Find-Secret
            $r.Results.Count | Should -be 0
            $_ | Should -BeIn ($r | Get-Member).Name 
        }

        It 'Result should always contain property <_> - one scanresult' -TestCases 'Results', 'ScanEnd', 'ScanFiles', 'ScanStart', 'ScanTimespan', 'Count', 'FailedFailCount', 'FileCount' {
            $r = Find-Secret $TestFile
            $r.Results.Count | Should -be 1
            $_ | Should -BeIn ($r | Get-Member).Name 
        }

        It 'FileCount should be the amount of files where secrets are found' {
            $r = Find-Secret $TestFile
            $r.FileCount | Should -be 1
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
            
            # Mock GetConfig - wrapper function to make Find-Secret testable
            Mock -CommandName GetConfig -ModuleName PSSecretScanner -MockWith {
                return '{"regexes":[{"_Pattern1":"pat1"},{"_Pattern2":"pat2"}],"fileextensions":[".ps1",".ps2"]}' | ConvertFrom-Json -AsHashtable
            }
        }

        It 'If an exclusion list is given it should excluse matches - zero results' {
            Mock -CommandName GetExclusions -ModuleName PSSecretScanner -MockWith {
                $p = $((resolve-path TestDrive:\TestFile.ps1).ProviderPath).Replace('\','\\')
                "[{""Type"": ""LinePattern"",""StringValue"": ""$p;1;pat1""}]" | ConvertFrom-Json
            }
            $r = Find-Secret $ScanFolder -Excludelist 'TestDrive:\TestFile.ps1'
            $r.results.count | Should -Be 0
        }

        It 'If an exclusion list is given it should excluse matches - one result' {
            "pat1`npat2" | Out-File -FilePath $TestFile -Force
            Mock -CommandName GetExclusions -ModuleName PSSecretScanner -MockWith {
                $p = $((resolve-path TestDrive:\TestFile.ps1).ProviderPath).Replace('\','\\')
                "[{""Type"": ""LinePattern"",""StringValue"": ""$p;1;pat1""}]" | ConvertFrom-Json
            }
            $r = Find-Secret $ScanFolder -Excludelist 'TestDrive:\TestFile.ps1'
            $r.results.count | Should -Be 1
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
            $r = Find-Secret -File $TestFile
            $r.ScanFiles.count | Should -Be 1
        }
    }

    Context 'Functionality - ParameterSet "Path"' {
        BeforeEach {
            # Start every test by cleaning up and recreating test environment

            Get-ChildItem TestDrive:\ | Remove-Item -Recurse
            $TestFile = 'TestDrive:\TestFile.ps1'
            $ScanFolder = Split-Path $TestFile
    
            # Create a test file
            'pat1' | Out-File -FilePath $TestFile -Force
        }
        
        BeforeAll {
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
            $r = Find-Secret $ScanFolder
            $r.ScanFiles.count | Should -Be 1
        }

        It 'Given a folder it should scan that folder - Not using positional paramneter' {
            $r = Find-Secret -Path $ScanFolder
            $r.ScanFiles.count | Should -Be 1
        }

        It 'Given a folder and a file it should scan both' {
            New-Item 'TestDrive:\Folder1\' -ItemType Directory
            New-Item 'TestDrive:\Folder2\' -ItemType Directory
            'pat1' | Out-File -FilePath TestDrive:\Folder1\file1.ps1 -Force
            'pat1' | Out-File -FilePath TestDrive:\Folder2\file2.ps1 -Force

            $r = Find-Secret 'TestDrive:\Folder1','TestDrive:\Folder2\file2.ps1'
            $r.ScanFiles.count | Should -Be 2
        }

        It 'Given only a file it should work as expected' {
            $r = Find-Secret 'TestDrive:\TestFile.ps1'
            $r.ScanFiles.count | Should -Be 1
        }

        It 'If NoRecurse is set we should only scan root dir' {
            # Make sure we have a subfolder tree with at least three matching files.
            New-Item 'TestDrive:\Folder1\' -ItemType Directory
            New-Item 'TestDrive:\Folder2\' -ItemType Directory
            'pat1' | Out-File -FilePath TestDrive:\Folder1\file1.ps1 -Force
            'pat1' | Out-File -FilePath TestDrive:\Folder2\file2.ps1 -Force

            $r = Find-Secret $ScanFolder -NoRecurse
            $r.ScanFiles.count | Should -Be 1
        }
    }
}
