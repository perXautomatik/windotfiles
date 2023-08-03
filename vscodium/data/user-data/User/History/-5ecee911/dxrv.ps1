function runx {
$v = Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" -Global
if($v)
{
$v | %{ 
        $q = trid $_ -ce
        if($q[-1] -ne " 0 file(s) renamed.")
        {
            $g = ($q -match 'Collecting data from file: ')
            $pos = [array]::IndexOf($q, $g)
            $filename = ($q[$pos] -split 'file: ')[1];
            $regex ="[()]";
            $ext = (($q[$pos+1] -split $regex)[1] -split '/')[0];
            $test = Test-path ($filename+$ext)
        }
        else {
            $g
        }
} 
}
else
{"no ressults"}
}