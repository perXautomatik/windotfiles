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
