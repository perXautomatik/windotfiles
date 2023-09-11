function New-TempFolder {
  # Define a function to create a temporary folder and return its path
  $tempPath = [System.IO.Path]::GetTempPath()
  $tempName = [System.IO.Path]::GetRandomFileName()
  $tempFolder = Join-Path $tempPath $tempName
  New-Item -ItemType Directory -Path $tempFolder | Out-Null
  return $tempFolder
}

function Clone-Repo {
  # Define a function to clone the current repository into a temporary folder using TortoiseGit
  param (
    [string]$RepoUrl,
    [string]$TempFolder
  )
  $cloneCmd = "TortoiseProc.exe /command:clone /path:`"$TempFolder`" /url:`"$RepoUrl`" /closeonend:1"
  Invoke-Expression $cloneCmd
}

function Filter-Repo {
  # Define a function to run git filter-repo on the cloned repository with the given arguments
  param (
    [string]$TempFolder,
    [string[]]$Args
  )
  Push-Location $TempFolder
  git filter-repo $Args
  Pop-Location
}

function Merge-Refs {
  # Define a function to merge all head refs in the filtered repository into a single branch using the strategy "theirs" and --allow-unrelated-history
  param (
    [string]$TempFolder,
    [string]$BranchName
  )
  Push-Location $TempFolder
  git checkout -b $BranchName
  foreach ($ref in (git show-ref --heads | Select-String -Pattern "refs/heads/" | ForEach-Object { $_.Line.Split()[-1] })) {
    if ($ref -ne "refs/heads/$BranchName") {
      git merge --strategy-option=theirs --allow-unrelated-histories -m "Merge $ref into $BranchName" $ref
      if ($?) {
        git branch -D $ref
      }
    }
  }
  Pop-Location
}

function Rename-Branch {
  # Define a function to rename the current branch into a name based on the arguments, replacing unallowed chars with safe replacements and truncating it to not be too long
  param (
    [string]$TempFolder,
    [string[]]$Args
  )
  Push-Location $TempFolder
  # Concatenate the arguments with dashes and remove any leading or trailing dashes
  $newName = ($Args -join "-").Trim("-")
  # Replace any unallowed chars with underscores
  $newName = $newName -replace "[^a-zA-Z0-9\-\_\.]", "_"
  # Truncate the name to not exceed 40 characters
  if ($newName.Length -gt 40) {
    $newName = $newName.Substring(0,40)
  }
  # Rename the current branch with the new name
  git branch -m $newName
  Pop-Location
}

function Push-Repo {
  # Define a function to push all branches in the filtered repository back to the original repository
  param (
    [string]$TempFolder,
    [string]$RepoUrl
  )
  Push-Location $TempFolder
  git push --all origin 
}

# Get the arguments from the command line
$Args = $args

# Get the current repository URL from git config
$RepoUrl = git config --get remote.origin.url

# Create a temporary folder and clone the current repository into it
$TempFolder = New-TempFolder 
Clone-Repo -RepoUrl $RepoUrl -TempFolder $TempFolder

# Run git filter-repo on the cloned repository with the given arguments
Filter-Repo -TempFolder $TempFolder -Args $Args

# Merge all head refs in the filtered repository into a single branch using the strategy "theirs" and --allow-unrelated-history 
Merge-Refs -TempFolder $TempFolder -BranchName "filtered"

# Rename the current branch into a name based on the arguments, replacing unallowed chars with safe replacements and truncating it to not be too long 
Rename-Branch -TempFolder $TempFolder -Args $Args

# Push all branches in the filtered repository back to the original repository 
Push-Repo -TempFolder $TempFolder -RepoUrl $RepoUrl

