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
    testSourceTarget -source $file.FullName -target $target.FullName
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

function testSourceTarget
{
    param (
        # Define the source and target paths
    $source = "\\hostessblabfoo\C$\Program Files\foo",
    $target = "\\hostessblabfoo\C$\Program Files\bar"
    )
        


    # Define a function to test if a file or folder is locked
    function Test-FileLock {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Path
        )
        try {
            [IO.File]::OpenWrite($Path).close()
            return $false
        }
        catch {
            return $true
        }
    }

    # Test the source and target paths for any issues
    if (Test-Path -Path $source -IsValid) {
        Write-Host "The source path is valid."
    }
    else {
        Write-Error "The source path is invalid. Please check the path name and try again."
        exit
    }

    if (Test-Path -Path $target -IsValid) {
        Write-Host "The target path is valid."
    }
    else {
        Write-Error "The target path is invalid. Please check the path name and try again."
        exit
    }

    if (Test-FileLock -Path $source) {
        Write-Error "The source file or folder is locked by another process. Please close any programs that might be using it and try again."
        exit
    }

    if (Test-FileLock -Path $target) {
        Write-Error "The target file or folder is locked by another process. Please close any programs that might be using it and try again."
        exit
    }

    $sourceAttributes = (Get-ItemProperty -Path $source).Attributes
    $targetAttributes = (Get-ItemProperty -Path $target).Attributes

    if ($sourceAttributes -band [System.IO.FileAttributes]::ReadOnly) {
        Write-Warning "The source file or folder has the read-only attribute. This might prevent robocopy from overwriting or deleting it."
    }

    if ($targetAttributes -band [System.IO.FileAttributes]::ReadOnly) {
        Write-Warning "The target file or folder has the read-only attribute. This might prevent robocopy from overwriting or deleting it."
    }

    if ($sourceAttributes -band [System.IO.FileAttributes]::Hidden) {
        Write-Warning "The source file or folder has the hidden attribute. This might prevent robocopy from copying it."
    }

    if ($targetAttributes -band [System.IO.FileAttributes]::Hidden) {
        Write-Warning "The target file or folder has the hidden attribute. This might prevent robocopy from copying it."
    }

    if ($sourceAttributes -band [System.IO.FileAttributes]::System) {
        Write-Warning "The source file or folder has the system attribute. This might prevent robocopy from copying it."
    }

    if ($targetAttributes -band [System.IO.FileAttributes]::System) {
        Write-Warning "The target file or folder has the system attribute. This might prevent robocopy from copying it."
    }

    $sourceAcl = Get-Acl -Path $source
    $targetAcl = Get-Acl -Path $target

    if ($sourceAcl.Owner -ne $env:USERNAME) {
        Write-Warning "The source file or folder has a different owner than the current user. This might prevent robocopy from accessing it."
    }

    if ($targetAcl.Owner -ne $env:USERNAME) {
        Write-Warning "The target file or folder has a different owner than the current user. This might prevent robocopy from accessing it."
    }

    foreach ($rule in $sourceAcl.Access) {
        if ($rule.IdentityReference.Value -eq $env:USERNAME) {
            if (-not ($rule.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::FullControl)) {
                Write-Warning "The current user does not have full control over the source file or folder. This might prevent robocopy from accessing it."
                break
            }
        }
    }

    foreach ($rule in $targetAcl.Access) {
        if ($rule.IdentityReference.Value -eq $env:USERNAME) {
            if (-not ($rule.FileSystemRights -band [System.Security.AccessControl.FileSystemRights]::FullControl)) {
                Write-Warning "The current user does not have full control over the target file or folder. This might prevent robocopy from accessing it."
                break
            }
        }
    }

    # Use robocopy to copy the files with some options
    robocopy $source $target /E /Z /R:3 /W:5 /NP /LOG+:robocopy.log

    # Check the exit code of robocopy and display the result
    $exitCode = $LASTEXITCODE

    switch ($exitCode)
    {
    0 {Write-Host "No files were copied. No errors were detected."}
    1 {Write-Host "One or more files were copied successfully."}
    2 {Write-Host "Some extra files or directories were detected. No errors were detected."}
    3 {Write-Host "One or more files were copied successfully. Some extra files or directories were detected."}
    4 {Write-Host "Some mismatched files or directories were detected. No errors were detected."}
    5 {Write-Host "One or more files were copied successfully. Some mismatched files or directories were detected."}
    6 {Write-Host "Some extra files or directories were detected. Some mismatched files or directories were detected. No errors were detected."}
    7 {Write-Host "One or more files were copied successfully. Some extra files or directories were detected. Some mismatched files or directories were detected."}
    8 {Write-Host "Some files or directories could not be copied and the retry limit was exceeded."}
    9 {Write-Host "One or more files were copied successfully. Some files or directories could not be copied and the retry limit was exceeded."}
    10 {Write-Host "Some extra files or directories were detected. Some files or directories could not be copied and the retry limit was exceeded."}
    11 {Write-Host "One or more files were copied successfully. Some extra files or directories were detected. Some files or directories could not be copied and the retry limit was exceeded."}
    12 {Write-Host "Some mismatched files or directories were detected. Some files or directories could not be copied and the retry limit was exceeded."}
    13 {Write-Host "One or more files were copied successfully. Some mismatched files or directories were detected. Some files or directories could not be copied and the retry limit was exceeded."}
    14 {Write-Host "Some extra files or directories were detected. Some mismatched files or directories were detected. Some files or directories could not be copied and the retry limit was exceeded."}
    15 {Write-Host "One or more files were copied successfully. Some extra files or directories were detected. Some mismatched files or directories were detected. Some files or directories could not be copied and the retry limit was exceeded."}
    16 {Write-Host "A fatal error occurred and robocopy terminated."}
    default {Write-Host "An unknown error occurred and robocopy terminated."}
    }

    # Display the log file of robocopy
    Get-Content robocopy.log

}