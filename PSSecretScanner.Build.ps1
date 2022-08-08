#Requires -Modules 'InvokeBuild', 'PlatyPS', 'Pester'

[string]$ModuleName = 'PSSecretScanner'
[string]$ModuleSourcePath = "$PSScriptRoot\Source"
[string]$HelpSourcePath = "$PSScriptRoot\Docs\Help"

[string]$Version = '1.0.9'

[string]$OutputPath = "$PSScriptRoot\Bin\$ModuleName\$Version"

task Clean {
    If (Test-Path -Path $OutputPath) {
        "Removing existing files and folders in $OutputPath"
        Get-ChildItem $OutputPath | Remove-Item -Force -Recurse
    }
    Else {
        "$OutputPath is not present, nothing to clean up."
        $Null = New-Item -ItemType Directory -Path $OutputPath
    }
}

task Unit_Tests {
    # .$PSScriptRoot\Tests\TestRunner.ps1 -Verbosity Normal -CodeCoverage
    Invoke-Pester .\Tests -Output Detailed
}

task RunScriptAnalyzer {
    Invoke-ScriptAnalyzer -Path $ModuleSourcePath -Recurse -Severity Error -EnableExit
}

Task Build_Documentation {
    New-ExternalHelp -Path $HelpSourcePath -OutputPath "$OutputPath\en-US"
}

task Compile_Module {
    $PSM1Name = "$ModuleName.psm1"
    New-Item -Name $PSM1Name -Path $OutputPath -ItemType File -Force 
    $PSM1Path = (Join-Path -Path $OutputPath -ChildPath $PSM1Name)
    
    $PSD1Name = "$ModuleName.psd1"
    New-Item -Name $PSD1Name -Path $OutputPath -ItemType File -Force 
    $PSD1Path = (Join-Path -Path $OutputPath -ChildPath $PSD1Name)

    $ExportedFunctionList = [System.Collections.Generic.List[string]]::new()

    # Private functions
    Get-ChildItem "$ModuleSourcePath\Private" *.ps1 | ForEach-Object {
        $FileContent = Get-Content $_.FullName
        "#region $($_.BaseName)`n"      | Out-File $PSM1Path -Append
        $FileContent                    | Out-File $PSM1Path -Append
        "#endregion $($_.BaseName)`n"   | Out-File $PSM1Path -Append
    }

    # Public functions
    '$script:PSSSConfigPath = "$PSScriptRoot\config.json"' | Out-File $PSM1Path -Append
    "`n" | Out-File $PSM1Path -Append

    Get-ChildItem "$ModuleSourcePath\Public" *.ps1 | ForEach-Object {
        $ExportedFunctionList.Add($_.BaseName)

        $FileContent = Get-Content $_.FullName
        "#region $($_.BaseName)`n" | Out-File $PSM1Path -Append
        $FileContent | Out-File $PSM1Path -Append
        "#endregion $($_.BaseName)`n" | Out-File $PSM1Path -Append
    }

    # Manifest
    $ManifestContent = (Get-Content "$ModuleSourcePath\$ModuleName.psd1" ) -replace 'ModuleVersion\s*=\s*[''"][0-9\.]{1,10}[''"]',"Moduleversion = '$Version'" -replace 'FunctionsToExport\s*=\s*[''"]\*[''"]',"FunctionsToExport = @('$($ExportedFunctionList -join "','")')"
    $ManifestContent | Out-File $PSD1Path 
}

task Include_Resources {
    Copy-Item -Path $PSScriptRoot\Source\config.json -Destination $OutputPath
}

# task Publish_Module_To_PSGallery {
#     Remove-Module -Name 'PSCodeHealth' -Force -ErrorAction SilentlyContinue

#     Write-Host "OutputModulePath : $($Settings.OutputModulePath)"
#     Write-Host "PSGalleryKey : $($Settings.PSGalleryKey)"
#     Get-PackageProvider -ListAvailable
#     Publish-Module -Path $Settings.OutputModulePath -NuGetApiKey $Settings.PSGalleryKey -Verbose
# }

Get-Module -Name $ModuleName | Remove-Module -Force
# Default task :
task . Clean,
    Unit_Tests,
    RunScriptAnalyzer,
    Build_Documentation,
    Compile_Module,
    Include_Resources
    