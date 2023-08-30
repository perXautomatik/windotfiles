
# Save the current location
Push-Location

# Change to the first repository location
cd 'D:\Project Shelf\PowerShellProjectFolder\scripts'

# Parse the output of git ls-tree command and add more properties to the objects
$repo1 = git ls-tree -r HEAD  | Parse-GitLsTreeOutput  | Add-MorePropertiesToGitLsTreeOutput

# Change to the second repository location
cd 'D:\Project Shelf\PowerShellProjectFolder'

# Parse the output of git ls-tree command and add more properties to the objects
$repo2 = git ls-tree -r HEAD  | Parse-GitLsTreeOutput  | Add-MorePropertiesToGitLsTreeOutput

# Select the first object from the first repository for testing
$repo1 | select -First 1

# Join the two collections by file name and get the result array
$joinedResult = Join-GitLsTreeOutputCollectionsByFileName $repo1 $repo2

# Create a lookup table by hash from the first collection and get the result array
$lookupResult = Create-LookupTableByHash $repo1

# Restore the original location
Pop-Location

