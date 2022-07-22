function AssertParameter {
    <#
    .SYNOPSIS
        Simplifies custom error messages for ValidateScript
    
    .DESCRIPTION
        Windows PowerShell implementation of the ErrorMessage functionality available
        for ValidateScript in PowerShell core
    
    .EXAMPLE
        [ValidateScript({ Assert-Parameter -ScriptBlock {Test-Path $_} -ErrorMessage "Path not found." })]
    #>
    param(
        [Parameter(Position = 0)]
        [scriptblock] $ScriptBlock
        ,
        [Parameter(Position = 1)]
        [string] $ErrorMessage = 'Failed parameter assertion'
    )

    if (& $ScriptBlock) {
        $true
    } else {
        throw $ErrorMessage
    }
}
