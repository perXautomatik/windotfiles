# A function that takes a path to a local git repo as input
# and returns the list of commits on the current branch
Function Get-Sha1 {
    Param (
        # The path to the local git repo
        [Parameter(Mandatory=$true)]
        [string]$RepoPath
    )

    # Change the current directory to the repo path
    Set-Location $RepoPath

    # Get the current branch name
    $BranchName = git rev-parse --abbrev-ref HEAD

    # Get the list of commits on the current branch
    $Commits = git rev-list $BranchName

    # Return the list of commits
    return $Commits
}

# A function that takes a list of commits as input
# and prints file names, file sizes and checksums of files affected by each commit
Function Get-FilesSha1 {
    Param (
        # The list of commits
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$Commits
    )

    Begin {
        # Create an empty array to store the output
        $Output = @()
    }

    Process {
        # Loop through each commit in the input
        foreach ($Commit in $Commits) {
            # Get the commit hash and message
            $CommitMessage = git log -1 --format=%s $Commit

            # Get the list of files affected by the commit
            $Files = git diff-tree --no-commit-id --name-only -r $Commit

            # Loop through each file in the commit
            foreach ($File in $Files) {
                # Get the file size in bytes
                $FileSize = (Get-Item $File).Length

                # Format the file size to human-readable units
                $FileSizeFormatted = [math]::Round($FileSize / 1KB, 2)
                if ($FileSizeFormatted -ge 1MB) {
                    $FileSizeFormatted = [math]::Round($FileSize / 1MB, 2) + " MB"
                }
                elseif ($FileSizeFormatted -ge 1KB) {
                    $FileSizeFormatted = [math]::Round($FileSize / 1KB, 2) + " KB"
                }
                else {
                    $FileSizeFormatted = $FileSize + " B"
                }

                # Get the file content as it is stored in the commit
                $FileContent = git show $Commit:$File

                # Calculate the checksum for the file content using MD5 algorithm
                $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
                $utf8 = New-Object -TypeName System.Text.UTF8Encoding
                $Checksum = [System.BitConverter]::ToString ($md5.ComputeHash ($utf8.GetBytes ($FileContent)))

                # Create a custom object to store the file information
                $FileInfo = [PSCustomObject]@{
                    Commit = $Commit
                    Message = $CommitMessage
                    File = $File
                    Size = $FileSizeFormatted
                    Checksum = $Checksum
                }

                # Add the custom object to the output array
                $Output += $FileInfo
            }
        }
    }

    End {
        # Return the output array
        return $Output
    }
}
