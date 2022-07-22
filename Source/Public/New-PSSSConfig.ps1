function New-PSSSConfig {
    param (
        [Parameter(Mandatory)]
        [string]$Path
    )

    $ConfigFileName = Split-Path $script:PSSSConfigPath -leaf

    $InvokeSplat = @{
        Path = $script:PSSSConfigPath
        Destination = $Path 
    }

    if (Test-Path (Join-Path -Path $Path -ChildPath $ConfigFileName)) {
        Write-Warning 'Config file already exists!'
        $InvokeSplat.Add('Confirm',$true)
    }

    Copy-Item @InvokeSplat
}
