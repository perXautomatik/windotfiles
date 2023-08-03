# Get the current repository URL
$repo = "B:\PF\PowerShellProjectFolder\" #git config --get remote.origin.url

# Create a temporary folder
$temp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'git' } -PassThru | % { rm $_ ; mkdir -Path $_ }  
Set-Location $temp

# Clone the repository into the temporary folder
git clone $repo $temp --no-local
$repo = $temp

# Get the list of all file names in the repository
$files = git ls-files

# Create an empty queue to store the folders to be deleted
$queue = New-Object System.Collections.Queue

# Loop through each file name
foreach ($file in $files) {
    
    # Create a temporary folder
    $temp = New-TemporaryFile | Rename-Item -NewName { $_ -replace 'tmp$', 'git' } -PassThru | % { rm $_ ; mkdir -Path $_ }  

    # Change the working directory to the temporary folder
    Set-Location $temp

    # Clone the repository into the temporary folder
    git clone $repo $temp


    # Remove the relative path from the file name
    $name = Split-Path -Leaf $file

    # Create a new branch with the file name as the branch name
   $resp = Invoke-Expression "git branch $name 2>&1"
    if ($resp.TargetObject -like "fatal*")
    {
      $q = $temp.BaseName
      $name = ($q -split "[.]")[0]
      git branch $name
    }
    # Switch to the new branch
    git checkout $name
     
    # Use git filter-repo to keep only the history related to the file name
    git filter-repo --path-glob $name --force

    # Push the new branch to the original repository
    git push $repo $name

    # Add the temporary folder to the queue
    $queue.Enqueue($temp)

}

# Change the working directory back to the original folder
Set-Location $repo

# Loop through the queue and delete each folder
while ($queue.Count -gt 0) {
    # Dequeue a folder from the queue
    $folder = $queue.Dequeue()

    # Try to remove the folder and catch any errors
    try {
        Remove-Item -Recurse -Force $folder -ErrorAction Stop
    }
    catch {
        # If an error occurs, re-enqueue the folder and write a warning message
        $queue.Enqueue($folder)
        Write-Warning "Failed to delete folder: $($folder.FullName)"
    }
}
