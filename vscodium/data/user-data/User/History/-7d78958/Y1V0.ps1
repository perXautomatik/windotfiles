<#
.SYNOPSIS
Deletes untracked or staged files as additions, not modifications, in a git repo.

.DESCRIPTION
This script takes a path to a git repo as input and deletes untracked or staged files as additions, not modifications, in the repo. It also deletes one of the files if more than one file has the same content as another of the staged files or untracked files, prioritizing deleting untracked files always. It also deletes and discards the file if it exists in the worktree currently. It uses git status --porcelain to get the list of files and Get-FileHash to get the hash of the file content.

.PARAMETER Repo
The path to the git repo.

.EXAMPLE
.\Delete-Files.ps1 -Repo "C:\Users\Användaren\Documents\Obsidian Vault"

This example deletes untracked or staged files as additions, not modifications, in the "C:\Users\Användaren\Documents\Obsidian Vault" repo.
#>

# Define a function to get the hash of a file content
<#
.SYNOPSIS
Gets the hash of a file content.

.DESCRIPTION
This function gets the hash of a file content using System.IO.MemoryStream and System.Text.Encoding.UTF8.GetBytes. It returns the hash as an integer.

.PARAMETER Path
The path to the file.

.EXAMPLE
Get-FileHash -Path "C:\Users\Användaren\Documents\Obsidian Vault\test.txt"

This example gets the hash of the file content of "C:\Users\Användaren\Documents\Obsidian Vault\test.txt".
#>
function Get-FileHash {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path # The path to the file
    )

    # Try to get the content of the file as a string
    try {
        $Content = Get-Content -Path $Path -Raw -ErrorAction Stop
    }
    catch {
        # Write an error message and return null
        Write-Error "Failed to get the content of $Path: $_"
        return $null
    }

    # Convert the content to a byte array using UTF8 encoding
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Content)

    # Create a memory stream from the byte array
    $Stream = [System.IO.MemoryStream]::new($Bytes)

    # Get the MD5 hash of the stream using Get-FileHash cmdlet
    $Hash = Get-FileHash -InputStream $Stream -Algorithm MD5

    # Return the hash as an integer
    return [int]$Hash.Hash
}

# Define a function to delete a file and discard the changes
<#
.SYNOPSIS
Deletes a file and discards the changes.

.DESCRIPTION
This function deletes a file using Remove-Item cmdlet and discards the changes using git restore command. It uses -WhatIf switch to show what would happen without actually deleting or discarding.

.PARAMETER Path
The path to the file.

.EXAMPLE
Delete-File -Path "C:\Users\Användaren\Documents\Obsidian Vault\test.txt"

This example deletes and discards "C:\Users\Användaren\Documents\Obsidian Vault\test.txt".
#>
function Delete-File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path # The path to the file
    )

    # Try to delete the file using Remove-Item cmdlet with -WhatIf switch
    try {
        Remove-Item -Path $Path -Force -ErrorAction Stop -WhatIf
    }
    catch {
        # Write an error message and return
        Write-Error "Failed to delete $Path: $_"
        return
    }

    # Try to discard the changes using git restore command with --staged option and -WhatIf switch
    try {
        Invoke-Expression "git restore --staged $Path" -ErrorAction Stop -WhatIf
    }
    catch {
        # Write an error message and return
        Write-Error "Failed to discard $Path: $_"
        return
    }
}
