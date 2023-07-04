<# Synopsis: Splits a folder as a branch and pushes it to a remote, then removes the folder from the current branch
# Parameters:
#   -Leaf: The path to the folder to split
#   -OtherBranchName: The name of the branch to create
#   -OtherRemote: The name of the remote to push to
# Example usage:
Split-And-Remove -Leaf 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco'

#>
function Split-And-Remove {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Leaf,
        [Parameter(Mandatory=$false)]
        [string]$OtherBranchName,
        [Parameter(Mandatory=$false)]
        [string]$OtherRemote
    )

    # If the leaf parameter is null, use the current directory and change to the parent directory
    if ($null -eq $Leaf) {
        $Leaf = $pwd
        Set-Location ..
    }

    # If the other branch name and remote parameters are null, use the git pathToBranchpushOrig alias with the leaf parameter
    if ($null -eq $OtherBranchName -and $null -eq $OtherRemote) {
        git pathToBranchpushOrig $Leaf # Assuming this is a custom alias
    }
    else {
        # If the other remote parameter is null, use 'remote' as the default value
        $Remote = if ($null -eq $OtherRemote) { 'remote' } else { $OtherRemote }

        # If the other branch name parameter is null, use 'remote' as the default value
        $BranchName = if ($null -eq $OtherBranchName) { 'remote' } else { $Leaf }

        # Split the leaf folder as a branch and push it to the remote
        git subtree split -P $Leaf -b $BranchName
        git push $BranchName $Remote
    }

    # Remove the leaf folder from the cache
    git rm -rf --cached $Leaf

    # Commit the changes with a message
    git commit -m "[chore] after subtree split; removing $Leaf folder"
}

