function runx {
$v = Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" -Global
if($v)
{
$v | %{ 
        $q = trid $_ -ce
        if($q[-1] -ne " 0 file(s) renamed.")
        {
            $g = ($q -like 'Collecting data from file: ')
            $pos = [array]::IndexOf($q, $q)
            $filename = ($q[$pos] -split 'file: ')[1];
            $regex ="[()]";
            $ext = $filename = ($q[$pos+1] -split $regex)[1];
        }
        else {
            $g
        }
} 
}
else
{"no ressults"}
}