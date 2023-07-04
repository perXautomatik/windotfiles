<#
.SYNOPSIS
Creates a temporary git repository and executes a script block in it.

.DESCRIPTION
This function creates a temporary git repository in a subdirectory of a temporary file and executes a script block in it. The function uses the invoke-git function to run git commands and the New-Guid cmdlet to generate a unique name for the subdirectory. The function also has an option to remove the subdirectory and its contents after executing the script block.

.PARAMETER Script
The script block to execute in the temporary git repository. If not specified, the function will return the path of the subdirectory.

.PARAMETER RemoveAfter
A switch parameter that indicates whether to remove the subdirectory and its contents after executing the script block. If not specified, the default value is false.
#>
function Invoke-GitTemp {
  param(
      # Validate that the Script parameter is not null or empty and is a script block
      [Parameter(Mandatory = $false)]
      [ValidateNotNullOrEmpty()]
      [ValidateScript({$_ -is [scriptblock]})]
      [scriptblock]
      $Script,

      # Validate that the RemoveAfter parameter is a switch
      [Parameter(Mandatory = $false)]
      [ValidateScript({$_ -is [switch]})]
      [switch]
      $RemoveAfter
  )

  # Create a temporary file and get its directory name
  $tempFile = New-TemporaryFile
  $tempDir = Split-Path -Parent $tempFile

  # Create a subdirectory under the temporary directory with a unique name
  $prefix = (New-Guid).Guid
  $gitDir = New-Item -Path $tempDir -Name "$prefix.gitrepo" -ItemType Directory

  # Change the current location to the subdirectory
  Push-Location -Path $gitDir -ErrorAction Stop

  # Initialize an empty git repository in the subdirectory
  $q = invoke-git("init")
  Write-Verbose $q

  # Check if a script block is specified
  if ($Script) {
      # Execute the script block and store the result
      $result = Invoke-Command -ScriptBlock $Script
  }
  else {
      # Return the path of the subdirectory as output
      $result = $gitDir
  }

  # Return to the previous location
  Pop-Location -ErrorAction Stop

  # Check if the flag is set to true
  if ($RemoveAfter) {
      # Delete the subdirectory and its contents
      Remove-Item -Path $gitDir -Recurse -Force
  }

  # Return the result as output
  return $result
}
