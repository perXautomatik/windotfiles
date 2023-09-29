param ($source,$target,$original)

. .\fork\sort-STNumerical.ps1

    function Get-FileEncoding {
        param ( [string] $FilePath )

        [byte[]] $byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $FilePath

        if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
            { $encoding = 'UTF8' }  
        elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
            { $encoding = 'BigEndianUnicode' }
        elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
             { $encoding = 'Unicode' }
        elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
            { $encoding = 'UTF32' }
        elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
            { $encoding = 'UTF7'}
        else
            { $encoding = 'ASCII' }
        return $encoding
    }


    $encoding = Get-FileEncoding $source
    $content = Get-Content -Path $source -Encoding $encoding
        # Process content here...
        
    (Get-Content $source) >> $original

     $lines = $content | %{ $_.tolower().trim() -replace '"','едц'}
    
    # case insensitive
    $hash = @{}
    $lines | %{$hash[$_]++}

 try {
        $PSDefaultParameterValues['out-file:width'] = 2000
    $result = $hash.GetEnumerator() | select key  | convertTo-csv -NoTypeInformation | Select-Object -Skip 1 
    $result | % {$_ -replace '"',''} | % {$_ -replace 'едц','"'} | Set-Content -Path $target -Encoding $encoding
    }
    finally {
        $PSDefaultParameterValues.Remove('out-file:width')
    }
