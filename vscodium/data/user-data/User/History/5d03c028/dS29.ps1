# Get the current repository URL
$repo = "B:\PF\PowerShellProjectFolder\" #git config --get remote.origin.url

# Get the list of all file names in the repository
$files = git ls-files

# Loop through each file name
foreach ($file in $files) {
    
    # Create a temporary folder
    $temp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'git' } -PassThru | % { rm $_ ; $_ | mkdir }  

    # Clone the repository into the temporary folder
    git clone $repo $temp

    # Change the working directory to the temporary folder
    Set-Location $temp

    # Remove the relative path from the file name
    $name = Split-Path -Leaf $file

    # Create a new branch with the file name as the branch name
   $resp = Invoke-Expression "git branch $name 2>&1"
    if ($resp.TargetObject -like "fatal")
    {
      $q = $temp.BaseName
    }
    # Switch to the new branch
    git checkout $name

    # Use git filter-repo to keep only the history related to the file name
    git filter-repo --path $file

    # Push the new branch to the original repository
    git push origin $name
}

# Change the working directory back to the original folder
Set-Location ..

# Remove the temporary folder
Remove-Item -Recurse -Force $temp
