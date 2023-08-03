<#
.SYNOPSIS
A function to run a search and move files based on their extensions.

.DESCRIPTION
This function uses Search-Everything and trid to search for files that are not gz, webp or gif in the current directory or its subdirectories, excluding .git folders. It then moves the files to a destination drive based on their extensions. It uses multithreading and chunking to speed up the process and reduce the number of calls to trid. If the file extension cannot be determined by trid, it moves the file to a different folder on the same drive.

.PARAMETER DestinationDrive
The drive letter where the files will be moved to. Default is L:.

.PARAMETER OtherFolder
The name of the folder where the files will be moved to if the condition is not met. Default is Other.

.PARAMETER ChunkSize
The maximum number of paths in a chunk for trid. Default is 100.

.EXAMPLE
runx -DestinationDrive M: -OtherFolder Unknown -ChunkSize 50

This will search for files that are not gz, webp or gif in the current directory or its subdirectories, excluding .git folders, and move them to M: drive based on their extensions using multithreading and chunking with a chunk size of 50. If the file extension cannot be determined by trid, it moves the file to M:\Unknown folder.
#>
function runx {
    [CmdletBinding()]
    param(
      [ValidatePattern("^[A-Z]:$")]
      [string]$DestinationDrive = "L:",
      [string]$OtherFolder = "Other",
      [ValidateRange(1, 100)]
      [int]$ChunkSize = 100
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
  
        # Get the chunks of paths for trid using the Get-TridChunks function
        $chunks = Get-TridChunks -Paths $v -ChunkSize $ChunkSize
  
        # Loop through each chunk of paths for trid
        foreach ($chunk in $chunks) {
          # Update the progress bar
          $progress.PercentComplete = ($chunks.IndexOf($chunk) / $chunks.Count) * 100
          Write-Progress @progress
  
          # Start a new job for each chunk
          $job = Start-Job -ScriptBlock {
            param($chunk, $DestinationDrive, $OtherFolder)
  
            # Get the file extension using trid
            $q = trid $chunk -ce
  
            # Loop through the output of trid and process each file
            for ($j = 0; $j -lt $q.Length; $j++) {
              if ($q[$j] -match 'Collecting data from file: ') {
                # Get the file name from the output
                $file = ($q[$j] -split 'file: ')[1]
  
                if ($q[$j + 1] -ne " 0 file(s) renamed.") {
                  # Get the file extension from the output
                  $regex = "[()]"
                  $ext = (($q[$j + 1] -split $regex)[1] -split '/')[0]
                  $file = ($file + $ext)
  
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
                  $driveLetter = Split-Path -Path $file -Qualifier
                  $fileName = Split-Path -Path $file -Leaf
  
                  # Construct the destination path by appending the other folder name
                  $destinationPath = Join-Path -Path "$driveLetter\$OtherFolder" -ChildPath $fileName
  
                  # Create the other folder if it does not exist
                  if (-not (Test-Path -Path "$driveLetter\$OtherFolder")) {
                    New-Item -Path "$driveLetter\$OtherFolder" -ItemType Directory
                  }
  
                  # Move the file to the destination path
                  Move-Item -Path $file -Destination $destinationPath
  
                  Write-Output "Moved file to other folder: $destinationPath"
                }
              }
            }
          } -ArgumentList $chunk, $DestinationDrive, $OtherFolder
  
          # Add the job object to the array
          $jobs += $job
        }
  
        # Wait for all jobs to complete
        Wait-Job -Job $jobs
  
        # Get the output from each job and display it
        Receive-Job -Job $jobs
  
        # Remove the jobs from memory
        Remove-Job -Job $jobs
  
        # Complete the progress bar
        $progress.PercentComplete = 100
        Write-Progress @progress
  
      }
      else {
        Write-Output "No results"
      }
    }
    catch {
      Write-Error $_.Exception.Message
    }
  }
  
  <#
  .SYNOPSIS
  A function to get chunks of paths for trid based on a chunk size and a wildcard match criteria.
  
  .DESCRIPTION
  This function takes an array of paths and a chunk size as parameters and returns an array of chunks of paths for trid. It groups the paths by their parent paths and creates chunks based on the chunk size and the wildcard match criteria. If there are no other files in the group that would be matched by the prefix wildcard, it uses the prefix wildcard as the path for trid. Otherwise, it uses each individual path in the chunk as separate paths for trid.
  
  .PARAMETER Paths
  The array of paths to be chunked.
  
  .PARAMETER ChunkSize
  The maximum number of paths in a chunk for trid.
  
  .EXAMPLE
  Get-TridChunks -Paths @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt") -ChunkSize 2
  
  This will return an array of @("C:\foo\bar*", "C:\foo\baz*").
  #>
  function Get-TridChunks {
    [CmdletBinding()]
    param(
      [Parameter(Mandatory = $true)]
      [string[]]$Paths,
      [Parameter(Mandatory = $true)]
      [ValidateRange(1, 100)]
      [int]$ChunkSize
    )
  
    # Create an array to store the chunks of paths for trid
    $chunks = @()
  
    # Loop through the paths and group them by their parent paths
    $groups = $Paths | Group-Object -Property {Split-Path -Path $_ -Parent}
  
    # Loop through each group and create chunks of paths based on the chunk size and the wildcard match criteria
    foreach ($group in $groups) {
      # Get the parent path of the group
      $parentPath = $group.Name
  
      # Get the number of files in the group
      $count = $group.Count
  
      # Calculate the number of chunks needed for the group based on the chunk size
      $numChunks = [Math]::Ceiling($count / $ChunkSize)
  
      # Loop through each chunk and create a wildcard path for trid
      for ($i = 0; $i -lt $numChunks; $i++) {
        # Get the start index and the length of the chunk
        $startIndex = $i * $ChunkSize
        $length = [Math]::Min($ChunkSize, $count - $startIndex)
  
        # Get the chunk of paths from the group
        $chunk = $group.Group[$startIndex..($startIndex + $length - 1)]
  
        # Get the common prefix of the file names in the chunk
        $prefix = [System.IO.Path]::GetCommonPrefix($chunk | Split-Path -Leaf)
  
        # Check if there are any other files in the group that would be matched by the prefix wildcard
        $otherFiles = $group.Group | Where-Object {$_ -like "$parentPath\$prefix*"} | Where-Object {$chunk -notcontains $_}
  
        # If there are no other files, use the prefix wildcard as the path for trid
        if (-not $otherFiles) {
          $chunks += "$parentPath\$prefix*"
        }
        else {
          # Otherwise, use each individual path in the chunk as separate paths for trid
          foreach ($path in $chunk) {
            $chunks += "$path"
          }
  