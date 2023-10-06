
function Git-NodeRemoteAddRemoteToLocal {
# Function to add a remote node to a local repository
<#
.SYNOPSIS
Adds a remote node to a local repository.

.PARAMETER LocalRepo
The path to the local repository.

.PARAMETER Node
The path or URL of the remote node.

.EXAMPLE
Git-NodeRemoteAddRemoteToLocal -LocalRepo "C:\Users\crbk01\Desktop\lib-repo" -Node "https://github.com/nodejs/node.git"
#>
    [CmdletBinding()]
    param (
        # Validate that the local repository path exists and is a directory
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$LocalRepo,

        # Validate that the node path or URL is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$Node
    )

    # Change the current directory to the local repository
    Set-Location $LocalRepo

    # Add the remote node using git
    git remote add node $Node

    # Check for any errors and write them to the console
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to add remote node: $Node"
    }
}

function Split-Folder {
# Function to split a folder from a parent repository into a separate branch
<#
.SYNOPSIS
Splits a folder from a parent repository into a separate branch.

.PARAMETER ParentRepo
The path to the parent repository.

.PARAMETER FolderName
The name of the folder to split.

.PARAMETER BranchName
The name of the branch to create.

.EXAMPLE
Split-Folder -ParentRepo "C:\Users\crbk01\Desktop\parent-repo" -FolderName "node" -BranchName "split"
#>
    [CmdletBinding()]
    param (
        # Validate that the parent repository path exists and is a directory
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$ParentRepo,

        # Validate that the folder name is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$FolderName,

        # Validate that the branch name is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$BranchName
    )

    # Change the current directory to the parent repository
    Set-Location $ParentRepo

    # Use the subtree split command and put the folder in a separate branch using git
    git subtree split --prefix=$FolderName -b $BranchName

    # Check for any errors and write them to the console
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to split folder: $FolderName"
    }
}

function Push-Branch {

# Function to push the contents of a branch to a remote repository
<#
.SYNOPSIS
Pushes the contents of a branch to a remote repository.

.PARAMETER LocalRepo
The path to the local repository.

.PARAMETER RemoteRepo
The path or URL of the remote repository.

.PARAMETER LocalBranch
The name of the local branch.

.PARAMETER RemoteBranch
The name of the remote branch.

.EXAMPLE
Push-Branch -LocalRepo "C:\Users\crbk01\Desktop\lib-repo" -RemoteRepo "https://github.com/crbk01/lib-repo.git" -LocalBranch "split" -RemoteBranch "master"
#>
    [CmdletBinding()]
    param (
        # Validate that the local repository path exists and is a directory
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$LocalRepo,

        # Validate that the remote repository path or URL is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$RemoteRepo,

        # Validate that the local branch name is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$LocalBranch,

        # Validate that the remote branch name is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$RemoteBranch
    )

    # Change the current directory to the local repository
    Set-Location $LocalRepo

    # Push the contents of the local branch to the remote repository using git
    git push $RemoteRepo $LocalBranch:$RemoteBranch

    # Check for any errors and write them to the console
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to push branch: $LocalBranch"
    }
}

function Remove-And-Add-Folder {

# Function to remove a folder from a parent repository and add it back as a subtree from a remote repository
<#
.SYNOPSIS
Removes a folder from a parent repository and adds it back as a subtree from a remote repository.

.PARAMETER ParentRepo
The path to the parent repository.

.PARAMETER FolderName
The name of the folder to remove and add back.

.PARAMETER RemoteRepo
The path or URL of the remote repository.

.PARAMETER RemoteBranch
The name of the remote branch.

.EXAMPLE
Remove-And-Add-Folder -ParentRepo "C:\Users\crbk01\Desktop\parent-repo" -FolderName "node" -RemoteRepo "https://github.com/crbk01/lib-repo.git" -RemoteBranch "master"
#>
    [CmdletBinding()]
    param (
        # Validate that the parent repository path exists and is a directory
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$ParentRepo,

        # Validate that the folder name is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$FolderName,

        # Validate that the remote repository path or URL is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$RemoteRepo,

        # Validate that the remote branch name is not null or empty
        [ValidateNotNullOrEmpty()]
        [string]$RemoteBranch
    )

    # Change the current directory to the parent repository
    Set-Location $ParentRepo

    # Remove the folder from the parent repository using git
    git remote add $FolderName $RemoteRepo
    git rm -r $FolderName
    git add -A
    git commit -am "removing $FolderName folder"

    # Check for any errors and write them to the console
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to remove folder: $FolderName"
    }

    # Add the folder back as a subtree from the remote repository using git
    git subtree add --prefix=$FolderName $RemoteRepo $RemoteBranch

    # Check for any errors and write them to the console
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to add folder: $FolderName"
    }
}       

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
Git-NodeRemoteAddRemoteToLocal -LocalRepo $LocalRepo -Node $Node

# Split the folder from the parent repository into a separate branch
Split-Folder -ParentRepo $ParentRepo -FolderName $FolderName -BranchName $BranchName

# Push the contents of the branch to the remote repository
Push-Branch -LocalRepo $LocalRepo -RemoteRepo $RemoteRepo -LocalBranch $BranchName -RemoteBranch $RemoteBranch

# Remove the folder from the parent repository and add it back as a subtree from the remote repository
Remove-And-Add-Folder -ParentRepo $ParentRepo -FolderName $FolderName -RemoteRepo $RemoteRepo -RemoteBranch $RemoteBranch
