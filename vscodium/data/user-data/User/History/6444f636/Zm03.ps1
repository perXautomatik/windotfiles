
    <#
    .SYNOPSIS
#This script adds git submodules to a working path based on the .gitmodules file


    .PARAMETER WorkPath
    The working path where the .gitmodules file is located.

    .EXAMPLE
    GitInitializeBySubmodule -WorkPath 'B:\ToGit\Projectfolder\NewWindows\scoopbucket-1'

    #>

# requires functional git repo
# A function to get the submodules recursively for a given repo path
# should return the submodules in reverse order, deepest first, when not providing flag?
function Get-SubmoduleDeep {
    param(
        [Parameter(Mandatory=$true)]
        [string]$RepoPath # The path to the repo
    )

    begin {
        # Validate the repo path
        Validate-PathW -Path $RepoPath

        # Change the current directory to the repo path
        Set-Location $RepoPath

        # Initialize an empty array for the result
        $result = @()
    }

    process {
        # Run git submodule foreach and capture the output as an array of lines
        $list = @(Invoke-Git "submodule foreach --recursive 'git rev-parse --git-dir'")

        # Loop through the list and skip the last line (which is "Entering '...'")
        foreach ($i in 0.. ($list.count-2)) { 
        # Check if the index is even, which means it is a relative path line
        if ($i % 2 -eq 0) 
        {
            # Create a custom object with the base, relative and gitDir properties and add it to the result array
            $result += , [PSCustomObject]@{
                base = $RepoPath
                relative = $list[$i]
                gitDir = $list[$i+1]
            }
        }
        }
        
    }

    end {
        # Return the result array
        $result 
    }
}
Function Git-InitializeSubmodules {
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='High')]
       Param(
        # File to Create
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_})]
        [string]
        $RepoPath
    )
    begin{            
        # Validate the parameter
        # Set the execution policy to bypass for the current process
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

    	Write-Verbose "[Add Git Submodule from .gitmodules]"    
    }
    process{    
        # Filter out the custom objects that have a path property and loop through them
        Get-SubmoduleDeep | Where-Object {($_.path)} | 
         %{ 
            $url = $_.url
            $path = $_.path
            try {
                if( New-Item -ItemType dir -Name $path -WhatIf -ErrorAction SilentlyContinue)
                {
                    if($PSCmdlet.ShouldProcess($path,"clone $url -->")){                                                   
                    
                    }
                    else
                    {
                        invoke-git "submodule add $url $path"
                    }
                }
                else
                {
                    if($PSCmdlet.ShouldProcess($path,"folder already exsists, will trye to clone $url --> "))
                    {   
                        
                    }
                    else
                    {
                        Invoke-Git "submodule add -f $url $path"                        
                    }
                }
                    # Try to add a git submodule using the path and url properties
        
        }
        catch {
            Write-Error "Could not add git submodule: $_"
        }
        }
    }
}

<#
.SYNOPSIS
Unabsorbe-ValidGitmodules from a git repository.

.DESCRIPTION
Unabsorbe-ValidGitmodules from a git repository by moving the .git directories from the submodules to the parent repository and updating the configuration.

.PARAMETER Paths
The paths of the submodules to extract. If not specified, all submodules are extracted.

.EXAMPLE
Extract-Submodules

.EXAMPLE
Extract-Submodules "foo" "bar"
[alias]
    extract-submodules = "!gitextractsubmodules() { set -e && { if [ 0 -lt \"$#\" ]; then printf \"%s\\n\" \"$@\"; else git ls-files --stage | sed -n \"s/^160000 [a-fA-F0-9]\\+ [0-9]\\+\\s*//p\"; fi; } | { local path && while read -r path; do if [ -f \"${path}/.git\" ]; then local git_dir && git_dir=\"$(git -C \"${path}\" rev-parse --absolute-git-dir)\" && if [ -d \"${git_dir}\" ]; then printf \"%s\t%s\n\" \"${git_dir}\" \"${path}/.git\" && mv --no-target-directory --backup=simple -- \"${git_dir}\" \"${path}/.git\" && git --work-tree=\"${path}\" --git-dir=\"${path}/.git\" config --local --path --unset core.worktree && rm -f -- \"${path}/.git~\" && if 1>&- command -v attrib.exe; then MSYS2_ARG_CONV_EXCL=\"*\" attrib.exe \"+H\" \"/D\" \"${path}/.git\"; fi; fi; fi; done; }; } && gitextractsubmodules"

    git extract-submodules [<path>...]
#>
function Unabsorbe-ValidGitmodules {
    param (
        [string[]]$Paths
    )

    # get the paths of all submodules if not specified
    if (-not $Paths) {
        $Paths = Get-SubmoduleDeep
    }

    # loop through each submodule path
    foreach ($Path in $Paths) {
        $gg = "$Path/.git"
        
        # check if the submodule has a .git file
        if (Test-Path -Path "$gg" -PathType Leaf) {
            # get the absolute path of the .git directory
            $GitDir = Get-GitDir -Path $Path

            # check if the .git directory exists
            if (Test-Path -Path $GitDir -PathType Container) {
                # display the .git directory and the .git file
                Write-Host "$GitDir`t$gg"

                # move the .git directory to the submodule path
                Move-Item -Path $GitDir -Destination "$gg" -Force -Backup

                # unset the core.worktree config for the submodule
                Remove-Worktree -ConfigPath "$gg/config"

                # remove the backup file if any
                Remove-Item -Path "$gg~" -Force -ErrorAction SilentlyContinue

                # hide the .git directory on Windows
                Hide-GitDir -Path $Path
            }
        }
    }
}



# \GitUpdateSubmodulesAutomatically.ps1
<#
.SYNOPSIS
Updates the submodules of a git repository.

.DESCRIPTION
This function updates the submodules of a git repository, using the PsIni module and the git commands. The function removes any broken submodules, adds any new submodules, syncs the submodule URLs with the .gitmodules file, and pushes the changes to the remote repository.

.PARAMETER RepositoryPath
The path of the git repository where the submodules are located.

.PARAMETER SubmoduleNames
An array of submodule names that will be updated. If not specified, all submodules will be updated.
#>
function Update-Git-Submodules {
  [CmdletBinding()]
  param (
      [Parameter(Mandatory = $true)]
      [string]
      $RepositoryPath,

      [Parameter(Mandatory = $false)]
      [string[]]
      $SubmoduleNames
  )

    # Set the error action preference to stop on any error
    $ErrorActionPreference = "Stop"

    # Change the current location to the repository path
    Set-Location -Path $RepositoryPath  

    #update .gitmodules
    config-to-gitmodules

    $submodules = Get-SubmoduleDeep $RepositoryPath

    # If submodule names are specified, filter out only those submodules from the array
    if ($SubmoduleNames) {
        $submodules = $submodules | Where-Object { $_.submodule.Name -in $SubmoduleNames }
    }

    # Loop through each submodule in the array and update it
    foreach ($submodule in $submodules) {
                
        
        # Get all submodules from the .gitmodules file as an array of objects    

        $submodulePath = $submodule.path

        # Check if submodule directory exists
        
        if (Test-Path -Path $submodulePath) {
            
            # Change current location to submodule directory
            
            Push-Location -Path $submodulePath
            
            # Get submodule URL from git config
            $submoduleUrl = Get-GitRemoteUrl
            
            # Check if submodule URL is empty or local path
            if ([string]::IsNullOrEmpty($submoduleUrl) -or (Test-Path -Path $submoduleUrl)) {
            
                # Set submodule URL to remote origin URL
                $submoduleUrl = (byPath-RepoUrl -Path $submodulePath)
                if(!($submoduleUrl))
                {
                    $submoduleUrl = $submodule.url
                }
                
                Set-GitRemoteUrl -Url  $submoduleUrl                    
            }

            # Return to previous location
            
            Pop-Location
            
            # Update submodule recursively
            
            Invoke-Git "submodule update --init --recursive $submodulePath"
            
        }        
        else {            
            # Add submodule from remote URL
            
            Invoke-Git "submodule add $(byPath-RepoUrl -Path $submodulePath) $submodulePath"            
        }
    
    }

  # Sync the submodule URLs with the .gitmodules file
  Invoke-Git "submodule sync"

  # Push the changes to the remote repository
  Invoke-Git "push origin master"
}




function Healthy-GetSubmodules {
   
    # Synopsis: A script to get the submodules recursively for a given repo path or a list of repo paths
    # Parameter: RepoPaths - The path or paths to the repos
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$RepoPaths # The path or paths to the repos
    )

    # A function to validate a path argument
    # Call the main function for each repo path in the pipeline
    foreach ($RepoPath in $RepoPaths) {
      Get-SubmoduleDeep -RepoPath $RepoPath
    }
}


# \git_add_submodule.ps1
#Get-Content .\.gitmodules | ? { $_ -match 'url' } | % { ($_ -split "=")[1].trim() } 
function git_add_submodule () {
    Write-Host "[Add Git Submodule from .gitmodules]" -ForegroundColor Green
    Write-Host "... Dump git_add_submodule.temp ..." -ForegroundColor DarkGray
    git config -f .gitmodules --get-regexp '^submodule\..*\.path$' > git_add_submodule.temp

    Get-content git_add_submodule.temp | ForEach-Object {
            try {
                $path_key, $path = $_.split(" ")
                $url_key = "$path_key" -replace "\.path",".url"
                $url= git config -f .gitmodules --get "$url_key"
                Write-Host "$url  -->  $path" -ForegroundColor DarkCyan
                Invoke-Git "submodule add $url $path"
            } catch {
                Write-Host $_.Exception.Message -ForegroundColor Red
                continue
            }
        }
    Write-Host "... Remove git_add_submodule.temp ..." -ForegroundColor DarkGray
    Remove-Item git_add_submodule.temp
}

#Git-InitializeSubmodules -repoPath 'G:\ToGit\projectFolderBare\scoopbucket-presist'

# \removeAtPathReadToIndex.ps1

function removeAtPathReadToIndex {

    param (
        [Parameter(Mandatory=$true, HelpMessage=".git, The path of the git folder to convert")]
        [ValidateScript({Test-Path $_ -PathType Container ; Resolve-Path -Path $_ -ErrorAction Stop})] 
        [Alias("GitFolder")][string]$errorus,[Parameter(Mandatory=$true,HelpMessage="subModuleRepoDir, The path of the submodule folder to replace the git folder")]
        #can be done with everything and menu
        [Parameter(Mandatory=$true,HelpMessage="subModuleDirInsideGit")]
        [ValidateScript({Test-Path $_ -PathType Container ; Resolve-Path -Path $_ -ErrorAction Stop})]
        [Alias("SubmoduleFolder")][string]$toReplaceWith
    )

        # Get the config file path from the git folder
        $configFile = Join-Path $GitFolder 'config'
        # Push the current location and change to the target folder

        # Get the target folder, name and parent path from the git folder
        Write-Verbos "#---- asFile"
 
        $asFile = ([System.IO.Fileinfo]$errorus.trim('\'))
     
        Write-Verbos $asFile
    
        $targetFolder = $asFile.Directory
        $name = $targetFolder.Name
        $path = $targetFolder.Parent.FullName  

        about-Repo #does nothing without -verbos

        
        Push-Location
        Set-Location $targetFolder
        
        index-Remove $name	$path

        # Change to the parent path and get the root of the git repository
        
        # Add and absorb the submodule using the relative path and remote url
        $relative = get-Relative $path $targetFolder

        Add-AbsorbSubmodule -Ref ( get-Origin) -Relative $relative

        # Pop back to the previous location
        Pop-Location

        # Restore the previous error action preference
        $ErrorActionPreference = $previousErrorAction

    }

