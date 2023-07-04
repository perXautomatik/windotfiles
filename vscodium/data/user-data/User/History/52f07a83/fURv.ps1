# Synopsis: This function initializes a git directory if it does not exist
# Parameters:
#   -Path: The path of the directory to initialize
function Initialize-GitDir {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    # Change the current directory to the given path
    cd $Path

    # Check if the directory is not a git directory
    if (-not (Test-Path ".git"))
    {
        # Initialize the git directory
        git init
    }
}

# Synopsis: This function gets all the .git folders in a given path recursively
# Parameters:
#   -Path: The path to search for .git folders
# Output:
#   An array of .git folder paths
function Get-GitFolders {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    # Get all the child items in the path that match the filter .git
    $GitFolders = Get-ChildItem -Recurse -Filter ".git" -Path $Path

    # Return an array of the full names of the .git folders
    return $GitFolders.FullName
}

# Synopsis: This function adds a submodule to a git repository
# Parameters:
#   -RepoPath: The path of the repository to add the submodule to
#   -SubmodulePath: The path of the submodule to add
function Add-Submodule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoPath,
        [Parameter(Mandatory=$true)]
        [string]$SubmodulePath
    )
    # Change the current directory to the repository path
    cd $RepoPath

    # Get the remote origin url of the repository
    $RepoUrl = git config --get remote.origin.url

    # Get the relative path of the submodule from the repository root
    $RelativePath = $SubmodulePath.Replace($RepoPath, "")

    # Get the remote origin url of the submodule
    $SubmoduleUrl = git config --get remote.origin.url -C $SubmodulePath

    # Check if the submodule path does not exist or is empty
    if (-not (Test-Path $SubmodulePath) -or ((Get-ChildItem $SubmodulePath).Count -eq 0))
    {
        # Initialize the submodule path as a git directory
        Initialize-GitDir $SubmodulePath

        # Add all the files in the submodule path to git
        git add . -C $SubmodulePath

        # Commit all the changes in the submodule path
        git commit -m "Initial commit" -C $SubmodulePath

        # Set the remote origin url of the submodule to be the same as the repository url plus the relative path
        git remote add origin "$RepoUrl/$RelativePath" -C $SubmodulePath

        # Push the changes to the remote origin url of the submodule
        git push origin master -C $SubmodulePath
    }

    # Add the submodule to the repository with its remote origin url and relative path
    git submodule add $SubmoduleUrl $RelativePath

    # Absorb the .git folder of the submodule into the repository's .git folder
    git submodule absorbgitdirs

}

# Synopsis: This function simulates a merge between two branches and identifies any conflicts
# Parameters:
#   -RepoPath: The path of the repository to simulate a merge on
#   -SourceBranch: The name of the source branch to merge from
#   -TargetBranch: The name of the target branch to merge into
function Simulate-Merge {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoPath,
        [Parameter(Mandatory=$true)]
        [string]$SourceBranch,
        [Parameter(Mandatory=$true)]
        [string]$TargetBranch
    )
    # Change the current directory to the repository path
    cd $RepoPath

    # Fetch all the changes from the remote origin url of the repository
    git fetch origin

    # Simulate a merge between the source branch and the target branch and output any conflicts or errors
    git merge --no-commit --no-ff origin/$SourceBranch origin/$TargetBranch 
}
