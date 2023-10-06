<#
   ========================================================================================================================
   Name         : <Name>.ps1
   Description  : This script ............................
   Created Date : %Date%
   Created By   : %UserName%
   Dependencies : 1) Windows PowerShell 5.1
                  2) .................

   Revision History
   Date       Release  Change By      Description
   %Date% 1.0      %UserName%     Initial Release

	can you write me a powershell script that takes a number of files as input, 
	for each file assume each file belonge to the same git repo; 
	begin block; 
	tag with "before merge", 
	select one of the files (arbitarly, if non specified as parameter) 
	as the target file, process block; for each file; 
	move file to a new folder called merged, 
	rename the file to same name as target file, 
	commit this change with message: 
	original relative path in repo, 
	create a tag with index of the for each, 
	reset the repo hard to the before merge tag. 
	end block; for each tag created with index, 
	do merge this tag to repo, resolve the merge by unioning both of the conflicting files
   ========================================================================================================================
#>

function New-GitTag {
<#
.Synopsis
This function creates a new Git tag with the given name and message
.Parameter TagName
The name of the new Git tag
.Parameter TagMessage
The message of the new Git tag
.Example
New-GitTag -TagName "before merge" -TagMessage "Before merge"
#>
    [CmdletBinding()]
    param (
      # The name of the new Git tag
      [Parameter(Mandatory=$true)]
      [string]$TagName,
  
      # The message of the new Git tag
      [Parameter(Mandatory=$true)]
      [string]$TagMessage
    )
  
    # Validate the tag name and message
    if ($TagName -eq $null -or $TagName -eq "") {
	Write-Error "Tag name cannot be null or empty"
	return
    }

    if ($TagMessage -eq $null -or $TagMessage -eq "") {
	Write-Error "Tag message cannot be null or empty"
	return
    }

    # Invoke the git tag command with the parameters
    # Create the tag with the message
    git tag -a $TagName -m $TagMessage
  }
  
function Get-GitRelativePath {
  <#
  .Synopsis
  This function gets the relative path of a file in the current Git repository
  .Parameter FilePath
  The absolute or relative path of the file
  .Outputs
  The relative path of the file in the current Git repository
  .Example
  Get-GitRelativePath -FilePath ".\foo\bar.txt"
  #>
    [CmdletBinding()]
    param (
      # The path of the file
      [Parameter(Mandatory=$true)]
      [ValidateScript({Test-Path $_})]
      [string]$FilePath
    )
  
    # Validate the file path
    if ($FilePath -eq $null -or $FilePath -eq "") {
	Write-Error "File path cannot be null or empty"
	return
    }

    if (-not (Test-Path $FilePath)) {
	Write-Error "File path does not exist"
	return
    }
    # Get the absolute path of the file
    $absolutePath = Resolve-Path $FilePath
  
    # Get the relative path of the file in the repo
    git ls-files --full-name $FilePath
    # Get the root path of the current Git repository
    $rootPath = git rev-parse --show-toplevel
  
    # Get the relative path of the file by removing the root path from the absolute path
    $relativePath = $absolutePath -replace "^$rootPath\\"
  
    # Write the relative path to stdout
    Write-Output $relativePath
  }
  
function Reset-GitHard {
  <#
  .Synopsis
  This function resets the current Git repository hard to a given tag name
  .Parameter TagName
  The name of the tag to reset to
  .Example
  Reset-GitHard -TagName "before merge"
  #>
    [CmdletBinding()]
    param (
      # The name of the tag to reset to
      [Parameter(Mandatory=$true)]
      [ValidateScript({git tag -l | Select-String $_})]
      [string]$TagName
    )

    # Validate the tag name
    if ($null -eq $TagName -or $TagName -eq "") {
	Write-Error "Tag name cannot be null or empty"
	return
    }
  
    # Reset the repo hard to the tag
    # Invoke the git reset command with the tag name and --hard option
    git reset --hard $TagName
  }
  

function Merge-GitTag {
<#
.SYNOPSIS
Merges a tag to the repo and resolves conflicts by unioning files.

.DESCRIPTION
This function merges a tag to the current branch of the repo and resolves any merge conflicts by unioning both of the conflicting files. It also commits the merge with a message containing the tag name.

.PARAMETER TagName
The name of the tag to merge. This parameter is mandatory and cannot be null or empty.

.EXAMPLE
Merge-GitTag -TagName "v1.0"

This example merges the tag "v1.0" to the current branch and resolves any conflicts by unioning files.
  #>
    [CmdletBinding()]
    param (
      # The name of the tag to merge from 
      [Parameter(Mandatory=$true)]
	  [ValidateNotNullOrEmpty()]
      [ValidateScript({git tag -l | Select-String $_})]
      [string]$TagName 
    )
    try {
            # Invoke the git merge command with the tag name and --no-commit option 
            git merge $TagName --no-commit 
        
            # Resolve the merge by unioning both of the conflicting files
            git config merge.union.driver true
        
            # Check if there are any merge conflicts 
            if (git diff --name-only --diff-filter=U) { 
                # Loop through the conflicted files and resolve them by unioning their contents 
                foreach ($file in (git diff --name-only --diff-filter=U)) { 
                        # Use git merge-file command with --union option to union the contents of the file 
                        git merge-file --union $file 
                        # Add the resolved file to the index 
                        git add $file 
                    }
                }
            git commit -m "Merged tag $TagName"
        }
    catch {
		# Write an error message and exit
		Write-Error "Failed to merge tag $TagName : $_"
		exit 1
    }
  }

function mergeBranchAnResolve()
{
<#
    #----------------------------------------------------------
    powershell script that takes two branches, and a file as argument,

    checking out a new third branch,

    merge into third branch branch 1 and branch 2

    resolve this merge automatically by union
    commit
    then replace the files in the third branches content by the provided file from argument,
    commit with ammend.
#>
    # Get the arguments
    param (
      [string]$branch1,
      [string]$branch2,
      [string]$file
    )
    
    # Check if the arguments are valid
    if (-not $branch1 -or -not $branch2 -or -not $file) {
      Write-Error "Please provide two branches and a file as arguments"
      exit 1
    }
    
    if (-not (Test-Path $file)) {
      Write-Error "The file $file does not exist"
      exit 2
    }
    
    # Create a new branch from the current one
    git checkout -b merged-branch
    
    # Merge the two branches into the new branch using union merge strategy
    git merge -s recursive -X union $branch1 $branch2
    
    # Replace the content of the new branch with the file content
    Copy-Item $file -Destination . -Force
    
    # Amend the last commit with the new content
    git commit --amend --all --no-edit
}

function Rename-File {

# A powershell function that does the following:
# - Takes two relative paths as arguments
# - Uses filter-repo to change the name of a file from the old path to the new path

  # Get the arguments
  param (
    [string]$oldPath,
    [string]$newPath
  )

  # Check if the arguments are valid
  if (-not $oldPath -or -not $newPath) {
    Write-Error "Please provide two relative paths as arguments"
    return
  }

  # Use filter-repo to rename the file
  git filter-repo  --path-regex '^.*/$oldPath$' --path-rename :$newPath
}

function prefixCommit()
{
  # Use git-filter-repo to add the branch name as a prefix to each commit message in a branch
  git filter-repo --refs my-branch --message-callback "
    import subprocess
    branch = subprocess.check_output(['git', 'branch', '--contains', commit.original_id.decode('utf-8')]).decode('utf-8').strip().lstrip('* ')
    commit.message = b'[' + branch.encode('utf-8') + b']: ' + commit.message
  "

}

function Merge-Files {
    <#
    .Synopsis
    This function processes a list of files and merges them into a new folder with the same name as the target file
    .Parameter Files
    An array of file paths to process. If not specified, it will use the current directory
    .Parameter Target
    The path of the target file to use as the base name for the merged files. If not specified, it will use the first file in the list
    .Example
    Merge-Files -Files ".\foo\bar.txt", ".\foo\baz.txt" -Target ".\foo\bar.txt"
    #>
    [CmdletBinding()]
    param (
      # The list of files to process
      [Parameter(Mandatory=$false)]
      [ValidateScript({Test-Path $_})]
      [string[]]$Files,

      # The target file to use as the base name
      [Parameter(Mandatory=$false)]
      [ValidateScript({Test-Path $_})]
      [string]$Target
    )

    # Get the files to process from the parameter or use the current directory
    if ($Files -eq $null) {
      $Files = Get-ChildItem -Path . -Recurse -File
    }

    # Get the target file from the parameter or use the first file
    if ($Target -eq $null) {
      $Target = $Files[0]
    }

    # Get the name of the target file without the extension
    $targetName = [System.IO.Path]::GetFileNameWithoutExtension($Target)

    # Create a new folder called merged if it does not exist
    $mergedFolder = "merged"
    if (-not (Test-Path $mergedFolder)) {
      New-Item -ItemType Directory -Path $mergedFolder
    }

    # Create a tag with "before merge" message using the function defined above
    New-GitTag -TagName "before merge" -TagMessage "Before merge"

    # Loop through the files and move them to the merged folder with the target name using functions defined above
    foreach ($file in $Files) {

      # Get the relative path of the file in the repo using function defined above
      $relativePath = Get-GitRelativePath -FilePath $file

      # Move the file to the merged folder with the target name and extension
      $newFile = Join-Path $mergedFolder "$targetName$([System.IO.Path]::GetExtension($file))"

       Move-Item -Path $file -Destination $newFile

       # Commit the change with the relative path as the message
       git add $newFile
       git commit -m $relativePath

       # Create a tag with the index of the file as the message using function defined above
       New-GitTag -TagName $Files.IndexOf($file) -TagMessage  $Files.IndexOf($file)

       # Reset the repo hard to the before merge tag using function defined above
       Reset-GitHard -TagName "before merge"
    }

    # Loop through the tags created with index and merge them to the repo using function defined above
    $tags = git tag -l | Where-Object {$_ -match "\d+"}
    foreach ($tag in $tags) {
      # Merge the tag to the repo and resolve conflicts by unioning files using function defined above
      Merge-GitTag -TagName $tag
    }
  }

  function Filter-GitRepo {
<#
    .Synopsis
    This function filters a Git repository into a new branch by keeping only files that match a given pattern
    .Parameter FileName
    The pattern to match for file names. It can be a glob or a regular expression.
    .Parameter BranchName
    The name of the new branch to create. If not specified, it will use the file name as the branch name.
    .Example
    Filter-GitRepo -FileName "*.txt" -BranchName "text-files"
#>
    [CmdletBinding()]
    param (
      # The pattern to match for file names 
      [Parameter(Mandatory=$true)]
      [string]$FileName,

      # The name of the new branch to create 
      [Parameter(Mandatory=$false)]
      [string]$BranchName 
    )

    # Get the branch name from the parameter or use the file name as the branch name 
    if ($BranchName -eq $null) { 
      $BranchName = $FileName 
    } 

    # Create a new branch from the current one 
    git checkout -b $BranchName 

    # Filter the new branch to only keep files with filenames that match the pattern 
    git filter-repo --path-glob "*$FileName*" 
  }

  function Replace-GitCommit {
    <#
    .Synopsis
    This function replaces a commit in a Git repository with another commit using a replacement rule
    .Parameter ReplacementRule
    The replacement rule that specifies which commit to replace with which commit. It should be in the format of "old-ref:new-ref"
    .Example
    Replace-GitCommit -ReplacementRule "refs/heads/master:81a708d refs/heads/project-history/master:c6e1e95"
    #>
    [CmdletBinding()]
    param (
      # The replacement rule that specifies which commit to replace with which commit 
      [Parameter(Mandatory=$true)]
      [ValidateScript({$_ -match "^refs\/.*:.* refs\/.*:.*$"})]
      [string]$ReplacementRule
    )
  
    # Create a file that contains the replacement rule
    $replacementsFile = "replacements.txt"
    Set-Content -Path $replacementsFile -Value $ReplacementRule
  
    # Use git-filter-repo to replace the commit
    git filter-repo --replace-refs $replacementsFile
  }
  