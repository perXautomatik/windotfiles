param ($source,$target,$original)


    (Get-Content $source) >> $original
    $lines = (Get-Content $source) | %{ $_.tolower().trim()}
    
    # case insensitive
    $hash = @{}
	$lines | %{ $hash[$_]++ }

	$repeated = $hash.GetEnumerator() | ?{[int]$_.value -gt 1 }

	$results = @($lines | ? { $_ -notin $repeated.Key })

	$results += @($repeated | sort-object { [int]$_.value } | select key)

	$results > $target