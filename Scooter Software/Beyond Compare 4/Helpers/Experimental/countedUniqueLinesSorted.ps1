param ($source,$target,$original)

. .\fork\sort-STNumerical.ps1

    (Get-Content $source) >> $original
     $lines = (Get-Content $source) | %{ $_.tolower()}
    
    # case insensitive
    $hash = @{}
    $lines | %{$hash[$_]++}
    
    $sorted = $hash.GetEnumerator() | sort-object {[int]$_.value}

 try {
        $PSDefaultParameterValues['out-file:width'] = 2000
    $sorted | select key | Format-Table -AutoSize | out-file -FilePath $target
    }
    finally {
        $PSDefaultParameterValues.Remove('out-file:width')
    }

    
