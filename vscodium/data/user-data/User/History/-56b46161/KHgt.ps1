<# Synopsis: Clone a git repository with a filter and merge all branches into one

# Example usage: Clone and merge a repository in folderQ with a filter and then sparsely checkout all branches in temporaryfolderx into a nested tree called CombinedTree

Clone-MergeRepository -FolderName "folderQ" -Filter "blob:none" -TempFolder "temporaryfolderx"

MergeOrCheckout-Branches -FolderName "temporaryfolderx" -TreeName "CombinedTree"

#>
function Clone-MergeRepository {
    param(
        # The name of the folder that contains the repository
        [string]$FolderName,

        # The filter to apply when cloning the repository
        [string]$Filter,

        # The name of the temporary folder to clone the repository into
        [string]$TempFolder
    )

    # Change directory to the folder that contains the repository
    Push-Location $FolderName

    # Get the current git remote URL
    $remote = git config --get remote.origin.url

    # Clone the repository with the filter into the temporary folder
    git clone --filter=$Filter $remote $TempFolder

    # Change directory to the temporary folder
    Push-Location $TempFolder

    # Get all the branch names from the remote repository
    $branches = git branch -r | Where-Object { $_ -notmatch "HEAD" } | ForEach-Object { $_.trim() }

    # Create a new branch with a prefix
    $newBranch = "Pruned$FolderName"
    git checkout -b $newBranch

    # Merge all the branches into the new branch
    foreach ($branch in $branches) {
        git merge --allow-unrelated-histories -X theirs $branch
    }

    # Push the new branch to the remote repository
    git push origin $newBranch

    # Change directory back to the original folder
    Pop-Location
    Pop-Location
}

# Synopsis: Merge or sparsely checkout all branches in a folder of repositories
function MergeOrCheckout-Branches {
    param(
        # The name of the folder that contains the repositories
        [string]$FolderName,

        # The name of the nested tree to create or use
        [string]$TreeName,

        # A switch to indicate whether to merge or sparsely checkout the branches
        [switch]$Merge
    )

    # Change directory to the folder that contains the repositories
    Push-Location $FolderName

    # Get all the subfolder names in the folder
    $subfolders = Get-ChildItem -Directory | ForEach-Object { $_.Name }

    # For each subfolder, assume it is a repository and perform the merge or checkout operation
    foreach ($subfolder in $subfolders) {
        Push-Location $subfolder

        # Get all the local branch names in the repository
        $branches = git branch | Where-Object { $_ -notmatch "\*" } | ForEach-Object { $_.trim() }

        if ($Merge) {
            # Merge all the branches into one branch with a prefix
            $newBranch = "Merged$subfolder"
            git checkout -b $newBranch

            foreach ($branch in $branches) {
                git merge --allow-unrelated-histories -X theirs $branch
            }
        }
        else {
            # Sparsely checkout all the branches into a nested tree with a prefix
            $newTree = "$TreeName/$subfolder"
            mkdir $newTree

            foreach ($branch in $branches) {
                git sparse-checkout set "$newTree/$branch"
                git checkout $branch
            }
        }

        Pop-Location
    }

    # Change directory back to the original folder
    Pop-Location
}

