<# Synopsis: Commits every folder containing a sub repository with a custom date and message
# Parameters:
#   -Folder: The path to the folder containing sub repositories
# Example usage:
Commit-Every-Folder -Folder 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration'

#>
function Commit-Every-Folder {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Folder
    )

    # For each folder containing a file of esp
    Get-ChildItem -Path $Folder -Recurse -Filter '*.esp' | ForEach-Object {
        # Change directory to the folder
        Set-Location $_.Directory

        # Initialize git
        Git init

        # Run header gen for each file and tag it
        Get-ChildItem -File | ForEach-Object {
            Run-Header-Gen $_ # Assuming this is a custom function
            Git tag $_
        }

        # Initialize an empty array for t
        $t = @()

        # Add the date created, modified and accessed of each file to t
        Get-ChildItem -File | ForEach-Object {
            $t += $_.CreationTime, $_.LastWriteTime, $_.LastAccessTime
        }

        # Add the string to date conversion of the old filename to t
        $t += String-To-Date $OldFilename # Assuming this is a custom function

        # Set the commit environment date time to the maximum and minimum of t
        Set-CommitEnviormentDateTime -Committer (Get-Maximum $t) -Author (Get-Minimum $t) # Assuming these are custom functions

        # Commit with a message containing the size of each file
        Git commit -m "$(Get-ChildItem -File | ForEach-Object { "$($_.Name) $($_.Length / 1MB) MB $($_.Length / 1KB) KB $($_.Length) bytes" })"
    }
}

# Synopsis: Sets the commit environment date time for git
# Parameters:
#   -Committer: The date for the committer
#   -Author: The date for the author
function Set-CommitEnviormentDateTime {
    param(
        [Parameter(Mandatory=$true)]
        [datetime]$Committer,
        [Parameter(Mandatory=$true)]
        [datetime]$Author
    )

    # Set the GIT_COMMITTER_DATE and GIT_AUTHOR_DATE environment variables to the given dates in ISO 8601 format
    $env:GIT_COMMITTER_DATE = $Committer.ToString("yyyy-MM-ddTHH:mm:ss")
    $env:GIT_AUTHOR_DATE = $Author.ToString("yyyy-MM-ddTHH:mm:ss")
}

