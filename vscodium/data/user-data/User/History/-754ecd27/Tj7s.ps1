. "$PSScriptRoot\Get-commonPrefix.ps1"
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
    $groups = $Paths | Group-Object -Property {[System.IO.Path]::GetDirectoryName($_)}
  
        # Create an array to store the jobs
    $jobs = @()

    # Loop through each group and create a job that runs the function on the group
    foreach ($group in $groups) {
      # Create a job that runs the function on the group
      $job = Start-Job -ScriptBlock {param($group, $ChunkSize) Get-TridChunks -Paths $group.Group -ChunkSize $ChunkSize} -ArgumentList $group, $ChunkSize

      # Add the job to the array
      $jobs += $job
    }

    # Wait for all jobs to complete
    Wait-Job -Job $jobs

    # Loop through each job and get the results
    foreach ($job in $jobs) {
      # Get the results from the job
      $result = Receive-Job -Job $job

      # Add the result to the chunks array
      $chunks += $result
    }

    return $chunks
}  