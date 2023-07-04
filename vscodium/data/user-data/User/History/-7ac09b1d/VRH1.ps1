<#todo
fallback solutions
* if everything fails,
    set got dir path to abbsolute value and edit work tree in place
* if comsumption fails,
    due to modulefolder exsisting, revert move and trye to use exsisting folder instead,
    if this ressults in error, re revert to initial
	move inplace module to x prefixed
	atempt to consume again
* if no module is provided, utelyse everything to find possible folders
    use hamming distance like priorit order
	where
	1. exact parrentmatch
	   rekative to root
	    order resukts by total exact


	take first precedance
	2. predefined patterns taken
	and finaly sort rest by hamming
#>

# This script converts a git folder into a submodule and absorbs its git directory

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true, HelpMessage=".git, The path of the git folder to convert")]
	[ValidateScript({Test-Path $_ -PathType Container ; Resolve-Path -Path $_ -ErrorAction Stop})] 
	[Alias("GitFolder")][string]$errorus,[Parameter(Mandatory=$true,HelpMessage="subModuleRepoDir, The path of the submodule folder to replace the git folder")]
     #can be done with everything and menu
    [Parameter(Mandatory=$true,HelpMessage="subModuleDirInsideGit")]
	[ValidateScript({Test-Path $_ -PathType Container ; Resolve-Path -Path $_ -ErrorAction Stop})]
	[Alias("SubmoduleFolder")][string]$toReplaceWith
)
begin {
	$pastE = $error
	$error.Clear()

	# Save the previous error action preference
	$previousErrorAction = $ErrorActionPreference
	$ErrorActionPreference = "Stop"

}
process {


# Get the target folder, name and parent path from the git folder
    Write-Verbos "#---- asFile"
	$asFile = ([System.IO.Fileinfo]$errorus.trim('\'))
    Write-Verbos $asFile
	$targetFolder = $asFile.Directory
	$name = $targetFolder.Name
	$path = $targetFolder.Parent.FullName

	# Get the config file path from the git folder
	$configFile = Join-Path $GitFolder 'config'

	about-Repo #does nothing without -verbos

	# Move the git folder to a temporary name
	Move-Folder -Source $GitFolder -Destination (Join-Path $targetFolder 'x.git')

	# Move the submodule folder to replace the git folder
	Move-Folder -Source $SubmoduleFolder -Destination (Join-Path $targetFolder '.git')

	# Remove the worktree line from the config file
	(Get-Content -Path $configFile | Where-Object { ! ($_ -match 'worktree') }) | Set-Content -Path $configFile

	# Push the current location and change to the target folder
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