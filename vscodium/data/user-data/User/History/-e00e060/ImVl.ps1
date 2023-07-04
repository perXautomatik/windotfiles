<#
.SYNOPSIS
Joins multiple script files from a source path into a single file with delimiters.

.DESCRIPTION
This function joins multiple script files from a source path into a single file with delimiters that contain the relative paths of the source files. The delimiters can be used to split the joined file back into separate files with the same folder structure.

.PARAMETER SourcePath
The path where the script files are located.

.PARAMETER DestinationFile
The path of the file where the script files will be joined.

.PARAMETER Delimiter
The string that will separate the script files and contain the relative paths. The string should have a placeholder {0} for the relative path.
#>
function Join-ScriptFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SourcePath,

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationFile,

        [Parameter(Mandatory = $true)]
        [string]
        $Delimiter
    )

    # Get all the script files from the source path recursively
    $scriptFiles = Get-ChildItem -Path $SourcePath -Filter *.ps1 -Recurse

    # Loop through each script file and append its content to the destination file with the delimiter
    foreach ($scriptFile in $scriptFiles) {
        # Get the relative path of the script file
        $relativePath = $scriptFile.FullName.Replace($SourcePath, "")

        # Write the delimiter with the relative path to the destination file
        $Delimiter -f $relativePath | Out-File -FilePath $DestinationFile -Append

        # Write the content of the script file to the destination file
        Get-Content -Path $scriptFile.FullName | Out-File -FilePath $DestinationFile -Append
    }
}

<#
.SYNOPSIS
Splits a joined script file into separate files with a folder structure according to the delimiters.

.DESCRIPTION
This function splits a joined script file into separate files with a folder structure according to the delimiters that contain the relative paths of the source files. The delimiters should have been created by the Join-ScriptFiles function.

.PARAMETER SourceFile
The path of the file where the script files are joined.

.PARAMETER DestinationPath
The path where the script files will be split.

.PARAMETER DelimiterPattern
The regular expression pattern that matches the delimiters and captures the relative paths as groups.
#>
function Split-ScriptFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $SourceFile,

        [Parameter(Mandatory = $true)]
        [string]
        $DestinationPath,

        [Parameter(Mandatory = $true)]
        [string]
        $DelimiterPattern
    )

    # Read the content of the source file as a single string
    $sourceContent = Get-Content -Path $SourceFile -Raw

    # Split the source content by the delimiter pattern and capture the relative paths as groups
    $splitContent = $sourceContent -split $DelimiterPattern

    # Loop through each split content and skip the first empty one
    for ($i = 1; $i -lt $splitContent.Count; $i += 2) {
        # Get the relative path of the script from the first group
        $relativePath = $splitContent[$i]

        # Get the script content from the second group
        $scriptContent = $splitContent[$i + 1]

        # Join the destination path with the relative path to get the full path of the script
        $scriptPath = Join-Path -Path $destinationPath -ChildPath $relativePath

        # Create the parent directory of the script if it does not exist
        $scriptDirectory = Split-Path -Path $scriptPath -Parent
        if (-not (Test-Path -Path $scriptDirectory)) {
            New-Item -Path $scriptDirectory -ItemType Directory | Out-Null
        }

        # Write the script content to the script path
        Set-Content -Path $scriptPath -Value $scriptContent
    }
}
