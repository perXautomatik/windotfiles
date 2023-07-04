<# Synopsis: Push a local repository to a remote repository and filter a subdirectory into a separate branch
# Example usage: Push C:\Users\chris\AppData to D:\ToGit\AppData and filter Roaming\Vortex into a separate branch and pull from LargeINcluding branch

Push-FilterRepository -LocalPath "C:\Users\chris\AppData" -RemotePath "D:\ToGit\AppData" -Subdirectory "Roaming\Vortex" -Branch "LargeINcluding"

#>
function Push-FilterRepository {
    param(
        # The path to the local repository
        [string]$LocalPath,

        # The path to the remote repository
        [string]$RemotePath,

        # The name of the subdirectory to filter
        [string]$Subdirectory,

        # The name of the branch to pull from the remote repository
        [string]$Branch
    )

    # Change directory to the local repository
    Push-Location $LocalPath

    # Push all the branches to the remote repository
    git push --all $RemotePath

    # Change directory to the remote repository
    Push-Location $RemotePath

    # Filter the subdirectory into a separate branch
    git filter-branch -f --subdirectory-filter $Subdirectory -- --all

    # Pull in any new commits to the subtree from the local repository
    git subtree pull --prefix $Subdirectory "$LocalPath\.git" $Branch

    # Change directory back to the original location
    Pop-Location
    Pop-Location
}

