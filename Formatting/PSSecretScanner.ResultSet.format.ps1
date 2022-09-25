#requires -Module EZOut
Write-FormatView -TypeName PSSecretScanner.ResultSet -Action {
    Write-FormatViewExpression -Text "PSSecretScanner Scan Results"

    Write-FormatViewExpression -ScriptBlock {
        ' ' + (@(if ( $_.Results.Count -eq 0 ) {
            Format-RichText -ForegroundColor Verbose -InputObject ' @ '
        }
        else {
            Format-RichText -ForegroundColor Error -InputObject ' @ '
        }) -join '') + ' '
    }

    Write-FormatViewExpression -ScriptBlock {
        "[ $($_.ScanStart.ToShortTimeString()) - $($_.ScanEnd.ToShortTimeString())] $([Math]::Round($_.ScanTimespan.TotalSeconds,2))s"
    }    
    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -ScriptBlock {
        $_.Results | Out-String
    }

    Write-FormatViewExpression -Newline

    Write-FormatViewExpression -If {
        $env:BUILD_BUILDID -and $_.Results.Count -gt 0
    } -ScriptBlock {
        @(
            "##vso[task.logissue type=error]$($_.Results.Count) secrets found $('!' * $_.Results.Count)"
            foreach ($bad in $_.results) {
                "##vso[task.logissue type=error;sourcepath=$($bad.Path);linenumber=$($bad.LineNumber)]$($bad.PatternName) found"
            }
        ) -join [Environment]::NewLine
    }

    Write-FormatViewExpression -If {
        $env:GITHUB_JOB -and $_.Results.Count -gt 0
    } -ScriptBlock {
        @(
            "::error::$($_.Results.Count) secrets found $('!' * $_.Results.Count)"
            foreach ($bad in $_.results) {
                "::error file=$($bad.Path),line=$($bad.LineNumber)::$($bad.PatternName) found"
            }
        ) -join [Environment]::NewLine
    }
}