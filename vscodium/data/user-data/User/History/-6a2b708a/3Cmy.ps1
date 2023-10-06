
. .\Add-Node.ps1
. .\Split-Folder.ps1

. .\Push-Branch.ps1
. .\Remove-And-Add-Folder.ps1

# Define the parameters for the script
param (
    # The path to the local repository
    [string]$LocalRepo,

    # The path or URL of the remote node
    [string]$Node,

    # The path to the parent repository
    [string]$ParentRepo,

    # The name of the folder to split
    [string]$FolderName,

    # The name of the branch to create
    [string]$BranchName,

    # The path or URL of the remote repository
    [string]$RemoteRepo,

    # The name of the remote branch
    [string]$RemoteBranch
)

# Add the remote node to the local repository
Git-NodeRemoteAddToLocal -LocalRepo $LocalRepo -Node $Node

# Split the folder from the parent repository into a separate branch
git-subtree-split-folder -ParentRepo $ParentRepo -FolderName $FolderName -BranchName $BranchName

# Push the contents of the branch to the remote repository
Git-PushBranchToRemote -LocalRepo $LocalRepo -RemoteRepo $RemoteRepo -LocalBranch $BranchName -RemoteBranch $RemoteBranch

# Remove the folder from the parent repository and add it back as a subtree from the remote repository
Git-Rm_AddSubtree -ParentRepo $ParentRepo -FolderName $FolderName -RemoteRepo $RemoteRepo -RemoteBranch $RemoteBranch
