# A function that initializes a new git repository in the current directory
Function Init-GitRepo {
    # No parameters needed for this function
    # Call the git init command
    git init
}

# A function that adds a remote repository to the local git repository
Function Add-GitRemote {
    Param (
        # The name of the remote repository
        [Parameter(Mandatory=$true)]
        [string]$RemoteName,

        # The path or URL of the remote repository
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container -IsValid})]
        [string]$RemotePath
    )

    # Call the git remote add command with the parameters
    git remote add $RemoteName $RemotePath
}

# A function that fetches all the branches and tags from a remote repository
Function Fetch-GitAll {
    Param (
        # The name of the remote repository
        [Parameter(Mandatory=$true)]
        [string]$RemoteName
    )

    # Call the git fetch --all command with the parameter
    git fetch --all $RemoteName
}

# A function that checks out a branch from a remote repository
Function Checkout-GitBranch {
    Param (
        # The name of the remote repository
        [Parameter(Mandatory=$true)]
        [string]$RemoteName,

        # The name of the branch to check out
        [Parameter(Mandatory=$true)]
        [string]$BranchName
    )

    # Call the git checkout command with the parameters
    git checkout $RemoteName/$BranchName
}

# A function that switches to a different branch in the local git repository
Function Switch-GitBranch {
    Param (
        # The name of the branch to switch to
        [Parameter(Mandatory=$true)]
        [string]$BranchName
    )

    # Call the git switch command with the parameter
    git switch $BranchName
}

# A function that filters the files and folders in the current branch using git-filter-repo
Function Filter-GitRepo {
    Param (
        # The subdirectory to filter by
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Container -IsValid})]
        [string]$Subdirectory,

        # The flag to force overwrite the existing repo history
        [switch]$Force
    )

    # Call the git filter-repo command with the parameters
    git filter-repo --subdirectory-filter $Subdirectory -f:$Force
}

# A function that renames a branch in the local git repository
Function Rename-GitBranch {
    Param (
        # The old name of the branch to rename
        [Parameter(Mandatory=$true)]
        [string]$OldName,

        # The new name of the branch to rename
        [Parameter(Mandatory=$true)]
        [string]$NewName
    )

    # Call the git branch -m command with the parameters
    git branch -m $OldName $NewName
}

# A function that pushes a branch from the local git repository to a remote repository and sets it as upstream branch 
Function Push-GitBranch {
    Param (
        # The name of the remote repository to push to 
        [Parameter(Mandatory=$true)]
        [string]$RemoteName,

        # The name of the branch to push 
        [Parameter(Mandatory=$true)]
        [string]$BranchName,

        # The flag to force overwrite any existing remote branch 
        [switch]$Force 
    )

    # Call the git push command with the parameters 
    git push $RemoteName -u $BranchName --force:$Force 
}

# Initialize a new git repo in C:\temp\repo 
Set-Location C:\temp\repo 
Init-GitRepo 

# Add a remote repo named scoop with path C:\ProgramData\scoop\persist\PowerShellCmdHist 
Add-GitRemote -RemoteName scoop -RemotePath 'C:\ProgramData\scoop\persist\PowerShellCmdHist' 

# Fetch all branches and tags from scoop 
Fetch-GitAll -RemoteName scoop 

# Checkout onlytxt branch from scoop 
Checkout-GitBranch -RemoteName scoop -BranchName onlytxt 

# Switch to onlytxt branch locally 
Switch-GitBranch -BranchName onlytxt 

# Filter files and folders by PSReadline subdirectory and force overwrite history 
Filter-GitRepo -Subdirectory PSReadline -Force 

# Rename onlytxt branch to OnlyPSReadline 
Rename-GitBranch -OldName onlytxt -NewName OnlyPSReadline 

# Push OnlyPSReadline branch to scoop and set it as upstream branch and force overwrite remote branch 
Push-GitBranch -RemoteName scoop -BranchName OnlyPSReadline -Force 
