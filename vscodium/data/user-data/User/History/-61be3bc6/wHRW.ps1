<#
.SYNOPSIS
Converts a gitmodules file into a custom object with submodule properties.

.DESCRIPTION
This function converts a gitmodules file into a custom object with submodule properties, such as url and path. The function uses two helper functions, Split-TextByRegex and keyPairTo-PsCustom, to parse the file and create the object.

.PARAMETER GitmodulesPath
The path of the gitmodules file.

.PARAMETER SubmoduleRegex
The regular expression that matches the submodule sections in the file.
#>
function Convert-Gitmodules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $GitmodulesPath,

        [Parameter(Mandatory = $true)]
        [string]
        $SubmoduleRegex
    )

    # Bypass the execution policy for the current process
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

    # Import the helper functions from their paths
    . "Z:\Project Shelf\Archive\ps1\Split-TextByRegex.ps1"
    . "Z:\Project Shelf\Archive\ps1\keyPairTo-PsCustom.ps1"

    # Change the current location to the directory of the gitmodules file
    Set-Location -Path (Split-Path -Path $GitmodulesPath)

    # Split the text of the gitmodules file by the submodule regex
    $TextRanges = Split-TextByRegex -path $GitmodulesPath -regx $SubmoduleRegex

    # Convert each text range into a custom object with key-value pairs
    $TextRanges | ForEach-Object { keyPairTo-PsCustom -keyPairStrings $_.values }
}
