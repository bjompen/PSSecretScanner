Remove-Module PSSecretScanner -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\Source\PSSecretScanner -Force

InModuleScope -ModuleName PSSecretScanner {
    Describe 'ConvertToHashtable' {
        It 'Should convert PSObject to hashtable the way we currently use it' {
            $Config = @'
{
"regexes":[
{"_Private_Key":"[-]{5}BEGIN\\s(?:[DR]SA|OPENSSH|EC|PGP)\\sPRIVATE\\sKEY(?:\\sBLOCK)?[-]{5}"},
],
"fileextensions":[
".ps1",
]
}         
'@
            $r = $Config | ConvertFrom-Json | ConvertToHashtable
            $r | Should -BeOfType [hashtable]
        }
    }
}