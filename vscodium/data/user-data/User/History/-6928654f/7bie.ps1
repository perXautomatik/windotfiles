# Get the list of file names from a text file
#$files = Get-Clipboard 
#$files = $files | select -Unique
Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % { . $_.FullName }

# Get the path of the original repository
$repo = "B:\PF\Archive\ps1"
$clonedRepo = "B:\ps1"

cd $repo; git config --local uploadpack.allowFilter true

# Create a folder to store the filtered repositories
cd  $repo

try {
    git-status -path $repo
    #git-status -path $repox            
    $to = CloneWithReference -repo $repo -objectRepo $repo -path $clonedRepo -ErrorAction Continue
    
    cd $clonedRepo
    
    Write-Output "---"
}
catch {
    Write-Error $_
    Write-Error "Failed to clone into $clonedRepo"
}

$files = git ls-files | ? { $_ -match "git" }

cd $clonedRepo
# Loop through each file name in the list
foreach ($file in $files) {

    # Change the current directory to the subfolder

    try {
        #$tr = "$clonedRepo\$file\ps1"
        #$f = "$file"
        branchAndRevert-byPattern -pattern $file -ErrorAction Continue
        #FilterBySubdirectory -baseRepo $repo -targetRepo $tr -toFilterRepo $tr -toFilterBy $f -branchName "master"      
    }
    catch {
        Write-Error "Failed to Filter for $file"
        Write-Error $_
    }
 
}


# Return the folder with the filtered repositories
#Write-Output $folder
