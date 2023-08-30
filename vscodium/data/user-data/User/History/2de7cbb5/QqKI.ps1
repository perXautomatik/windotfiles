# Synopsis: Renames files based on their extensions or creation dates and moves them to a folder, then commits the folder to git
# Parameters:
#   -Folder: The path to the folder containing the files
#   -X: The path to the folder to move the renamed files to
function Rename-And-Move {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Folder,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$X
    )

    # Get all the files in the folder
    $files = Get-ChildItem -Path $Folder -File

    # For each file in the files array
    foreach ($file in $files) {
        # Get the extension and creation date of the file
        $extension = $file.Extension
        $date = $file.CreationTime

        # Try to rename the file based on its extension or date, without forcing or throwing errors
        try {
            Rename-Item -Path $file.FullName -NewName "$extension$file.Name" -ErrorAction Stop
        }
        catch {
            try {
                Rename-Item -Path $file.FullName -NewName "$date$file.Name" -ErrorAction Stop
            }
            catch {
                Write-Warning "Could not rename $file.Name"
            }
        }

        # Move the renamed file to the X folder, forcing overwrite if needed
        Move-Item -Path $file.FullName -Destination $X -Force
    }

    # Change directory to the X folder
    Set-Location $X

    # Initialize git and add all files
    Git init
    Git add .

    # Get the total size of the files in the X folder and concatenate it as a string
    $size = (Get-ChildItem -File | Measure-Object -Sum Length).Sum / 1MB
    $message = "$size MB"

    # Commit the changes with the message
    Git commit -m $message
}

# Example usage:
Rename-And-Move -Folder 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration' `
                 -X 'D:\Project Shelf\.git\modules\PowerShellProjectFolder\modules\scripts\modules\windowsAdmin\modules\Export-Inst-Choco'
