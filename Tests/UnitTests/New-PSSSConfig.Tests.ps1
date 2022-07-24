Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

Describe 'New-PSSSConfig' {
    Context 'Copying new config file' {
        BeforeEach {
            if (Test-Path TestDrive:\config.json) {
                Remove-Item TestDrive:\config.json -Force
            }
        }

        It 'Should copy a new config.json to the patch given.' {
            New-PSSSConfig -Path TestDrive:\config.json
            Test-Path TestDrive:\config.json | Should -Be $true
        }
    }
}