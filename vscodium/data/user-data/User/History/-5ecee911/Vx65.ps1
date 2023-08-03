Search-Everything -PathExclude ".git" -filter "folder\ file: !ext:gz;webp;gif"| select -first 76 | %{ $q = trid $_ -ce } 
$filename = ($q[$pos] -split 'file: ')[1]; $ext =