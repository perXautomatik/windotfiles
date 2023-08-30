<#
.SYNOPSIS
Joins multiple script files from a source path into a single file with delimiters.

.DESCRIPTION
This function joins multiple script files from a source path into a single file with delimiters that contain the relative paths of the source files. The delimiters can be used to split the joined file back into separate files with the same folder structure.

.PARAMETER SourcePath
The path where the script files are located.

.PARAMETER DestinationFile
The path of the file where the script files will be joined. If not specified, it will be a file named JoinedScripts.ps1 in the same directory as the source path.

.PARAMETER Delimiter
The string that will separate the script files and contain the relative paths. The string should have a placeholder {0} for the relative path.
#>
function Join-ScriptFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]
        $SourcePath,

        [Parameter(Mandatory = $false)]
        [ValidateScript({-not (Test-Path -Path $_ -PathType Container)})]
        [string]
        $DestinationFile,

        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ -match "{0}"})]
        [string]
        $Delimiter
    )

    # If destination file is not specified, use a default name in the same directory as the source path
    if (-not $DestinationFile) {
        $DestinationFile = Join-Path -Path $SourcePath -ChildPath "JoinedScripts.ps1"
    }

    # Get all the script files from the source path recursively
    $scriptFiles = Get-ChildItem -Path $SourcePath -Filter *.ps1 -Recurse

    # Loop through each script file and append its content to the destination file with the delimiter
    foreach ($scriptFile in $scriptFiles) {
        # Get the relative path of the script file
        $relativePath = $scriptFile.FullName.Replace($SourcePath, "")

        # Write the delimiter with the relative path to the destination file
        try {
            $Delimiter -f $relativePath | Out-File -FilePath $DestinationFile -Append -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to write delimiter for $($scriptFile.Name)"
            continue
        }

        # Write the content of the script file to the destination file
        try {
            Get-Content -Path $scriptFile.FullName | Out-File -FilePath $DestinationFile -Append -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to write content for $($scriptFile.Name)"
            continue
        }
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
The path where the script files will be split. If not specified, it will be a directory named Scripts in the same directory as the source file.

.PARAMETER DelimiterPattern
The regular expression pattern that matches the delimiters and captures the relative paths as groups.
#>
function Split-ScriptFiles {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]
        $SourceFile,

        [Parameter(Mandatory = $false)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]
        $DestinationPath,

        [Parameter(Mandatory = $true)]
        [ValidateScript({$_ -match "\(.+\)"})]
        [string]
        $DelimiterPattern
    )

    # If destination path is not specified, use a default name in the same directory as the source file
    if (-not $DestinationPath) {
        $DestinationPath = Join-Path -Path (Split-Path -Path $SourceFile) -ChildPath "Scripts"
    }

    # Read the content of the source file as a single string
    try {
        $sourceContent = Get-Content -Path $SourceFile -Raw -ErrorAction Stop
    }
    catch {
        Write-Error "Failed to read content from $SourceFile"
        return
    }

    # Split the source content by the delimiter pattern and capture the relative paths as groups
    try {
        $splitContent = $sourceContent -split $DelimiterPattern #-ErrorAction Stop
    }
    catch {
        Write-Error "Failed to split content by $DelimiterPattern"
        return
    }

    # Loop through each split content and skip the first empty one
    for ($i = 1; $i -lt $splitContent.Count; $i += 2) {
        # Get the relative path of the script from the first group
        $relativePath = $splitContent[$i]

        # Get the script content from the second group
        $scriptContent = $splitContent[$i + 1]

        # Join the destination path with the relative path to get the full path of the script
        try {
            $scriptPath = Join-Path -Path $destinationPath -ChildPath $relativePath -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to join path for $relativePath"
            continue
        }

        # Create the parent directory of the script if it does not exist
        $scriptDirectory = Split-Path -Path $scriptPath -Parent
        if (-not (Test-Path -Path $scriptDirectory)) {
            try {
                New-Item -Path $scriptDirectory -ItemType Directory -ErrorAction Stop | Out-Null
            }
            catch {
                Write-Error "Failed to create directory for $scriptDirectory"
                continue
            }
        }

        # Write the script content to the script path
        try {
            Set-Content -Path $scriptPath -Value $scriptContent -ErrorAction Stop
        }
        catch {
            Write-Error "Failed to write content to $scriptPath"
            continue
        }
    }
}
