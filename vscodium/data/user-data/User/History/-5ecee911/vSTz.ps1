<#
.SYNOPSIS
A function to run a search and move files based on their extensions.

.DESCRIPTION
This function uses Search-Everything and trid to search for files that are not gz, webp or gif in the current directory or its subdirectories, excluding .git folders. It then moves the files to a destination drive based on their extensions. It uses multithreading and chunking to speed up the process. If the file extension cannot be determined by trid, it moves the file to a different folder on the same drive.

.PARAMETER DestinationDrive
The drive letter where the files will be moved to. Default is L:.

.PARAMETER OtherFolder
The name of the folder where the files will be moved to if the condition is not met. Default is Other.

.EXAMPLE
runx -DestinationDrive M: -OtherFolder Unknown

This will search for files that are not gz, webp or gif in the current directory or its subdirectories, excluding .git folders, and move them to M: drive based on their extensions using multithreading and chunking. If the file extension cannot be determined by trid, it moves the file to M:\Unknown folder.
#>
function runx {
    [CmdletBinding()]
    param(
      [ValidatePattern("^[A-Z]:$")]
      [string]$DestinationDrive = "L:",
      [string]$OtherFolder = "Other"
    )
  
    try {
      # Search for files that are not gz, webp or gif, excluding .git folders
      $v = Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" -Global
  
      if ($v) {
        # Initialize a progress bar
        $progress = @{
          Activity = "Moving files based on extensions"
          Status   = "Processing file"
          PercentComplete = 0
        }
  
        # Create an array to store the job objects
        $jobs = @()
  
        # Create an array to store the chunks of files
        $chunks = @()
  
        # Define a function to get the common parent path of an array of paths
        function Get-CommonParentPath {
          param($paths)
          $commonPath = ""
          $minLength = ($paths | Measure-Object -Property Length -Minimum).Minimum
          for ($i = 0; $i -lt $minLength; $i++) {
            $char = $paths[0][$i]
            foreach ($path in $paths) {
              if ($path[$i] -ne $char) {
                return $commonPath
              }
            }
            $commonPath += $char
          }
          return $commonPath
        }
  
        # Define a function to check if a chunk is valid, i.e. no other file exists that will be touched by a wildcard match from trid
        function Test-Chunk {
          param($chunk)
          # Get the common parent path of the chunk
          $commonPath = Get-CommonParentPath -paths $chunk
  
          # Check if there are any other files in the same directory or subdirectories that match the search criteria
          $otherFiles = Search-Everything -PathExclude ".git" -filter "F: folder\ file: !ext:gz;webp;gif" -Global -Path "$commonPath*"
  
          # Compare the other files with the chunk and return false if there is any difference
          return (Compare-Object -ReferenceObject $otherFiles -DifferenceObject $chunk).Count -eq 0
        }
  
        # Loop through the files and create chunks of max 100 paths that are valid
        $chunkSize = 100
        for ($i = 0; $i -lt $v.Count; $i += $chunkSize) {
          # Get a slice of max 100 paths from the array of files
          $slice = $v[$i..($i + $chunkSize - 1)]
  
          # Check if the slice is a valid chunk
          if (Test-Chunk -chunk $slice) {
            # Add the slice to the array of chunks
            $chunks += ,$slice
          }
          else {
            # Split the slice into smaller chunks and test each one individually
            foreach ($file in $slice) {
              # Check if the file is a valid chunk by itself
              if (Test-Chunk -chunk @($file)) {
                # Add the file to the array of chunks as a single-element array
                $chunks += ,@($file)
              }
              else {
                # Skip the file as it cannot be processed by trid with wildcard matching
                Write-Warning "Skipping file: $file"
              }
            }
          }
        }
  
        # Loop through the chunks
        foreach ($chunk in $chunks) {
          # Update the progress bar
          $progress.PercentComplete = ($chunks.IndexOf($chunk) / $chunks.Count) * 100
          Write-Progress @progress
  
          # Start a new job for each chunk
          $job = Start-Job -ScriptBlock {
            param($chunk, $DestinationDrive, $OtherFolder)
  
            # Get the common parent path of the chunk
            $commonPath = Get-CommonParentPath -paths $chunk
  
            # Get the file extensions using trid with wildcard matching
            $q = trid "$commonPath*" -ce
  
            # Loop through the output lines of trid
            for ($i = 0; $i -lt $q.Count; $i++) {
              # Check if the line contains the file name
              if ($q[$i] -match 'Collecting data from file: ') {
                # Get the file name from the line
                $filename = ($q[$i] -split 'file: ')[1]
  
                # Check if the next line contains the file extension
                if ($q[$i + 1] -match '\(\w+/\w+\)') {
                  # Get the file extension from the line
                  $regex = "[()]"
                  $ext = (($q[$i + 1] -split $regex)[1] -split '/')[0]
                  $file = ($filename + $ext)
  
                  # Check if the file exists
                  if (Test-Path $file) {
                    # Get the file path without the drive letter
                    $filePath = $file.Substring(2)
  
                    # Construct the destination path by replacing the drive letter
                    $destinationPath = $DestinationDrive + $filePath
  
                    # Create the destination directory if it does not exist
                    $destinationDir = Split-Path -Path $destinationPath -Parent
                    if (-not (Test-Path -Path $destinationDir)) {
                      New-Item -Path $destinationDir -ItemType Directory
                    }
  
                    # Move the file to the destination path
                    Move-Item -Path $file -Destination $destinationPath
                  }
                }
                else {
                  # Get the drive letter and the file name of the original file
                  $driveLetter = Split-Path -Path $filename -Qualifier
                  $fileName = Split-Path -Path $filename -Leaf
  
                  # Construct the destination path by appending the other folder name
                  $destinationPath = Join-Path -Path "$driveLetter\$OtherFolder" -ChildPath $fileName
  
                  # Create the other folder if it does not exist
                  if (-not (Test-Path -Path "$driveLetter\$OtherFolder")) {
                    New-Item -Path "$driveLetter\$OtherFolder" -ItemType Directory
                  }
  
                  # Move the file to the destination path
  