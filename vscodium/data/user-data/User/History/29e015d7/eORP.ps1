# Get the list of file names from a text file
#$files = Get-Clipboard 
#$files = $files | select -Unique
Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % { . $_.FullName }

# Get the path of the original repository
$repo = "B:\PF\Archive\ps1"
$folderPath = "B:\ps1"

cd $repo; git config --local uploadpack.allowFilter true

# Create a folder to store the filtered repositories
cd  $repo

try {
    git-status -path $repo
    #git-status -path $repox            
    $to = CloneWithReference -repo $repo -objectRepo $repo -path $folderPath --
    
    cd $folderPath
    
    Write-Output "---"
}
catch {
    Write-Error $_
    Write-Error "Failed to clone into $folderPath"
}

$files = git ls-files | ? { $_ -match "git" }

cd $folderPath
# Loop through each file name in the list
foreach ($file in $files) {

    # Change the current directory to the subfolder

    try {
        #$tr = "$folderPath\$file\ps1"
        #$f = "$file"
        cherryPick-byPattern -pattern $file -erroraction cont
        #FilterBySubdirectory -baseRepo $repo -targetRepo $tr -toFilterRepo $tr -toFilterBy $f -branchName "master"      
    }
    catch {
        Write-Error "Failed to Filter for $file"
        Write-Error $_
    }
 
}


# Return the folder with the filtered repositories
#Write-Output $folder
