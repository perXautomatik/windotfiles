param ($source,$target,$original)

. .\fork\sort-STNumerical.ps1

    (Get-Content $source) >> $original
    $lines = (Get-Content $source) | %{ $_.tolower()}
    
    # case insensitive
    $hash = @{}
    $lines | %{$hash[$_]++}

    $result = $lines | select value,name | convertTo-csv -NoTypeInformation | Select-Object -Skip 1
    $result  > $target
    
