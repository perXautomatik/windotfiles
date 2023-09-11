. .\New-TempFolder.ps1

. .\Clone-Repo.ps1

. .\Filter-Repo.ps1

. .\Merge-Refs.ps1

. .\Rename-Branch.ps1

. .\Push-Repo.ps1

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

