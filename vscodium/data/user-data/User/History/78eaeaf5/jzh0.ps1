function Git-PushBranchToRemote {

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
Git-PushBranchToRemote -LocalRepo "C:\Users\crbk01\Desktop\lib-repo" -RemoteRepo "https://github.com/crbk01/lib-repo.git" -LocalBranch "split" -RemoteBranch "master"
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
