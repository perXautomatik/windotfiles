<#
.SYNOPSIS
Finds the process that is locking a file or a directory.

.DESCRIPTION
This function finds the process that is locking a file or a directory, using the openfiles command and the find command. The function expects a valid path as an input and outputs the result of the openfiles command filtered by the path.

.PARAMETER FileOrFolderPath
The path of the file or directory to check for locking.
#>
function Get-Lock {
    param(
        # Validate that the FileOrFolderPath parameter is not null or empty
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $FileOrFolderPath
    )

    # Check if the path exists
    if ((Test-Path -Path $FileOrFolderPath) -eq $false) {
        # Write a warning message if not
        Write-Warning "File or directory does not exist."
    }
    else {
        # Run the openfiles command with the query and table options and pipe it to the find command with the path as an argument
        $LockingProcess = CMD /C "openfiles /query /fo table | find /I ""$FileOrFolderPath"""
        # Write the result to the host
        Write-Host $LockingProcess
    }
}
