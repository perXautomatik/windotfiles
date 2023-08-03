Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" | 
    select -first 76 | %{ 
        $q = trid $_ -ce
        $pos = [array]::IndexOf($q, "image123.jpg")
        $filename = ($q[$pos] -split 'file: ')[1];
        
        $ext =

} 