# Get the list of file names from a text file
#$files = Get-Clipboard 
#$files = $files | select -Unique
Get-ChildItem -path B:\GitPs1Module | % { . $_.FullName }

# Get the path of the original repository
$repo = "B:\ps1"
$repox = "file:///B:/ps1/.git"
$folderPath = "B:\Filtered"

cd $repo; git config --local uploadpack.allowFilter true

# Create a folder to store the filtered repositories
cd  $repo

$files = git ls-files | ? { $_ -match "git" }

cd $folderPath
# Loop through each file name in the list
foreach ($file in $files) {
    
    try {
        $sub = Join-Path $folderPath $file

        $subfolder = New-Item -Path $sub -ItemType Directory -Force -ErrorAction Stop 
    }
    catch {
        Write-Error "Failed to create subfolder for $file"
        Write-Error $_
    }

    try {
        git-status -path $repo
        git-status -path $repox            
        CloneWithReference -repo $repox -objectRepo $repo -path ($subfolder.FullName)
        
        cd ps1 -PassThru
        
        Write-Output "---"
    }
    catch {
        Write-Error $_
        Write-Error "Failed to clone $subfolder"
    }

    # Change the current directory to the subfolder

    try {
        FilterBySubdirectory -baseRepo $repo -targetRepo "$folderPath\$file" -toFilterRepo "$folderPath\$file" -toFilterBy "ps1\$file" -branchName "master"      
    }
    catch {
        Write-Error "Failed to Filter for $file"
        Write-Error $_
    }
    #
    #git submodule update --init --recursive 


    #git clone --reference $repo --filter=combine:blob:none,sparse:$file, $repox
    #filterByName ($file)

    # Filter the copied repository to only contain the current file name using git filter-branch
    #try {
        #git filter-branch --prune-empty --subdirectory-filter $file HEAD
    #}
    #catch {
        #Write-Error "Failed to filter repository by $file"
        #continue # Skip to the next file
    #}

    # Change the current directory back to the original repository
 #   Set-Location $repo
}


# Return the folder with the filtered repositories
#Write-Output $folder
