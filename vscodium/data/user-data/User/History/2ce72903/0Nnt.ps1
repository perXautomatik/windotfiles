
function checkIfRepo ($path)
{

      # Check if the path is a valid git repository
      if (-not (Test-Path -Path (Join-Path -Path $path -ChildPath ".git"))) {
       # Throw an error if no git repository found
       throw "No git repository found at $path"
   }

}

<#
.SYNOPSIS
This script recursively identifies nested git repositories and removes them if they are not already 
added as submodules to the parent repository.

.DESCRIPTION
This script takes a path of a parent git repository as a parameter and uses git commands to check if any of its subfolders are also git repositories. If so, it checks if they are already added as submodules to the parent repository using git submodule status command. If not, it removes them using Remove-Item cmdlet with Recurse and Force switches. It also outputs a message for each nested git repository that is removed. It returns 0 if only one git repository is found in the whole tree.

.PARAMETER path
The path of the parent git repository.

.EXAMPLE
Remove-NestedGitRepos -path "C:\Users\user\Documents\MyProject"

This example removes any nested git repositories in the "C:\Users\user\Documents\MyProject" folder that are not added as submodules to the parent repository.
#>
function Remove-NestedGitRepos {
    # Get the path of the parent repository as a parameter
    param (
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    checkIfRepo -path $path

    # Try to execute the script block
    try {
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
    catch {
        # Catch any errors and write them to the error stream
        Write-Error $_.Exception.Message
    }
}