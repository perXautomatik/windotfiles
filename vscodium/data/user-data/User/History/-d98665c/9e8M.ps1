<# Synopsis: Removes a folder from the git cache and commits the changes
# Parameters:
#   -Errorus: The path to the .git folder of the folder to remove
# Example usage:
Remove-From-Cache -Errorus 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git'

#>
function Remove-From-Cache {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Errorus
    )

    # Get the file info of the .git folder
    $asFile = ([System.IO.FileInfo]$Errorus)

    # Get the target folder of the .git folder
    $targetFolder = ($asFile | Select-Object Directory).Directory

    # Get the name of the target folder
    $name = $targetFolder.Name

    # Get the parent path of the target folder
    $path = $targetFolder.Parent.FullName

    # Save the current location and change directory to the parent path
    Push-Location
    Set-Location $path

    # Remove the target folder from the git cache
    git rm -r --cached $name

    # Commit the changes with a message
    git commit -m "forgot about $name"

    # Restore the previous location
    Pop-Location
}

