# Define the source and destination paths
$PathB = "B:\PF\Modding\Diablo II ressurected"
$PathA = "C:\Users\CrRoot\Desktop\New folder (2)\D2RMM 1.4.5\mods\"

# Get all the folders inside PathA
$Folders = Get-ChildItem -Path $PathA -Directory

# Sort each folder by total file size, small to large
$SortedFolders = $Folders | Sort-Object -Property @{Expression = {(Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum}} 

# Move the sorted folders into PathB
$SortedFolders | %{ 
    $q = Move-Item -Path $_ -Destination $PathB  -Force -Verbose
    $q
    # Change the current location to PathB
    Set-Location $PathB

    $Folder = $_
    # Add the folder to the staging area
    git add $Folder.Name

    # Commit the folder with the folder name as the commit message
    git commit -m $Folder.Name
}