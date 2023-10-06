function Invoke-Git {
  # Define a function to run git commands and check the exit code
<#
.SYNOPSIS
Runs a git command and checks the exit code.

.DESCRIPTION
This function runs a git command using Invoke-Expression and captures the output.
It returns the output to the host and prints a verbose message if the exit code is not zero.
It also prints the output to verbose if the verbose flag is set.

.PARAMETER Command
The git command to run.

.PARAMETER Verbose
The flag to indicate whether to print the output to verbose or not.

.EXAMPLE
Invoke-Git -Command "status --porcelain --untracked-files=no" -Verbose $true

This example runs the git status command with some options and returns and prints the output to verbose.
#>
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Command, # The git command to run

    [Parameter(Mandatory=$false)]
    [bool]$Verbose # The flag to indicate whether to print the output to verbose or not
  )
  # Run the command and capture the output
  $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
  # return the output to the host
  $output
  # Check the exit code and print a verbose message if not zero
  if ($LASTEXITCODE -ne 0) {
    Write-Verbose "Git command failed: git $Command"
  }
  # Print the output to verbose if the flag is set
  if ($Verbose) {
    Write-Verbose $output
  }
}