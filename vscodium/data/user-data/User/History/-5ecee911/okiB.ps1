Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" | 
    select -first 76 | %{ 
        $q = trid $_ -ce
        $pos = $q.indexOF
        $filename = ($q[$pos] -split 'file: ')[1];
        
        $ext =

} 