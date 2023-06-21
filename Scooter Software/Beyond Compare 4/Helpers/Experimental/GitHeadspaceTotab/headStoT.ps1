param ($source,$target,$original)

    (Get-Content $source) >> $original

    $lines = (Get-Content $source)
    
    $lines | % { $parts = $_ -split ':' ; $parts[0] = $parts[0] -replace '`s','`t' ; "$parts[0]$parts[1]" } > $target
    
