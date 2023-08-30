<# Synopsis: Filter a git repository with a tree filter that creates a folder if it does not exist and renames a file if it exists
# Example usage: Filter a git repository in C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell with a tree filter that creates a PSReadline folder if it does not exist and renames Psreadline/ConsoleHost_history.txt to PSReadline/ConsoleHost_history.txt if it exists

Filter-RepositoryWithRename -Path "C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell" -FolderName "PSReadline" -FileName "ConsoleHost_history.txt"

#>
function Filter-RepositoryWithRename {
    param(
        # The path to the git repository
        [string]$Path,

        # The name of the folder to create or use
        [string]$FolderName,

        # The name of the file to rename
        [string]$FileName
    )

    # Change directory to the git repository
    Push-Location $Path

    # Define the tree filter as a script block with the variables
    $filter = {
        if (-not (Test-Path $FolderName)) {
            New-Item -ItemType Directory -Path $FolderName
        }
        if (Test-Path "$FolderName/$FileName") {
            Rename-Item -Path "$FolderName/$FileName" -NewName "$FolderName/$FileName"
        }
    }

    # Filter the git repository with the tree filter
    git filter-branch -f --tree-filter $filter

    # Change directory back to the original location
    Pop-Location
}

