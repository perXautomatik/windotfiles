<# Synopsis: Adds a folder as a submodule to the current git repository
# Parameters:
#   -Errorus: The path to the .git folder of the submodule

# Example usage:
Add-Submodule -Errorus 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git'
#>
function Add-Submodule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Errorus
    )

    # Get the file info of the .git folder
    $asFile = ([System.IO.FileInfo]$Errorus)

    # Get the target folder of the submodule
    $targetFolder = ($asFile | select Directory).Directory

    # Get the name of the target folder
    $name = $targetFolder.Name

    # Get the parent path of the target folder
    $path = $targetFolder.Parent.FullName

    # Define a function to change directory to the root of the current git repository
    function git-root {
        $gitrootdir = (git rev-parse --show-toplevel)
        if ($gitrootdir) {
            Set-Location $gitrootdir
        }
    }

    # Save the current location and change directory to the .git folder of the submodule
    Push-Location
    Set-Location $Errorus

    # Get the remote URL of the submodule
    $ref = (git remote get-url origin)

    # Change directory to the parent path of the target folder
    Set-Location $path

    # Change directory to the root of the current git repository
    Git-root

    # Get the relative path of the target folder from the root of the current git repository
    $relative = ((Resolve-Path -Path $targetFolder.FullName -Relative) -replace([regex]::Escape('\'),'/')).Substring(2)

    # Add the submodule with the remote URL and the relative path
    Git submodule add $ref $relative

    # Commit the changes with a message
    git commit -m "as submodule $relative"

    # Absorb the .git folder of the submodule into the current git repository
    Git submodule absorbgitdirs $relative

    # Restore the previous location
    Pop-Location
}
