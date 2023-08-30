<# Synopsis: Moves a .git folder to a different location and renames it
# Parameters:
#   -Errorus: The path to the original .git folder
#   -ToReplaceWith: The path to the new .git folder
# Example usage:
Move-And-Rename -Errorus 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration\Export-Inst-Choco\.git' `
                 -ToReplaceWith 'D:\Project Shelf\.git\modules\PowerShellProjectFolder\modules\scripts\modules\windowsAdmin\modules\Export-Inst-Choco'

#>
function Move-And-Rename {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Errorus,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ToReplaceWith
    )

    # Get the file info of the original .git folder
    $asFile = ([System.IO.FileInfo]$Errorus)

    # Get the target folder of the original .git folder
    $targetFolder = ($asFile | Select-Object Directory).Directory

    # Get the target path for renaming the original .git folder to x.git
    $target = Join-Path -Path $targetFolder -ChildPath 'x.git'

    # Move the original .git folder to the target path
    $asFile.MoveTo($target)

    # Get the file info of the new .git folder
    $asFile = ([System.IO.FileInfo]$ToReplaceWith)

    # Get the target path for renaming the new .git folder to .git
    $target = Join-Path -Path $targetFolder -ChildPath '.git'

    # Move the new .git folder to the target path
    $asFile.MoveTo($target)
}

