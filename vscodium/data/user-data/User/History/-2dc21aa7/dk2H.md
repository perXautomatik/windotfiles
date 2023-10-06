# Synopsis: Creates multiple branches from a dictionary of relative paths and aliases.
# Parameters:
#   -rp: A dictionary of relative paths and aliases.
#   -remotePath: The remote path to push the branches to.
function Create-MultipleBranches {
  param (
    [Parameter(Mandatory=$true)]
    [Dictionary[string, string]] $rp,
    [Parameter(Mandatory=$true)]
    [string] $remotePath
  )

  # Validate the parameters.
  if (!$rp.Count) {
    throw "The -rp parameter must not be empty."
  }
  if (-not $remotePath.Trim()) {
    throw "The -remotePath parameter must not be empty."
  }

  # Get the repo branch names.
  $branches = Get-RepoBranchNames

  # Create an array to store the successful branch creations.
  $successfulBranches = @()

  # Iterate over the branches and create them.
  foreach ($branch in $branches) {
    # Get the relative path of the branch head.
    $relPath = Get-BranchHeadPaths $branch.BranchName

    # Check if the relative path matches a path in the -rp parameter.
    $relPath = $relPath ? $relPath.Match($rp.Relative) : $null

    # If the relative path matches, create the branch.
    if ($relPath) {
      # Create an array of the branch name, ref, and relative path.
      $creationArray = @($relPath.BaseName, $branch.Ref, $relPath.Parent)

      # Create a valid branch name.
      $branchName = Create-ValidBranchName $creationArray, @"{1}_{2}-{3}" -CheckAgainstRepo

      # Create the branch.
      $successfulBranch = Create-MultipleBranches -BranchName $branchName -Ref $branch.Ref -RelativePath $relPath

      # Add the successful branch to the array.
      $successfulBranches += $successfulBranch
    }
  }

  # Set the remote for the successful branches.
  $successfulBranches | Set-Remote -RemotePath $remotePath

  # Return the successful branches.
  return $successfulBranches
}

# Synopsis: Creates a valid branch name from an array of strings and a string embedding.
# Parameters:
#   -array: An array of strings to use to create the branch name.
#   -stringEmbedding: A string embedding to use to create the branch name.
#   -checkAgainstRepo: A boolean value indicating whether to check if the branch name already exists in the repository.
# Returns: A valid branch name.
function Create-ValidBranchName {
  param (
    [Parameter(Mandatory=$true)]
    [string[]] $array,
    [Parameter(Mandatory=$true)]
    [string] $stringEmbedding,
    [Parameter(Mandatory=$false)]
    [switch] $CheckAgainstRepo = $false
  )

  # Validate the parameters.
  if (!$array.Count) {
    throw "The -array parameter must not be empty."
  }
  if (-not $stringEmbedding.Trim()) {
    throw "The -stringEmbedding parameter must not be empty."
  }

  # Create a string from the array using the string embedding.
  $branchName = $stringEmbedding.Format($array)

  # Trim the branch name to the correct length.
  $branchName = $branchName.Substring(0, 255)

  # Remove any unsuitable characters from the branch name.
  $branchName = $branchName.Replace("/", "-")
  $branchName = $branchName.Replace(":", "_")
  $branchName = $branchName.Replace("*", "_")
  $branchName = $branchName.Replace("\?", "_")
  $branchName = $branchName.Replace("\"", "_")
  $branchName = $branchName.Replace("\<", "_")
  $branchName = $branchName.Replace("\>", "_")
  $branchName = $branchName.Replace("\|", "_")

  # Check if the branch name already exists in the repository.
  if ($CheckAgainstRepo) {
    $branches = Get-RepoBranchNames
    if ($branches.ContainsKey($branch
