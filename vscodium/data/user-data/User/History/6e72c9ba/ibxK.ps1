

# Get the list of local git repositories
$listx = Get-Content "listx.txt"

# Get the other local repository directory
$dirx = "C:\dirx"

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
