
function gitRemoveWorktree ($configPath)
{
    $iniContent = Get-IniContent -FilePath $configPath
    $iniContent.core.Remove("worktree") ;
    $iniContent | Out-IniFile -FilePath $configPath -Force
}

function Get-SubmoduleUrl {
  
# Define a function to get the URL of a submodule
  param(
    [string]$Path # The path of the submodule directory
  )
  # Change the current location to the submodule directory
  Push-Location -Path $Path -ErrorAction Stop
  # Get the URL of the origin remote
  $url = git config remote.origin.url -ErrorAction Stop
  # Write the URL to the host
  Write-Host $url
  # Parse the URL to get the part after the colon
  $parsedUrl = ($url -split ':')[1]
  # Write the parsed URL to the host
  Write-Host $parsedUrl
  # Return to the previous location
  Pop-Location -ErrorAction Stop
}

function Invoke-Git {
  # Define a function to run git commands and check the exit code

  param(
    [string]$Command # The git command to run
  )
  # Run the command and capture the output
  $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
  # return the output to the host
  $output
  # Check the exit code and throw an exception if not zero
  if ($LASTEXITCODE -ne 0) {
    throw "Git command failed: git $Command"
  }
}
