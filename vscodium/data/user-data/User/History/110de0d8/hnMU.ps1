<#i would like to make my own rename function in powershell that i will use as a alias to easier remeber the features of rename-item, the functions need to accept pipline input from eather a file object or a file path, the file path might be a real exsisting path or a relative path or even just a string, the parameters should be "change_extension" (from,to) append_extension , what-if , name ( replace current basename with provided name ) , basename (same as name) , extension (takes a extension and sets it regardles if the file had a extension or not) , you should be able to to specify several paramters at the same time; like name, extension, append_extension, what-if#>
function Rename-MyItem {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [ValidateScript({Test-Path $_})]
        [string]$Path,

        [Parameter()]
        [string]$Name,

        [Parameter()]
        [string]$BaseName,

        [Parameter()]
        [string]$Extension,

        [Parameter()]
        [string[]]$Change_Extension,

        [Parameter()]
        [string]$Append_Extension
    )

    begin {
        # Initialize some variables
        $newName = ""
        $oldName = ""
    }

    process {
        # Get the full path of the item
        $fullPath = Resolve-Path -Path $Path

        # Get the old name and extension of the item
        $oldName = Split-Path -Path $fullPath -Leaf
        $oldExtension = [System.IO.Path]::GetExtension($oldName)

        # Check if any of the parameters are specified
        if ($Name) {
            # Use the Name parameter as the new name
            $newName = $Name
        }
        elseif ($BaseName) {
            # Use the BaseName parameter as the new name without extension
            $newName = $BaseName
            # Add the old extension if it exists
            if ($oldExtension) {
                $newName += $oldExtension
            }
        }
        elseif ($Extension) {
            # Use the Extension parameter as the new extension
            # Remove the dot if it exists
            $newExtension = $Extension.TrimStart(".")
            # Get the old name without extension
            $oldBaseName = [System.IO.Path]::GetFileNameWithoutExtension($oldName)
            # Combine the old name and the new extension
            $newName = "$oldBaseName.$newExtension"
        }
        elseif ($Change_Extension) {
            # Use the Change_Extension parameter as an array of from and to extensions
            # Validate that the array has two elements
            if ($Change_Extension.Count -eq 2) {
                # Remove the dots if they exist
                $fromExtension = $Change_Extension[0].TrimStart(".")
                $toExtension = $Change_Extension[1].TrimStart(".")
                # Replace the old extension with the new one using regex
                $newName = $oldName -replace "\.$fromExtension$", ".$toExtension"
            }
            else {
                # Write an error message if the array is not valid
                Write-Error "The Change_Extension parameter must have two elements: from and to extensions."
                return
            }
        }
        else {
            # Write an error message if none of the parameters are specified
            Write-Error "You must specify one of the following parameters: Name, BaseName, Extension, Change_Extension."
            return
        }

        # Check if the Append_Extension parameter is specified
        if ($Append_Extension) {
            # Use the Append_Extension parameter as an additional extension to append to the new name
            # Remove the dot if it exists
            $appendExtension = $Append_Extension.TrimStart(".")
            # Add a dot and append the extension to the new name
            $newName += ".$appendExtension"
        }

        # Check if the new name is different from the old name
        if ($newName -ne $oldName) {
            # Rename the item using the Rename-Item cmdlet
            # Use the -WhatIf parameter to show what would happen
            Rename-Item -Path $fullPath -NewName $newName -WhatIf:$WhatIfPreference
        }
        else {
            # Write a message if the new name is the same as the old name
            Write-Verbose "The new name is the same as the old name. No action taken."
        }
    }

    end {
        # Write a message when the function is done
        Write-Verbose "The Rename-MyItem function is done."
    }
}
