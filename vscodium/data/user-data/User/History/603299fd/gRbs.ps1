
# Define a function to get the folder path from the user input
<#
.SYNOPSIS
Gets the folder path from the user input and trims any trailing backslashes.

.PARAMETER Input
The user input string.

.EXAMPLE
Get-FolderPath -Input "B:\PF\NoteTakingProjectFolder\"

Output: B:\PF\NoteTakingProjectFolder
#>
function Get-FolderPath {
    param(
        # The user input string
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Input
    )

    # Trim any trailing backslashes and return the result
    return $Input.Trim("\\")
}

# Define a function to use Everything to find all folders in the folder path
<#
.SYNOPSIS
Uses Everything to find all folders in the folder path and returns them as an array.

.PARAMETER Path
The folder path to search.

.EXAMPLE
Get-Folders -Path "B:\PF\NoteTakingProjectFolder"

Output: B:\PF\NoteTakingProjectFolder\Subfolder1, B:\PF\NoteTakingProjectFolder\Subfolder2, ...
#>
function Get-Folders {
    param(
        # The folder path to search
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    # Install and import the pseverything module if not already loaded
    if (-not (Get-Module -Name pseverything)) {
        Install-Module pseverything -Scope CurrentUser -Force
        Import-Module pseverything
    }

    # Use Everything to find all folders in the folder path
    $filter = 'folder:'
    $folders = Search-Everything -PathInclude $Path -Filter $filter -Global

    # Add the folder path itself to the result array
    $folders += $Path

    # Return the result array
    return $folders
}

# Define a function to get the depth of a folder
<#
.SYNOPSIS
Gets the depth of a folder by counting the number of parts separated by backslashes.

.PARAMETER Folder
The folder name or path.

.EXAMPLE
Get-Depth -Folder "B:\PF\NoteTakingProjectFolder\Subfolder1"

Output: 4
#>
function Get-Depth {
    param(
        # The folder name or path
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Folder
    )

    # Split the folder by the path separator and count the number of parts
    return ($Folder -split "\\").Count
}



# Get the folder path from the user input using Get-FolderPath function and store it in a variable
$folderPath = "B:\PF\NoteTakingProjectFolder".Trim("\\")

# Use Get-Folders function to find all folders in the folder path and store them in an array variable 
$folders = Get-Folders -Path $folderPath

# Sort the folders by depth in descending order using Get-Depth function and store them in an array variable 
$sortedFolders = $folders | Sort-Object -Descending -Property {Get-Depth $_}

# Get the total number of folders and store it in a variable 
$total = $sortedFolders.Count

# Initialize the folder index 
$index = 0

# For each folder in the sorted list 
foreach ($folder in $sortedFolders) {
    # Increment the folder index 
    $index++

    # Calculate the percentage of completion and store it in a variable 
    $percent = ($index / $total) * 100

    # Update the progress bar using Write-Progress cmdlet 
    Write-Progress -Activity "Adding and committing folders" -Status "Current folder: $folder" -PercentComplete $percent

    # Start a job to run the Add-Commit-Folder function on the folder using Start-Job cmdlet 
    Start-Job -ScriptBlock {
        # Define a function to add and commit files in a folder using git commands
            <#
            .SYNOPSIS
            Adds and commits all files in a folder using git commands. The commit message is "folder name; toVerify".

            .PARAMETER Folder
            The folder name or path.

            .EXAMPLE
            Add-Commit-Folder -Folder "B:\PF\NoteTakingProjectFolder\Subfolder1"
            #>
            function Add-Commit-Folder {
                param(
                    # The folder name or path
                    [Parameter(Mandatory = $true)]
                    [ValidateNotNullOrEmpty()]
                    [string]$Folder
                )

                # Change the current location to the folder
                Set-Location $Folder

                # Get the folder name from the path
                $folderName = Split-Path $Folder -Leaf

                # Add all files in the folder to the staging area using git command
                git add .

                # Check the status of the git repository using git command and store the output in a variable
                $status = git status

                # If there are changes to be committed, then commit them using git command with the message "folder name; toVerify"
                if ($status[-1] -ne "nothing to commit, working tree clean") {
                    git commit -m "$folderName; toVerify"
                }
            }
        
        
        Add-Commit-Folder -Folder $using:folder}

    # Get the number of running jobs and store it in a variable 
    $running = (Get-Job -State Running).Count

    # If the number of running jobs is equal to or greater than 4, then wait for any job to finish using Wait-Job cmdlet 
    if ($running -ge 4) {
        Wait-Job -state "running" -Any 
    }
}

# Wait for all jobs to finish using Wait-Job cmdlet 
Wait-Job * | Out-Null

# Receive and display the output from each job using Receive-Job cmdlet 
Receive-Job *

# Remove all completed jobs using Remove-Job cmdlet 
Remove-Job -State Completed
