<#
.SYNOPSIS
This script recursively identifies nested git repositories and removes them if they are not already 
added as submodules to the parent repository.
#>

function Remove-NestedGitRepos {
    # Get the path of the parent repository as a parameter
    param (
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    # Check if the path is a valid git repository
    if (-not (Test-Path -Path (Join-Path -Path $path -ChildPath ".git"))) {
        # Throw an error if no git repository found
        throw "No git repository found at $path"
    }

    # Get the subfolders of the path recursively
    $subfolders = Get-ChildItem -Path $path -Directory -Recurse

    # Loop through each subfolder
    foreach ($subfolder in $subfolders) {
        # Check if the subfolder is a git repository
        if (Test-Path -Path (Join-Path -Path $subfolder.FullName -ChildPath ".git")) {
            # Check if the subfolder is already added as a submodule to the parent repository
            if (-not (git submodule status $subfolder.FullName)) {
                # Remove the subfolder as a nested git repository
                Remove-Item -Path $subfolder.FullName -Recurse -Force
                Write-Host "Removed nested git repository at $subfolder.FullName"
            }
        }
    }

    # Return 0 if only one git repository found in the whole tree
    return 0
}
