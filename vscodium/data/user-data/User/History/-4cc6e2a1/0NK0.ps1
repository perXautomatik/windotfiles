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

. .\New-GitTag.ps1
  
. .\Get-GitRelativePath.ps1
. .\Reset-GitHard.ps1

. .\Merge-GitTag.ps1

. .\mergeNresolveByExternal.ps1

. .\Git-flterRepo-RegexRename.ps1

. .\prefixCommit.ps1

. .\Merge-Files.ps1

. .\Filter-GitRepo.ps1

. .\Git-Filter-Replace-Commit.ps1

param (
    <#
.Synopsis
This script takes a number of files as input and merges them into a new folder with the same name as the target file
.Parameter Files
An array of file paths to process. If not specified, it will use the current directory
.Parameter Target
The path of the target file to use as the base name for the merged files. If not specified, it will use the first file in the list
.Example
.\Merge-Script.ps1 -Files ".\foo\bar.txt", ".\foo\baz.txt" -Target ".\foo\bar.txt"
#>
  # The list of files to process
  [Parameter(Mandatory=$false)]
  [ValidateScript({Test-Path $_})]
  [string[]]$Files,

  # The target file to use as the base name
  [Parameter(Mandatory=$false)]
  [ValidateScript({Test-Path $_})]
  [string]$Target
)

# Import the module that contains the functions
Import-Module .\GitFunctions.psm1

# Call the Merge-Files function with the parameters
Merge-Files -Files $Files -Target $Target
