<# Synopsis: Clone a remote repository with a sparse checkout
# Example usage: Clone a remote repository with a sparse checkout of only the README.md file and the src folder

Git-SparseClone -RemoteUrl "https://github.com/user/repo.git" -LocalDir "C:\Users\user\Documents\MyRepo" -Paths "README.md", "src/"


#>
function Git-SparseClone {
  param(
      # The URL of the remote repository
      [string]$RemoteUrl,

      # The name of the local directory to clone the repository into
      [string]$LocalDir,

      # The list of paths to include in the sparse checkout
      [string[]]$Paths
  )

  # Create the local directory if it does not exist
  if (-not (Test-Path $LocalDir)) {
      New-Item -ItemType Directory -Path $LocalDir
  }

  # Change directory to the local directory
  Push-Location $LocalDir

  # Initialize a git repository in the local directory
  git init

  # Add the remote repository as origin
  git remote add -f origin $RemoteUrl

  # Enable sparse checkout in the git configuration
  git config core.sparseCheckout true

  # Write the paths to include in the sparse checkout file
  foreach ($path in $Paths) {
      Add-Content -Path ".git\info\sparse-checkout" -Value $path
  }

  # Pull the master branch from the remote repository
  git pull origin master

  # Change directory back to the original location
  Pop-Location
}

