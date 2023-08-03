<#
.SYNOPSIS
Watches a folder for new files and copies them to a backup folder.

.DESCRIPTION
This script watches a folder for new files and copies them to a backup folder. It also writes a log entry with the date, time and file name. It takes the path of the source folder, the path of the backup folder, and an optional file filter as parameters. It uses the System.IO.FileSystemWatcher class to monitor the file system events.

.PARAMETER SourceFolder
The path of the source folder to watch. This parameter is mandatory and must be a valid path.

.PARAMETER BackupFolder
The path of the backup folder to copy the new files to. This parameter is mandatory and must be a valid path.

.PARAMETER FileFilter
The file filter to apply to the source folder. This parameter is optional and defaults to "*.*".

.EXAMPLE
.\script.ps1 -SourceFolder "C:\Program Files (x86)\Steam\steamapps\common\STALKER Shadow of Chernobyl" -BackupFolder "D:\Backup"

This example watches the "C:\Program Files (x86)\Steam\steamapps\common\STALKER Shadow of Chernobyl" folder for new files and copies them to the "D:\Backup" folder.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$SourceFolder, # The path of the source folder to watch

    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_})]
    [string]$BackupFolder, # The path of the backup folder to copy the new files to

    [Parameter()]
    [string]$FileFilter = "*.*" # The file filter to apply to the source folder
)

# Define a function to create a file system watcher with the given parameters
function New-FileSystemWatcher {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path, # The path of the folder to watch

        [Parameter()]
        [string]$Filter = "*.*", # The file filter to apply

        [Parameter()]
        [bool]$IncludeSubdirectories = $true, # Whether to include subdirectories or not

        [Parameter()]
        [bool]$EnableRaisingEvents = $true # Whether to enable raising events or not
    )

    # Validate the parameters
    if ($Path -eq $null -or $Path -eq "") {
        Write-Error "Path cannot be null or empty"
        return
    }

    if (-not (Test-Path $Path)) {
        Write-Error "Path does not exist"
        return
    }

    if ($Filter -eq $null -or $Filter -eq "") {
        Write-Error "Filter cannot be null or empty"
        return
    }

    # Create a new file system watcher object with the given parameters
    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $Path
    $watcher.Filter = $Filter
    $watcher.IncludeSubdirectories = $IncludeSubdirectories
    $watcher.EnableRaisingEvents = $EnableRaisingEvents

    # Return the file system watcher object
    return $watcher
}

# Define a function to copy a file to a backup folder and write a log entry
function Copy-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceFile, # The path of the source file to copy

        [Parameter(Mandatory=$true)]
        [string]$BackupFolder, # The path of the backup folder to copy the file to

        [Parameter()]
        [string]$LogFile = "C:\Documents\log.txt" # The path of the log file to write the entry to
    )

    # Validate the parameters
    if ($SourceFile -eq $null -or $SourceFile -eq "") {
        Write-Error "Source file cannot be null or empty"
        return
    }

    if (-not (Test-Path $SourceFile)) {
        Write-Error "Source file does not exist"
        return
    }

    if ($BackupFolder -eq $null -or $BackupFolder -eq "") {
        Write-Error "Backup folder cannot be null or empty"
        return
    }

    if (-not (Test-Path $BackupFolder)) {
        Write-Error "Backup folder does not exist"
        return
    }

    if ($LogFile -eq $null -or $LogFile -eq "") {
        Write-Error "Log file cannot be null or empty"
        return
    }

    # Copy the file to the backup folder using Copy-Item cmdlet with Force switch
    Copy-Item -Path $SourceFile -Destination $BackupFolder -Force

    # Write a log entry with the date, time and file name using Add-Content cmdlet
    $logline = "$(Get-Date), Copied, $SourceFile"
    Add-content $LogFile -value $logline
}

try {
    # Create a file system watcher with the given parameters using New-FileSystemWatcher function
    $watcher = New-FileSystemWatcher -Path $SourceFolder -Filter $FileFilter

    # Define an action to perform when a new file is created using Copy-File function
    $action = {
        # Get the full path of the new file
        $path = $Event.SourceEventArgs.FullPath

        # Copy the file to the backup folder and write a log entry using Copy-File function
        Copy-File -SourceFile $path -BackupFolder $BackupFolder
    }

    # Register the action to watch for the Created event using Register-ObjectEvent cmdlet
    Register-ObjectEvent $watcher "Created" -Action $action

    # Keep the script running until stopped using while loop and sleep cmdlet
    while ($true) {sleep 5}
}
catch {
    # Write an error message and exit
    Write-Error "Failed to watch or copy files: $_"
    exit 1
}
