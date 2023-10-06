function Git-Rm_AddSubtree {

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
Git-Rm_AddSubtree -ParentRepo "C:\Users\crbk01\Desktop\parent-repo" -FolderName "node" -RemoteRepo "https://github.com/crbk01/lib-repo.git" -RemoteBranch "master"
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
