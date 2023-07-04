# Import the previous functions from a file
. .\Functions.ps1

# Change the current directory to the given path
$Path = 'B:\Users\chris\Documents\'
cd $Path

# Initialize the directory as a git directory if it does not exist
Initialize-GitDir $Path

# Get all the .git folders in the path recursively
$GitFolders = Get-GitFolders $Path

# Sort the .git folders by their depth in descending order
$GitFolders = $GitFolders | Sort-Object -Property @{Expression = {$_.Split('\').Count}} -Descending

# Loop through each .git folder
foreach ($GitFolder in $GitFolders)
{
    # Get the parent directory of the .git folder
    $ParentDir = Split-Path -Parent $GitFolder

    # Get the remote origin url of the parent directory
    $ParentUrl = git config --get remote.origin.url -C $ParentDir

    # Get the submodules of the parent directory
    $Submodules = git submodule status -C $ParentDir

    # Loop through each submodule
    foreach ($Submodule in $Submodules)
    {
        # Get the relative path of the submodule from the parent directory
        $SubmoduleRelativePath = $Submodule.Path

        # Get the absolute path of the submodule
        $SubmodulePath = Join-Path -Path $ParentDir -ChildPath $SubmoduleRelativePath

        # Check if the submodule is damaged by looking for a minus sign at the beginning of its status
        if ($Submodule.Status.StartsWith("-"))
        {
            # Throw an error and exclude the submodule from the original queue
            throw "The submodule at $SubmodulePath is damaged and cannot be added."
            continue
        }

        # Get the remote origin url of the submodule
        $SubmoduleUrl = git config --get remote.origin.url -C $SubmodulePath

        # Check if the submodule url is not equal to the parent url plus the relative path
        if ($SubmoduleUrl -ne "$ParentUrl/$SubmoduleRelativePath")
        {
            # Add the submodule to the parent directory with its remote origin url and relative path
            Add-Submodule -RepoPath $ParentDir -SubmodulePath $SubmodulePath
        }
    }

    # Simulate a merge between master and dev branches and identify any conflicts
    Simulate-Merge -RepoPath $ParentDir -SourceBranch master -TargetBranch dev
}
