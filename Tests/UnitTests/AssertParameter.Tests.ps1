Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

InModuleScope -ModuleName PSSecretScanner {
    Describe 'AssertParameter' {
        It 'Should not throw when scriptblock is successful' {
            {AssertParameter -ScriptBlock {$true} -ErrorMessage 'error!' }| Should -Not -Throw
        }

        It 'Should throw when scriptblock is not successful' {
            {AssertParameter -ScriptBlock {$false} -ErrorMessage 'error!'} | Should -Throw
        }
    }
}