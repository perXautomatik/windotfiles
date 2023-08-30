<#
.SYNOPSIS
Clones a git repository with a sparse checkout.

.DESCRIPTION
This function clones a git repository with a sparse checkout, which means that only the specified files or directories are downloaded instead of the entire repository.

.PARAMETER RemoteUrl
The URL of the remote git repository.

.PARAMETER LocalDir
The path of the local directory where the repository will be cloned.

.PARAMETER Files
The files or directories that will be included in the sparse checkout. This can be one or more arguments separated by spaces.
#>
function Git-Sparse-Clone {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string]
      $RemoteUrl,

      [Parameter(Mandatory = $true)]
      [string]
      $LocalDir,

      [Parameter(Mandatory = $true)]
      [string[]]
      $Files
  )

  # Create the local directory if it does not exist
  if (-not (Test-Path -Path $LocalDir)) {
      New-Item -Path $LocalDir -ItemType Directory | Out-Null
  }

  # Change the current location to the local directory
  Set-Location -Path $LocalDir

  # Initialize a git repository
  git init

  # Add the remote URL as origin
  git remote add -f origin $RemoteUrl

  # Enable sparse checkout
  git config core.sparseCheckout true

  # Loop over the files or directories and add them to the sparse checkout list
  foreach ($file in $Files) {
      Add-Content -Path .git\info\sparse-checkout -Value $file
  }

  # Pull the master branch from origin
  git pull origin master
}
