Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" | 
    select -first 76 | %{ 
        $q = trid $_ -ce
        $g = ($q -like 'Collecting data from file: ')
        $pos = [array]::IndexOf($q, $q)
        $filename = ($q[$pos] -split 'file: ')[1];
        
        $ext =

} 