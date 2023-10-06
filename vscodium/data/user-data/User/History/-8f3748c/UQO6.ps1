
function Get-FileNames {
    # Get the list of file names from a text file
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    # Validate the path parameter
    if (-not (Test-Path $Path)) {
        throw "Invalid path: $Path"
    }
    # Return the unique file names from the text file
    Get-Content $Path | Select-Object -Unique
}

function Get-RepoPath {
    # Get the path of the original repository
    param (
        [Parameter(Mandatory=$true)]
        [string]$Repo
    )
    # Validate the repo parameter
    if (-not (Test-Path $Repo)) {
        throw "Invalid repository: $Repo"
    }
    # Return the full path of the repository
    Resolve-Path $Repo
}

function Create-Folder {
    # Create a folder to store the filtered repositories
    param (
        [Parameter(Mandatory=$true)]
        [string]$Folder
    )
    # Validate the folder parameter
    if (Test-Path $Folder) {
        throw "Folder already exists: $Folder"
    }
    # Create the folder and return it
    New-Item -ItemType Directory -Path $Folder | Out-Null
    Write-Output $Folder
}

function CloneWithReference {
    # Clone a repository with reference to another repository
    param (
        [Parameter(Mandatory=$true)]
        [string]$Repo,
        [Parameter(Mandatory=$true)]
        [string]$ObjectRepo,
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [switch]$AllowFilter
    )
    
    # Validate the parameters
    if (-not (Test-Path $Repo)) {
        throw "Invalid repository: $Repo"
    }
    if (-not (Test-Path $ObjectRepo)) {
        throw "Invalid object repository: $ObjectRepo"
    }
    if (Test-Path $Path) {
        throw "Path already exists: $Path"
    }

    # Set the git config for allow filter if specified
    if ($AllowFilter) {
        cd $Repo; git config --local uploadpack.allowFilter true
    }

    # Clone the repository with reference to the object repository and return the path
    git clone --reference $ObjectRepo --dissociate $Repo $Path | Out-Null
    Write-Output $Path

}

function BranchByPattern {
    # Create a branch based on a pattern in the file names
    param (
        [Parameter(Mandatory=$true)]
        [string]$Pattern,
        [switch]$Force
    )

    # Validate the pattern parameter
    if (-not ($Pattern)) {
        throw "Invalid pattern: $Pattern"
    }

    # Get the matching file names from the current directory
    $files = git ls-files | Where-Object { $_ -match $Pattern }

    # Check if there are any matching files
    if ($files) {

        # Create a branch name based on the pattern
        $branch = "branch-$Pattern"

        # Check if the branch already exists and force delete it if specified
        if (git branch --list $branch) {
            if ($Force) {
                git branch -D $branch | Out-Null
            }
            else {
                throw "Branch already exists: $branch"
            }
        }

        # Create a new branch and check out to it
        git checkout -b $branch | Out-Null

        # Filter out the non-matching files from the branch
        git ls-files | Where-Object { $_ -notmatch $Pattern } | ForEach-Object { git rm --cached $_ } | Out-Null

        # Commit the changes to the branch
        git commit -m "Filtered for $Pattern" | Out-Null

        # Return the branch name
        Write-Output $branch

    }
    
}

# Main script

# Get the list of file names from a text file or clipboard 
#$files = Get-FileNames -Path "B:\GitPs1Module\filelist.txt"
$files = Get-Clipboard 
$files = $files | Select-Object -Unique

# Get the path of the original repository and its clone destination 
$repo = Get-RepoPath -Repo "B:\PF\Archive\ps1"
$clonedRepo = "B:\ps1"

# Create a folder to store the filtered repositories 
Create-Folder -Folder "$repo\filtered"

# Clone the repository with reference and allow filter 
try {
    
   CloneWithReference -Repo $repo -ObjectRepo $repo -Path $clonedRepo -AllowFilter
    
    cd $clonedRepo
    
    Write-Output "---"
}
catch {
    Write-Error $_
    Write-Error "Failed to clone into $clonedRepo"
}

# Loop through each file name in the list 
foreach ($file in $files) {

    # Change the current directory to the subfolder 
    cd $clonedRepo

    try {

        # Create a branch based on the file name pattern 
        BranchByPattern -Pattern $file -Force
  
    }
    catch {
        Write-Error "Failed to Filter for $file"
        Write-Error $_
    }
 
}

# Return the folder with the filtered repositories 
Write-Output "$repo\filtered"
