<#
.SYNOPSIS
Packs the files and folders in the current directory into bsa archives.

.DESCRIPTION
This function packs the files and folders in the current directory into bsa archives, using the bsarch.exe tool. The function expects to find only one esp or esm file in the current directory, and uses its name as the prefix for the bsa archives. The function also groups the files and folders by their types, such as textures, meshes, music and sound, and uses different options for packing them.

.PARAMETER BsarchPath
The path of the bsarch.exe tool.

.PARAMETER FomodPath
The path of the fomod folder where the other files or folders will be moved.
#>
function Pack-Bsa {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $BsarchPath,

        [Parameter(Mandatory = $true)]
        [string]
        $FomodPath
    )

    # Get the current location
    $current = Get-Location

    # Get the esp or esm file in the current location
    $esp = Get-ChildItem -Path $current | Where-Object { $_.Name -like '*.esp' }
    $esm = Get-ChildItem -Path $current | Where-Object { $_.Name -like '*.esm' }

    # Count the number of esp or esm files
    $espNr = ($esp).count
    $esmNr = ($esm).count

    # Define the patterns for different types of directories
    $includedDirectory = "textures|meshes"
    $textureMeshes = Get-ChildItem -Path $current -Directory | Where-Object Name -Match $includedDirectory

    $includedDirectory = "music|sound"
    $SoundMusic = Get-ChildItem -Path $current -Directory | Where-Object Name -Match $includedDirectory

    # Initialize a variable for the prefix of the bsa archives
    $s = ""

    # Check if there is only one esp or esm file in the current location
    if (($espNr -eq 1) -or ($esmNr -eq 1)) {

        if ($espNr -eq 1) {
            # Use the esp file name without extension as the prefix
            $s = $esp | Select-Object -ExcludeProperty name | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) -join [Environment]::NewLine }
        }

        if ($esmNr -eq 1) {
            # Use the esm file name without extension as the prefix
            $s  = $esm | Select-Object -ExcludeProperty name | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_) -join [Environment]::NewLine }
        }
    }
    else {
        # Throw an error if there is no or more than one esp or esm file
        throw "Expected only one esp or esm file in the current location"
    }

    # Loop through each texture or mesh directory and pack it into a bsa archive with x options
    if ($textureMeshes -ne $null) {
        $textureMeshes | ForEach-Object {
            & "$BsarchPath" pack $_ ($s + " - " + $_ + ".bsa") -z -fnv -share -mt
        }
    }

    # Loop through each music or sound directory and pack it into a bsa archive with y options
    if ($SoundMusic -ne $null) {
        $SoundMusic | ForEach-Object {
            & "$BsarchPath" pack $_ ($s + " - " + $_ + ".bsa") -fnv -share -mt
        }
    }

    # Move any other file or folder to the fomod folder
    Get-ChildItem -Path $current | Where-Object { $_.Name -notlike '*.esp' -and $_.Name -notlike '*.esm' } | Move-Item -Destination (Join-Path -Path $FomodPath)

}
