function runx {
$v = Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" -Global
if($v)
{
$v | %{ 
        $q = trid $_ -ce
        $g = ($q -like 'Collecting data from file: ')
        if($g[-1] -eq " 0 file(s) renamed.")
        {
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