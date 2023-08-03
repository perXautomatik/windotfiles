# Define the source and destination paths
$PathA = "B:\PF\Modding\Diablo II ressurected"
$PathB = "C:\Users\CrRoot\Desktop\New folder (2)\D2RMM 1.4.5\mods"

# Get all the folders inside PathA
$Folders = Get-ChildItem -Path $PathA -Directory

# Sort each folder by total file size, small to large
$SortedFolders = $Folders | Sort-Object -Property @{Expression = {(Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum}} 

# Move the sorted folders into PathB
$SortedFolders | Move-Item -Destination $PathB

# Change the current location to PathB
Set-Location $PathB

# Initialize a git repository in PathB
git init

# Loop through each folder in PathB
foreach ($Folder in $SortedFolders) {
    # Add the folder to the staging area
    git add $Folder.Name
    
    # Commit the folder with the folder name as the commit message
    git commit -m $Folder.Name
}