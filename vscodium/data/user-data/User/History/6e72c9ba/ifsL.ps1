# Define the path to search for .git files
$path = "K:\D2RMM 1.4.5\mods"

# Define the path to the Everything command line tool
$es = "C:\ProgramData\scoop\shims\es.exe"
# Get the list of .git files using Everything

# Get the list of local git repositories
$listx = & $es -p $path -s -regex "[.]git$"

# Get the other local repository directory
$dirx = $path

# Change the working directory to dirx
Set-Location $dirx

# Loop through each repository in the list
foreach ($repo in $listx) {
    # Get the relative path from dirx to repo
    $relpath = [System.IO.Path]::GetRelativePath($dirx, $repo)

    # Use git index to remove memory for the relative path in dirx
    git rm --cached $relpath

    # Commit the changes
    git commit -m "Remove memory for $relpath"

    # Add the repo as a submodule to dirx at the relative path
    git submodule add $repo $relpath
}
