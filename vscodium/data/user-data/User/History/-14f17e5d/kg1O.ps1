  
  function Get-Submodules {
  # Define a function to get the submodules of a git repository as an array of custom objects
      param(
          [string]$RepoPath # The path of the git repository
      )
      # Change the current location to the repository path
      Set-Location -Path $RepoPath

      # Run the git command to get the submodules and their git directories
      $list = @(Invoke-Git "submodule foreach --recursive 'git rev-parse --git-dir'")

      # Initialize an empty array for the result
      $result = @()

      # Loop through each item in the list and skip the odd ones
      foreach ($i in 0.. ($list.count-2)) {
          if ($i % 2 -eq 0) {
              # Create a custom object with the base, relative and gitDir properties
              $result += , [PSCustomObject]@{
                  base = $RepoPath
                  relative = ($list[$i] -split "'")[1]
                  gitDir = $list[$i+1]
              }
          }
      }
      # Return the result as output
      return $result
  }

  function Invoke-Git {
    # Define a function to run git commands and check the exit code
      param(
          [string]$Command # The git command to run
      )
      # Run the command and capture the output
      $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
      # Write the output to the host
      Write-Host $output
      # Check the exit code and throw an exception if not zero
      if ($LASTEXITCODE -ne 0) {
          throw "Git command failed: git $Command"
      }
  }


function SetWorktreeSubmodules {
<#
.SYNOPSIS
Compares the submodules of two git repositories and sets their worktrees.

.DESCRIPTION
This function compares the submodules of two git repositories and sets their worktrees, using the git commands and the Linq.Enumerable.Join method. The function expects the submodules to have the same relative paths in both repositories, and uses them as the join key. The function also outputs the result of the comparison and the worktree configuration.

.PARAMETER RepoPath1
The path of the first git repository.

.PARAMETER RepoPath2
The path of the second git repository.
#>
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string]
      $RepoPath1,

      [Parameter(Mandatory = $true)]
      [string]
      $RepoPath2
  )

  # Get the submodules of both repositories as arrays of custom objects
  $submodules1 = Get-Submodules -RepoPath $RepoPath1 | Select-Object @{name='GitDirSP'; expression={$_.gitdir} },relative, @{name='baseSP'; expression={$_.base} }
  $submodules2 = Get-Submodules -RepoPath $RepoPath2

  # Define a function to get the relative property of an object
  [System.Func[System.Object, string]]$getRelative = {
      param ($x)
      $x.relative
  }

  # Join the two arrays by their relative property and select a new object with all properties.
  $joined = [System.Linq.Enumerable]::Join(
    $submodules1,
    $submodules2,
    $getRelative, # outer key selector
    $getRelative, # inner key selector
    [Func [object,object,object]] { param($x,$y) # result selector
      # Create a new object with all properties from both objects.
      $props = @{}
      foreach ($prop in ($x.psobject.Properties+$y.psobject.Properties)) { $props[$prop.Name] = $prop.Value }
      [pscustomobject] $props
    }
  )

  # Output the result.
  Write-Host "The joined submodules are:"
  Write-Host ($joined | Format-Table | Out-String)

  # Loop through each joined submodule and set its worktree to its full path
  foreach ($submodule in $joined) {
      
  # Change current location to submodule directory
  
  Set-Location -Path (Join-Path -Path $submodule.baseSP -ChildPath $submodule.relative)
  
  # Get submodule full path
  
  $q = Join-Path -Path $submodule.base -ChildPath $submodule.relative
  
  # Get submodule worktree from git config
  
  $worktree = Invoke-Git "config --get core.worktree"
  
  # Check if worktree is empty or different from full path
  
  if ([string]::IsNullOrEmpty($worktree) -or ($worktree -ne $q)) {
    
    # Set submodule worktree to full path
    
    Invoke-Git "config --local --replace-all core.worktree $q"
    
  }
  
}

}
