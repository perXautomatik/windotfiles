<#
cd $localrepopath ; Get-Sha1 | Get-FilesSha1 | Format-Table -AutoSize -Wrap -GroupBy Commit 

This will produce a table with file names, file sizes and checksums grouped by commit. For example:

   Commit: a1b2c3d4 - Added some features

File       Size Checksum                               
----       ---- --------                               
README.md  12 KB 4D-5F-6A-7B-8C-9D-AE-BF-C0-D1-E2-F3 
src/main.c 34 KB 0A-1B-2C-3D-4E-5F-6G-7H-8I-9J-K0-L1 
src/helper.c 21 KB F3-E2-D1-C0-BF-AE-9D-8C-7B-6A-5F-4D 
test/test.c 15 KB L1-K0-J9-I8-H7-G6-F5-E4-D3-C2-B1-A0 

   Commit: b2c3d4e5 - Fixed some bugs

File       Size Checksum                               
----       ---- --------                               
src/main.c 35 KB A0-B1-C2-D3-E4-F5-G6-H7-I8-J9-K0-L1 
src/helper.c 22 KB E2-F3-G4-H5-I6-J7-K8-L9-M0-N1-O2-P3 
test/test.c 16 KB P3-O2-N1-M0-L9-K8-J7-I6-H5-G4-F3-E2 
#>
# A function that takes a path to a local git repo as input
# and returns the list of commits on the current branch
# A function that takes a list of commits as input
# and prints file names, file sizes and checksums of files affected by each commit
Function Get-FilesSha1 {
    Param (
        # The list of commits
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$Commits,

        # The path to the local git repo
        [Parameter(Mandatory=$true)]
        [string]$RepoPath,

        # The flag to suppress errors and continue
        [switch]$Force
    )

    Begin {
        # Create an empty array to store the output
        $Output = @()

        # Check if the path is a valid git repository
        $IsGitRepo = git -C $RepoPath rev-parse 2>/dev/null

        # If not, throw an error or write a warning, depending on the Force flag
        if (-not $IsGitRepo) {
            if ($Force) {
                Write-Warning "The path $RepoPath is not a valid git repository. Skipping..."
                return
            }
            else {
                Throw "The path $RepoPath is not a valid git repository. Use -Force to ignore this error and continue."
            }
        }

        # Change the current directory to the repo path
        Set-Location $RepoPath

        # Get the current branch name
        $BranchName = git rev-parse --abbrev-ref HEAD
    }

    Process {
        # Loop through each commit in the input
        foreach ($Commit in $Commits) {
            # Check if the commit exists in the current branch
            $IsCommitValid = git merge-base --is-ancestor $Commit $BranchName 2>/dev/null

            # If not, throw an error or write a warning, depending on the Force flag
            if (-not $IsCommitValid) {
                if ($Force) {
                    Write-Warning "The commit $Commit does not exist in the current branch $BranchName. Skipping..."
                    continue
                }
                else {
                    Throw "The commit $Commit does not exist in the current branch $BranchName. Use -Force to ignore this error and continue."
                }
            }

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
