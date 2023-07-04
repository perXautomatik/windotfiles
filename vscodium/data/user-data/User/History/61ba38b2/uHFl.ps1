<#
.SYNOPSIS
This script collects information about the folders in a given path and checks if they are git repositories or not.

.DESCRIPTION
This script takes a start path as a parameter and uses a background job to get all the subfolders recursively, excluding the ones that contain ".git" in their names. It then uses git commands to check the status and root of each folder and creates a custom object with the folder name, path, git root and status properties. It outputs the results as JSON objects and displays a progress bar while the job is running. It also sorts the results by status and formats them as a table. It also shows the relative paths of the folders that are not git repositories.

.PARAMETER start
The start path to search for folders.

.EXAMPLE
Collect-FolderInfo -start 'B:\ToGit\'

This example collects information about the folders in the 'B:\ToGit\' path and checks if they are git repositories or not.
#>
function Collect-FolderInfo {
    # Define the parameter for the function
    param (
        # The start parameter specifies the start path to search for folders
        [Parameter(Mandatory=$true)]
        [string]$start
    )

    # Start a background job with the name "FileCollection"
    Start-Job -Name "FileCollection" -ScriptBlock {

        # Set the environment variable for git redirection
        [Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

        # Define a function to get all subfolders recursively, excluding the ones that contain ".git" in their names
        function Get-Folders {
            param (
                # The path parameter specifies the path to search for subfolders
                [Parameter(Mandatory=$true)]
                [string]$path
            )
            Get-ChildItem -Path $path -Recurse -Directory | Where-Object { !($_.FullName -like '*.git*') }
        }

        # Define a function to create a custom object with folder information and git status
        function Get-FolderInfo {
            param (
                # The folder parameter specifies the folder object to process
                [Parameter(Mandatory=$true)]
                [object]$folder
            )
            # Change the current directory to the folder path
            cd $folder.FullName
            # Get the git status of the folder
            $status = (git status)
            # Create a custom object with folder name, path, git root and status properties
            $properties = [ordered]@{
                FolderName = $folder.Name
                path = $folder.FullName
                gitRoot = if ($status -like 'fatal*') { $null } else { (git rev-parse --show-toplevel) }
                status = $status
            }
            New-Object –TypeName PSObject -Property $properties
        }

        # Get all subfolders from the start path using Get-Folders function and store them in a variable
        $folders = Get-Folders -path $using:start

        # Loop through each folder in the variable and output its information as a JSON object using Get-FolderInfo function
        foreach ($folder in $folders) {
            Get-FolderInfo -folder $folder | ConvertTo-Json
        }
    }

    # Initialize a counter variable for the progress bar
    $x = 0

    # Initialize an empty array to store the results from the job
    $results = @()

    # Loop while the job is running
    While ((Get-Job -Name "FileCollection").State -eq "Running") {

        # Receive the latest result from the job and append it to the results array
        $result = Get-Job -Name "FileCollection" | Receive-Job | Select-Object -Last 1 
        $results += $result

        # Define a string for the activity name of the progress bar
        $activity = 'Collecting Folder Information'

        # Write a progress bar with the activity name and percentage completed using Write-Progress cmdlet
        Write-Progress -Activity $activity -PercentComplete $x

        # Increment or reset the counter variable for the progress bar
        If ($x -eq 100) { $x = 1 } Else { $x += 1 }
    }

    # Complete the progress bar using Write-Progress cmdlet with the Completed switch
    Write-Progress -Activity "FileCollection" -Completed

    # Receive all results from the job and store them in a variable
    $files = Get-Job -Name "FileCollection" | Receive-Job 

    # Remove the job using Remove-Job cmdlet
    Get-Job -Name "FileCollection" | Remove-Job

    # Convert the results from JSON to objects and sort them by status and format them as a table
    $results | ConvertFrom-Json | Sort-Object -Property status | Format-Table

    # Change the current directory to the start path and show the relative paths of the folders that are not git repositories
    cd $start
    $results | ConvertFrom-Json | Where-Object { $_.status -like 'fatal*' } | Select-Object @{name = "relative" ; expression={ Resolve-Path $_.path }} 
}