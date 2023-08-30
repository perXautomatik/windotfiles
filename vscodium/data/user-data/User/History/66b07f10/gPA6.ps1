  
    <#
    .SYNOPSIS
    Changes the current directory to the specified path.
    .EXAMPLE
    Change-Directory -Path 'C:\Users\chris\AppData'
    #>
# This function changes the current directory to the specified path
function Change-Directory {
    [CmdletBinding()]
    param(
      # The path to change to
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Path
    )

  
    # Change the current directory
    Set-Location -Path $Path
  }
    
    <#
    .SYNOPSIS
    Pushes all branches to a remote repository.
    .EXAMPLE
    Push-AllBranches -Remote 'D:\ToGit\AppData'
    #>
  # This function pushes all branches to a remote repository
  function Push-AllBranches {
    [CmdletBinding()]
    param(
      # The remote repository to push to
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Remote
    )

  
    # Push all branches to the remote repository
    git push --all $Remote
  }
      <#
    .SYNOPSIS
    Filters a branch to a subdirectory and rewrites its history.
    .EXAMPLE
    Filter-Branch -Subdirectory 'Roaming/Vortex/' -Branch '--all'
    #>
  # This function filters a branch to a subdirectory and rewrites its history
  function Filter-Branch {
    [CmdletBinding()]
    param(
      # The subdirectory to filter to
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Subdirectory,
  
      # The branch to filter
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Branch
    )
  

  
    # Filter the branch to the subdirectory and rewrite its history
    git filter-branch -f --subdirectory-filter $Subdirectory -- $Branch 
  }
       <#
     .SYNOPSIS
     Pulls in any new commits from a remote subtree.
     .EXAMPLE
     Pull-Subtree -Prefix 'Roaming/Vortex/' -Remote 'C:\Users\chris\AppData\.git' -Branch LargeINcluding 
     #>
  # This function pulls in any new commits from a remote subtree
  function Pull-Subtree {
    [CmdletBinding()]
    param(
      # The prefix of the subtree
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Prefix,
  
      # The remote repository of the subtree
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Remote,
  
      # The branch of the subtree
      [Parameter(Mandatory=$true)]
      [ValidateNotNullOrEmpty()]
      [string]$Branch
    )
     # Pull in any new commits from the remote subtree 
     git subtree pull --prefix $Prefix $Remote $Branch 
  }
  
  # This is the main script that calls the functions
  
  Change-Directory -Path 'C:\Users\chris\AppData'
  
  Push-AllBranches -Remote 'D:\ToGit\AppData'
  
  Change-Directory -Path 'D:\ToGit\Vortex'
  
  Filter-Branch -Subdirectory 'Roaming/Vortex/' -Branch '--all'
  
  Pull-Subtree -Prefix 'Roaming/Vortex/' -Remote 'C:\Users\chris\AppData\.git' -Branch LargeINcluding 
  