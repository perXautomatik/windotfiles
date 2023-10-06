# Synopsis: This function replaces any slashes in a filename with underscores
  # Check if the file exists in the repo at the given commit
  # If the file exists and is in the root of the repo, return the filename
  # Otherwise, return an empty string to delete the file
  $FilterRootFiles = "return filename.replace(b'/', b'_') if b'/' in filename else filename"

  


function RunGitFilterRepo {
  <#
.Synopsis
# Synopsis: This function runs git filter-repo with the given filename callback and force flag
# Parameters: callback - a function name that takes a byte string as input and returns a byte string as output
#             force - a boolean value indicating whether to pass the --force flag to git filter-repo or not
# Returns: nothing, but prints the output of git filter-repo to stdout

This function runs git filter-repo with the given filename callback and force flag
.Parameter callback
A function name that takes a byte string as input and returns a byte string as output
.Parameter force
A boolean value indicating whether to pass the --force flag to git filter-repo or not
.Example
RunGitFilterRepo -callback "ReplaceFooWithBar" -force $true
#>
  [CmdletBinding()]
  param (
    # The callback function name
    [Parameter(Mandatory=$true)]
    [ValidateScript({Get-Command $_ -ErrorAction SilentlyContinue})]
    [string]$callback,

    # The force flag value
    [Parameter(Mandatory=$true)]
    [ValidateSet($true, $false)]
    [bool]$force
  )

  # Build the git filter-repo command with the parameters
  $command = "git filter-repo --filename-callback $callback"
  if ($force) {
    # Add the --force flag if true
    $command += " --force"
  }

  # Invoke the command and capture the output
  $output = Invoke-Expression $command

  # Write the output to stdout
  Write-Output $output
}
