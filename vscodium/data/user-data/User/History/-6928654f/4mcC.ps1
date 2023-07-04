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

        $branch = branch-byPattern -pattern $file -ErrorAction Continue
        if($branch)
        {
            Revert-byPattern -pattern $file -branch $branch -ErrorAction Continue
        }

    }
    catch {
        Write-Error "Failed to Filter for $file"
        Write-Error $_
    } 
}
foreach ($file in $files) {

# Return the folder with the filtered repositories
#Write-Output $folder
