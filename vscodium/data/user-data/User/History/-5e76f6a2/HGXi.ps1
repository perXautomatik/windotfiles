<#
.Synopsis
    A script that moves and renames files in a list of paths to the smallest file in the list.
.Description
    This script takes a file name as a parameter, which contains a list of paths to files. It then sorts the files by size and gets the smallest file as the target. It then moves and renames each file in the list to the target with force, and commits the changes with a message containing the old name of the file.
.Parameter FileName
    The name of the file that contains the list of paths to files. The file should have one path per line.
.Example
    PS C:\> .\script.ps1 -FileName "C:\paths.txt"
    This will run the script with the file name "C:\paths.txt" as the parameter.
#>
param (
    # The name of the file that contains the list of paths to files
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path -Path $_ -PathType Leaf},ErrorMessage = "15, {0}.")]
    [string]$FileName
)

# A function that reads the file content and splits it by line
function Get-Paths {
    param (
        # The name of the file to read
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf},ErrorMessage = "24, {0}.")]
        [string]$FileName
    )
    # Return an array of paths from the file content
    return (Get-Content -Path $FileName | Out-String) -split "`n"
}

# A function that gets all the files in an array of paths and sorts them by size
function Get-Files {
    param (
        # The array of paths to process
        [Parameter(Mandatory=$true)]
        [array]$paths
    )
    # Return an array of files sorted by size
    return $paths | Get-ChildItem -File | Sort-Object -Property Length
}

# A function that moves and renames a file to a target with force and commits the change
function Move-And-Rename {
    param (
        # The file to move and rename
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf},ErrorMessage = "48, {0}.")]
        [System.IO.FileInfo]$file,
        # The target file to move and rename to
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf},ErrorMessage = "52, {0}.")]
        [System.IO.FileInfo]$target
    )
    # Get the old name of the file before moving
    $oldName = $file.Name

    # Move and rename the file to the target with force
    Move-Item -Path $file.FullName -Destination $target.FullName -Force

    # Add the change to git staging area
    git add .

    # Commit with a message containing the old name
    git commit -m "Moved and renamed $oldName to $target.Name"
}

# Call the functions with error handling

try {
    # Get the paths from the file name parameter
    $paths = ""
    $paths = Get-Paths -FileName $FileName

    # Get all the files from the paths and sort them by size
    $files = ""
    $files = Get-Files -paths $paths

    # Get the smallest file as the target
    $target
    $target = $files[0]

    # Loop through each path except for the first one (the target)
    foreach ($path in ($files | Select-Object -Skip 1 | Where-Object { $_ -ne "" } | Where-Object { $_ -ne $null }))
    {
        # Move and rename each file to the target and commit the change
        Move-And-Rename -file $path -target $target
    }
}
catch {
    # Write an error message if something goes wrong
    Write-Error "An error occurred: $_"
}
