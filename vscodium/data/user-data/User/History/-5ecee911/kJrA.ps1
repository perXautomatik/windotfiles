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
            $file = ($filename+$ext)
            $testCondition = Test-path $file
            $destinationDrive = "L:"

            if ($testCondition) {
                $file = $file | Get-Content
                # Get the file path without the drive letter
                $filePath = $file.FullName.Substring(2)
            
                # Construct the destination path by replacing the drive letter
                $destinationPath = $destinationDrive + $filePath
            
                # Create the destination directory if it does not exist
                $destinationDir = Split-Path -Path $destinationPath -Parent
                if (-not (Test-Path -Path $destinationDir)) {
                  New-Item -Path $destinationDir -ItemType Directory
                }
            
                # Move the file to the destination path
                Move-Item -Path $file.FullName -Destination $destinationPath
              }


        }
        else {
            $g
        }
} 
}
else
{"no ressults"}
}