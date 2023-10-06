function git-subtree-split-folder {

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
git-subtree-split-folder -ParentRepo "C:\Users\crbk01\Desktop\parent-repo" -FolderName "node" -BranchName "split"
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
