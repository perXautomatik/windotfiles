# Define the path to search for .git files
$path = "B:\d2rmm\mods\"

# Define the path to the Everything command line tool
$es = "C:\ProgramData\scoop\shims\es.exe"
# Get the list of .git files using Everything

# Get the list of local git repositories
$listx = & $es -p $path -s -regex "[.]git.config$"

# Get the other local repository directory
$dirx = $path

# Change the working directory to dirx
Set-Location $dirx

# Loop through each repository in the list
foreach ($repo in $listx) {
    # Get the relative path from dirx to repo
    $repo = $repo | Split-Path -Parent
    $repo = $repo | Split-Path -Parent
    $relpath = [System.IO.Path]::GetRelativePath($dirx, $repo)

    git add .
    # Use git index to remove memory for the relative path in dirx
    git rm --cached -r $relpath

    # Commit the changes
    git commit -m "Remove memory for $relpath"

    # Add the repo as a submodule to dirx at the relative path
    git submodule add $repo $relpath
    git commit --amend
}
