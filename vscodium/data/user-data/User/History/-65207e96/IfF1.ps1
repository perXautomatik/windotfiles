# A PowerShell script that takes a path to a local git repo as input
# and then for each commit on the current branch, print file names, file sizes and checksums of files affected by each commit

# Get the path to the local git repo from the user
$repoPath = Read-Host -Prompt "Enter the path to the local git repo"

# Change the current directory to the repo path
Set-Location $repoPath

# Get the current branch name
$branchName = git rev-parse --abbrev-ref HEAD

# Get the list of commits on the current branch
$commits = git rev-list $branchName

# Loop through each commit
foreach ($commit in $commits) {
    # Print the commit hash and message
    $commitMessage = git log -1 --format=%s $commit
    Write-Host "Commit: $commit - $commitMessage"

    # Get the list of files affected by the commit
    $files = git diff-tree --no-commit-id --name-only -r $commit

    # Loop through each file
    foreach ($file in $files) {
        # Get the file size in bytes
        $fileSize = (Get-Item $file).Length

        # Format the file size to human-readable units
        $fileSizeFormatted = [math]::Round($fileSize / 1KB, 2)
        if ($fileSizeFormatted -ge 1MB) {
            $fileSizeFormatted = [math]::Round($fileSize / 1MB, 2) + " MB"
        }
        elseif ($fileSizeFormatted -ge 1KB) {
            $fileSizeFormatted = [math]::Round($fileSize / 1KB, 2) + " KB"
        }
        else {
            $fileSizeFormatted = $fileSize + " B"
        }

        # Get the file content as it is stored in the commit
        $fileContent = git show $commit:$file

        # Calculate the checksum for the file content using MD5 algorithm
        $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
        $utf8 = New-Object -TypeName System.Text.UTF8Encoding
        $checksum = [System.BitConverter]::ToString ($md5.ComputeHash ($utf8.GetBytes ($fileContent)))

        # Print the file name, size and checksum
        Write-Host "$file - $fileSizeFormatted - $checksum"
    }

    # Print a blank line for readability
    Write-Host ""
}
