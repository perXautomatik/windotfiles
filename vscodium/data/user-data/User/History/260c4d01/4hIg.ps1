# Set the error action preference to stop on any error
$ErrorActionPreference = "Stop"

Import-Module PsIni

# Call the function with a submodule path
Get-SubmoduleUrl "B:\ToGit\.git\modules\BucketTemplate"

# Check the status of the submodules
Invoke-Git "submodule status"

# Update the submodules recursively
Invoke-Git "submodule update --init --recursive"

# Sync the submodule URLs with the .gitmodules file
Invoke-Git "submodule sync"

# Remove any broken submodules manually or with a loop
# For example, to remove a submodule named foo:
Invoke-Git "rm --cached foo"
Remove-Item -Path ".git/modules/foo" -Recurse -Force

# Add any new submodules manually or with a loop
# For example, to add a submodule named bar:
Invoke-Git "add bar"
Invoke-Git "submodule update --init --recursive"

# Push the changes to the remote repository
Invoke-Git "push origin master"

