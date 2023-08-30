<# Synopsis: Clone a remote repository into a non-empty directory

# Example usage: Clone a remote repository into a non-empty directory called MyProject

Clone-NonEmptyDirectory -Path "C:\Users\user\Documents\MyProject" -Remote "https://github.com/user/repo.git"
#>
function Clone-NonEmptyDirectory {
    param(
        # The path to the non-empty directory
        [string]$Path,

        # The URL of the remote repository
        [string]$Remote
    )

    # Change directory to the non-empty directory
    Push-Location $Path

    # Initialize a git repository in the directory
    git init

    # Add the remote repository as origin
    git remote add origin $Remote

    # Fetch the remote repository
    git fetch

    # Reset the local repository to the remote master branch
    git reset origin/master

    # Checkout the remote master branch and set it as upstream
    git checkout -t origin/master

    # Change directory back to the original location
    Pop-Location
}
