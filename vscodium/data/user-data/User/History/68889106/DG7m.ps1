Sure, I can try to write you a PowerShell script that uses the technique of comparing the hashes of commits to find duplicates. Here is a possible script:

# Define a function to get the hash of a commit
function Get-CommitHash ($commit) {
  # Use git rev-parse to get the full hash of the commit
  $hash = git rev-parse $commit
  # Return the first 16 characters of the hash
  return $hash.Substring(0,16)
}

# Define a function to get the tree hash of a commit
function Get-TreeHash ($commit) {
  # Use git cat-file to get the tree hash of the commit
  $tree = git cat-file -p $commit | Select-String "tree"
  # Return the second word of the output, which is the tree hash
  return $tree.ToString().Split()[1]
}

# Define a function to get the list of commits in a branch
function Get-CommitList ($branch) {
  # Use git log to get the list of commits in reverse chronological order
  $log = git log --pretty=format:"%h" --no-merges --reverse $branch
  # Return the output as an array of strings
  return $log.ToString().Split()
}

# Define a function to check if two commits are duplicates
function Is-Duplicate ($commit1, $commit2) {
  # Get the hashes and tree hashes of both commits
  $hash1 = Get-CommitHash $commit1
  $hash2 = Get-CommitHash $commit2
  $tree1 = Get-TreeHash $commit1
  $tree2 = Get-TreeHash $commit2
  # Compare the hashes and tree hashes and return true if they are equal, false otherwise
  return ($hash1 -eq $hash2) -and ($tree1 -eq $tree2)
}

# Define a function to find and print duplicate commits in a branch
function Find-Duplicates ($branch) {
  # Get the list of commits in the branch
  $commits = Get-CommitList $branch
  # Loop through each commit and compare it with the rest of the list
  for ($i = 0; $i -lt $commits.Length; $i++) {
    for ($j = $i + 1; $j -lt $commits.Length; $j++) {
      # Check if the two commits are duplicates
      if (Is-Duplicate $commits[$i] $commits[$j]) {
        # Print the hashes and messages of the duplicate commits
        Write-Host "Duplicate commits found:"
        Write-Host (git show --no-patch --oneline $commits[$i])
        Write-Host (git show --no-patch --oneline $commits[$j])
      }
    }
  }
}

# Invoke the function with the name of your branch as an argument
Find-Duplicates "dev"

I hope this script works for you. 😊

Källa: Konversation med Bing, 2023-09-13
(1) github - Fixing git double-commit history - Stack Overflow. https://stackoverflow.com/questions/22817360/fixing-git-double-commit-history.
(2) Git commits are duplicated in the same branch after doing a rebase. https://stackoverflow.com/questions/9264314/git-commits-are-duplicated-in-the-same-branch-after-doing-a-rebase.
(3) Find and remove duplicate files with PowerShell – 4sysops. https://4sysops.com/archives/find-and-remove-duplicate-files-with-powershell/.
(4) How can I get the Git commit hash in my PS script?. https://stackoverflow.com/questions/43962860/how-can-i-get-the-git-commit-hash-in-my-ps-script.