# Get the current repository URL
$repo = git config --get remote.origin.url

# Create a temporary folder
$temp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'git' } -PassThru

# Clone the repository into the temporary folder
git clone $repo $temp

# Change the working directory to the temporary folder
Set-Location $temp

# Get the list of all file names in the repository and their commit counts
$files = git log --name-only --pretty=format: | sort | group | select Name, Count

# Filter out the files that are touched by less than 2 commits
$files = $files | where { $_.Count -ge 2 }

# Loop through each file name
foreach ($file in $files) {
    # Get the file name and its commit count
    $name = $file.Name
    $count = $file.Count

    # Create a new branch with the file name as the branch name
    git branch $name

    # Switch to the new branch
    git checkout $name

    # Use git filter-repo to keep only the history related to the file name
    git filter-repo --path $name

    # Push the new branch to the original repository
    git push origin $name

    # Write a message with the file name and its commit count
    Write-Output "Processed file: $name ($count commits)"
}

# Change the working directory back to the original folder
Set-Location ..

# Remove the temporary folder
Remove-Item -Recurse -Force $temp
