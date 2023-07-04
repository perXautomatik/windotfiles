<# Synopsis: Clones a source repository as a mirror and filters out unwanted files
# Parameters:
#   -Source: The path to the source repository
#   -Parent: The path to the parent repository
#   -ParentName: The name of the parent repository
#   -TempFolder: The path to the temporary folder
#   -ToFilterBy: The name of the file to filter out
# Example usage:
Clone-And-Filter -Source 'U:\PortableApplauncher\PortableApps\2. file Organization\PortableApps\Beyond Compare 4' `
                  -Parent 'C:\Users\chris\AppData\Roaming\Scooter Software\Beyond Compare 4' `
                  -ParentName 'appdata' `
                  -TempFolder 'B:\ToGit\' `
                  -ToFilterBy 'BCPreferences.xml'

#>
function Clone-And-Filter {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Source,
        [Parameter(Mandatory=$true)]
        [string]$Parent,
        [Parameter(Mandatory=$true)]
        [string]$ParentName,
        [Parameter(Mandatory=$true)]
        [string]$TempFolder,
        [Parameter(Mandatory=$true)]
        [string]$ToFilterBy
    )

    # Change directory to the temporary folder
    Set-Location $TempFolder

    # Clone the source repository as a mirror
    git clone --mirror $Source .

    # Change directory to the cloned repository
    Set-Location ($TempFolder)

    # Set the core.bare option to false
    git config --bool core.bare false 

    # Add and commit all files
    git add . ; git commit -m 'etc' 

    # Filter out the unwanted file from all branches
    $filter = 'git rm --cached -qr --ignore-unmatch -- . && git reset -q $GIT_COMMIT -- '+$ToFilterBy
    git filter-branch --index-filter $filter --prune-empty -- --all

    # Add the parent repository as a remote
    git remote add $parentName $parent

    # Filter out the .gitignore file from all branches
    git filter-branch --index-filter 'git rm --cached -qr --ignore-unmatch -- . && git reset -q $GIT_COMMIT -- .gitignore' --prune-empty -- --all
}

