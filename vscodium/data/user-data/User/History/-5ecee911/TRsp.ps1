function runx {
$v = Search-Everything -PathExclude ".git" -filter " folder\ file: !ext:gz;webp;gif" -Global

$v | 
    select -first 76 | %{ 
        $q = trid $_ -ce
        $g = ($q -like 'Collecting data from file: ')
        if($g)
        {
            $pos = [array]::IndexOf($q, $q)
            $filename = ($q[$pos] -split 'file: ')[1];
            $regex ="[()]";
            $ext = $filename = ($q[$pos+1] -split $regex)[1];
        }
} 
}