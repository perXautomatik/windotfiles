
function get-Origin
{
		# Get the remote url of the git repository
		$ref = (git remote get-url origin)

		# Write some information to the console
		Write-Verbos '************************** ref *****************************'
		Write-Verbos $ref.ToString()
		Write-Verbos '************************** ref *****************************'
		return $ref
}

function get-Relative {
	param (
		$path
		,$targetFolder
	)
	Set-Location $path
	$gitRoot = Get-GitRoot

	# Get the relative path of the target folder from the root of the git repository
	return (Resolve-Path -Path $targetFolder.FullName -Relative).TrimStart('.\').Replace('\', '/')

	# Write some information to the console
	Write-Verbos '******************************* bout to read as submodule ****************************************'
	Write-Verbos $relative.ToString()
	Write-Verbos $ref.ToString()
	Write-Verbos '****************************** relative path ****************************************************'

}

	# Define a function to get the root of the git repository
	function Get-GitRoot {
	    (git rev-parse --show-toplevel)
	}

	function git-root {
		$gitrootdir = (git rev-parse --show-toplevel)
		if ($gitrootdir) {
			Set-Location $gitrootdir
		}
		}

	# Define a function to move a folder to a new destination
	function Move-Folder {
	    param (
		[Parameter(Mandatory=$true)][string]$Source,
		[ValidateScript({Test-Path $_})]
		# Check if the destination already exists
		[Parameter(Mandatory=$true, HelpMessage="Enter A empty path to move to")]
		[ValidateScript({!(Test-Path $_)})]
		[string]$Destination
	    )

	    try {
			Move-Item -Path $Source -Destination $Destination -ErrorAction Stop
			Write-Verbos "Moved $Source to $Destination"
	    }
	    catch {
			Write-Warning "Failed to move $Source to $Destination"
			Write-Warning $_.Exception.Message
	    }
	}

	# Define a function to add and absorb a submodule
	function Add-AbsorbSubmodule {
	    param (
		[Parameter(Mandatory=$true)]
		[string]$Ref,

		[Parameter(Mandatory=$true)]
		[string]$Relative
	    )

	    try {
		Git submodule add $Ref $Relative
		git commit -m "as submodule $Relative"
		Git submodule absorbgitdirs $Relative
		Write-Verbos "Added and absorbed submodule $Relative"
	    }
	    catch {
			Write-Warning "Failed to add and absorb submodule $Relative"
			Write-Warning $_.Exception.Message
	    }
	}


	function index-Remove ($name,$path)
	{
		try {
			# Change to the parent path and forget about the files in the target folder
			Set-Location $path
			# Check if the files in the target folder are already ignored by git
			if ((git ls-files --error-unmatch --others --exclude-standard --directory --no-empty-directory -- "$name") -eq "") {
			Write-Warning "The files in $name are already ignored by git"
			}
			else {
			git rm -r --cached $name
			git commit -m "forgot about $name"
			}
		}
		catch {
			Write-Warning "Failed to forget about files in $name"
			Write-Warning $_.Exception.Message
		}
	}

	function about-Repo()
	{

			$vb = ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -eq $true)

				# Write some information to the console
			Write-Verbos '************************************************************' -Verbose: $vb
			Write-Verbos $targetFolder.ToString() -Verbose: $vb
			Write-Verbos $name.ToString() -Verbose: $vb
			Write-Verbos $path.ToString() -Verbose: $vb
			Write-Verbos $configFile.ToString() -Verbose: $vb
			Write-Verbos '************************************************************'-Verbose: $vb

	}


<#
.SYNOPSIS
Gets the paths of all submodules in a git repository.
.DESCRIPTION
Gets the paths of all submodules in a git repository by parsing the output of git ls-files --stage.

.OUTPUTS
System.String[]
#>
function Get-SubmodulePaths {
    # run git ls-files --stage and filter by mode 160000
    git ls-files --stage | Select-String -Pattern "^160000"

    # loop through each line of output
    foreach ($Line in $Input) {
	# split the line by whitespace and get the last element as the path
	$Line -split "\s+" | Select-Object -Last 1
    }
}

<#
.SYNOPSIS
Gets the absolute path of the .git directory for a submodule.

.DESCRIPTION
Gets the absolute path of the .git directory for a submodule by reading the .git file and running git rev-parse --absolute-git-dir.

.PARAMETER Path
The path of the submodule.

.OUTPUTS
System.String
#>
function Get-GitDir {
    param (
	[Parameter(Mandatory)]
	[string]$Path
    )

    # read the .git file and get the value after "gitdir: "
    $GitFile = Get-Content -Path "$Path/.git"
    $GitDir = $GitFile -replace "^gitdir: "

    # run git rev-parse --absolute-git-dir to get the absolute path of the .git directory
    git -C $Path rev-parse --absolute-git-dir | Select-Object -First 1
}

<#
.SYNOPSIS
Unsets the core.worktree configuration for a submodule.

.DESCRIPTION
Unsets the core.worktree configuration for a submodule by running git config --local --path --unset core.worktree.

.PARAMETER Path
The path of the submodule.
#>
function Unset-CoreWorktree {
    param (
	[Parameter(Mandatory)]
	[string]$Path
    )

    # run git config --local --path --unset core.worktree for the submodule
    git --work-tree=$Path --git-dir="$Path/.git" config --local --path --unset core.worktree
}

<#
.SYNOPSIS
Hides the .git directory on Windows.

.DESCRIPTION
Hides the .git directory on Windows by running attrib.exe +H /D.

.PARAMETER Path
The path of the submodule.
#>
function Hide-GitDir {
    param (
	[Parameter(Mandatory)]
	[string]$Path
    )

    # check if attrib.exe is available on Windows
    if (Get-Command attrib.exe) {
	# run attrib.exe +H /D to hide the .git directory
	MSYS2_ARG_CONV_EXCL="*" attrib.exe "+H" "/D" "$Path/.git"
    }
}


<# .SYNOPSIS
Lists all the ignored files that are cached in the index.

.DESCRIPTION
This function uses git ls-files with the -c, --ignored and --exclude-standard options to list all the files that are ignored by
Use git ls-files with the -c, --ignored and --exclude-standard options
.gitignore or other exclude files, and also have their content cached in the index. #>
function Get-IgnoredFiles {


git ls-files -s --ignored --exclude-standard -c }


<# .SYNOPSIS
Removes files from the index and the working tree.

.DESCRIPTION
This function takes an array of file names as input and uses git rm to remove them from the index and the working tree.
Define a function that removes files from the index and the working tree
.PARAMETER
 Files An array of file names to be removed. #>
function Remove-Files { param( # Accept an array of file names as input
[string[]]$Files )

#Use git rm with the file names as arguments
git rm $Files --ignore-unmatch }

<# .SYNOPSIS
Rewrites the history of the current branch by removing all the ignored files.

.DESCRIPTION
This function uses git filter-branch with the -f, --index-filter and --prune-empty options to rewrite the history of the current branch by removing all the ignored files from each revision, and also removing any empty commits that result from this operation. It does this by modifying only the index, not the working tree, of each revision.
#Define a function that rewrites the history of the current branch by removing all the ignored files
#Use git filter-branch with the -f, --index-filter and --prune-empty options#>

function Rewrite-History {    # Call the Get-IgnoredFiles function and pipe the output to Remove-Files function

    git filter-branch -f --index-filter {
	Get-IgnoredFiles | Remove-Files
	} --prune-empty }

#Call the Rewrite-History function
<# .SYNOPSIS
Lists all the ignored files that are cached in the index.

.DESCRIPTION
This function uses git ls-files with the -c, --ignored and --exclude-standard options to list all the files that are ignored by
Use git ls-files with the -c, --ignored and --exclude-standard options
.gitignore or other exclude files, and also have their content cached in the index. #>
function Get-IgnoredFiles {


git ls-files -s --ignored --exclude-standard -c }


<# .SYNOPSIS
Removes files from the index and the working tree.

.DESCRIPTION
This function takes an array of file names as input and uses git rm to remove them from the index and the working tree.
Define a function that removes files from the index and the working tree
.PARAMETER
 Files An array of file names to be removed. #>
function Remove-Files { param( # Accept an array of file names as input
[string[]]$Files )

#Use git rm with the file names as arguments
git rm $Files --ignore-unmatch }

<# .SYNOPSIS
Rewrites the history of the current branch by removing all the ignored files.

.DESCRIPTION
This function uses git filter-branch with the -f, --index-filter and --prune-empty options to rewrite the history of the current branch by removing all the ignored files from each revision, and also removing any empty commits that result from this operation. It does this by modifying only the index, not the working tree, of each revision.
#Define a function that rewrites the history of the current branch by removing all the ignored files
#Use git filter-branch with the -f, --index-filter and --prune-empty options#>

function Rewrite-History {    # Call the Get-IgnoredFiles function and pipe the output to Remove-Files function

    git filter-branch -f --index-filter {
	Get-IgnoredFiles | Remove-Files
	} --prune-empty }

#Call the Rewrite-History function Rewrite-History

# A function that parses the output of git ls-tree command and returns a custom object with properties
function Parse-GitLsTreeOutput
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTreeOutput
        )
        process {
            # Extract the blob type from the output line
            $blobType = $_.substring(7,4)
            # Set the hash start position based on the blob type
            $hashStartPos = 12
            if ($blobType -ne 'blob') { $hashStartPos+=2 } 
            # Set the relative path start position based on the blob type
            $relativePathStartPos = 53
            if ($blobType -ne 'blob') { $relativePathStartPos+=2 } 
            # Create a custom object with properties for unknown, blob, hash and relative path
            [pscustomobject]@{unknown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     } 
}

# A function that resolves the absolute path of a file from its relative path
function Resolve-AbsolutePath
{
    param(
        [Parameter(Mandatory)] [string]$RelativePath
    )
    
    # Escape the backslash character for regex matching
    $backslash = [regex]::escape('\')
    
    # Define a regex pattern for matching octal escape sequences in the relative path
    $octalPattern = $backslash+'\d{3}'+$backslash+'\d{3}'
    
    # Trim the double quotes from the relative path
    $relativePath =  $RelativePath.Trim('"')

    # Try to resolve the relative path to an absolute path
    $absolutePath = Resolve-Path $relativePath -ErrorAction SilentlyContinue  
    
    # If the absolute path is not found and the relative path contains octal escape sequences, try to resolve it with wildcard matching
    if(!$absolutePath -and $relativePath -match ($octalPattern))
    { 
       $absolutePath = Resolve-Path  (($relativePath -split($octalPattern) ) -join('*')) 
    }
    # Return the absolute path or null if not found
    return $absolutePath     
}

# A function that takes a collection of parsed git ls-tree output objects and adds more properties to them such as absolute path, file name and parent folder
function Add-MorePropertiesToGitLsTreeOutput
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$GitLsTreeOutputObjects
    )
    # For each object in the collection, add more properties using calculated expressions
    $GitLsTreeOutputObjects | Select-Object -Property *,@{Name = 'absolute'; Expression = {Resolve-AbsolutePath $_.relativePath}},@{Name = 'FileName'; Expression = {$path = $_.absolute;$filename = [System.IO.Path]::GetFileNameWithoutExtension("$path");if(!($filename)) { $filename = [System.IO.Path]::GetFileName("$path") };$filename}},@{Name = 'Parent'; Expression = {Split-Path -Path $_.relativePath}}
}

# A function that joins two collections of parsed git ls-tree output objects based on their file names and returns a custom object with properties for hash and absolute paths of both collections
function Join-GitLsTreeOutputCollectionsByFileName
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$Collection1,
        [Parameter(Mandatory)]
        [psobject[]]$Collection2
    )
    # Define a delegate function that returns the file name of an object as the join key
    $KeyDelegate = [System.Func[Object,string]] {$args[0].FileName}
    # Define a delegate function that returns a custom object with properties for hash and absolute paths of both collections as the join result
    $resultDelegate = [System.Func[Object,Object,Object]]{ 
                    param ($x,$y);
                    
                    New-Object -TypeName PSObject -Property @{
                    Hash = $x.hash;
                    AbsoluteX = $x.absolute;
                    AbsoluteY = $y.absolute
                    }
                }
    
    # Use LINQ Join method to join the two collections by file name and return an array of custom objects as the result
    $joinedDataset = [System.Linq.Enumerable]::Join( $Collection1, $Collection2, #tableReference
        
                                                     $KeyDelegate,$KeyDelegate, #onClause
                
                                                     $resultDelegate
    )
    $OutputArray = [System.Linq.Enumerable]::ToArray($joinedDataset)

    return $OutputArray
}

# A function that creates a lookup table from a collection of parsed git ls-tree output objects based on their hash values
function Create-LookupTableByHash
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$GitLsTreeOutputObjects
    )
    # Define a delegate function that returns the hash value of an object as the lookup key
    $HashDelegate = [system.Func[Object,String]] { $args[0].hash }
    # Define a delegate function that returns the object itself as the lookup element
    $ElementDelegate = [system.Func[Object]] { $args[0] }
    # Use LINQ ToLookup method to create a lookup table from the collection by hash value and return an array of lookup groups as the result
    $lookup = [system.Linq.Enumerable]::ToLookup($GitLsTreeOutputObjects, $HashDelegate,$ElementDelegate)

    return [Linq.Enumerable]::ToArray($lookup)
}


# This function takes an array of objects and splits it into smaller chunks of a given size
# It also executes a script block on each chunk if provided
function Split-Array
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)] [object[]] $InputObject,
        [Parameter()] [scriptblock] $Process,
        [Parameter()] [int] $ChunkSize
    )

    Begin { #run once
        # Initialize an empty array to store the chunks
        $cache = @();
        # Initialize an index to keep track of the chunk size
        $index = 0;
    }
    Process { #run each entry

        if($cache.Length -eq $ChunkSize) {
            # if the cache array is full, send it out to the pipe line
            write-host '{'  –NoNewline
            write-host $cache –NoNewline
            write-host '}'

            # Then we add the current pipe line object to the cache array and reset the index
            $cache = @($_);
            $index = 1;
        }
        else {
            # Otherwise, we append the current pipe line object to the cache array and increment the index
            $cache += $_;
            $index++;
        }

      }
    End { #run once
        # Here we check if there are any remaining objects in the cache array, if so, send them out to pipe line
        if($cache) {
            Write-Output ($cache );
        }
    }
}

# This function parses the output of git ls-tree and converts it into a custom object with properties
function Parse-LsTree
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTree
        )
        process {
            # Extract the blob type from the input string
            $blobType = $_.substring(7,4)
            # Set the starting positions of the hash and relative path based on the blob type
            $hashStartPos = 12
            $relativePathStartPos = 53

            if ($blobType -ne 'blob')
                {
                $hashStartPos+=2
                $relativePathStartPos+=2
                } 

            # Create a custom object with properties for unknown, blob, hash and relative path
            [pscustomobject]@{unkown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     
     } 
}

# This function lists the duplicate object hashes in a git repository using git ls-tree and Parse-LsTree functions
function List-Git-DuplicateHashes
{
    param([string]$path)
    # Save the current working directory
    $current = $PWD

    # Change to the given path
    cd $path

    # Use git ls-tree to list all the objects in the HEAD revision
    git ls-tree -r HEAD |
    # Parse the output using Parse-LsTree function
    Parse-LsTree |
            # Group the objects by hash and filter out the ones that have only one occurrence 
            Group-Object -Property hash |
            ? { $_.count -ne 1 } | 
            # Sort the groups by count in descending order
                Sort-Object -Property count -Descending

    # Change back to the original working directory            
    cd $current
 }               

# This function adds an index property to each object in an array using a counter variable 
function Add-Index { #https://stackoverflow.com/questions/33718168/exclude-index-in-powershell
   
    begin {
        # Initialize the counter variable as -1
        $i=-1
    }
   
    process {
        if($_ -ne $null) {
        # Increment the counter variable and add it as an index property to the input object 
        Add-Member Index (++$i) -InputObject $_ -PassThru
        }
    }
}

# This function displays the indexed groups of duplicate hashes in a clear format 
function Show-Duplicates
{    
    [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )

     Clear-Host
     Write-Host "================ k for keep all ================"
                 

    # Add an index property to each group using Add-Index function 
    $indexed = ( $input |  %{$_.group} | Add-Index )
            
    # Display the index and relative path of each group and store the output in a variable 
    $indexed | Tee-Object -variable re |  
    % {
        $index = $_.index
        $relativePath = $_.relativePath 
        Write-Host "$index $relativePath"
    }

    # Return the output variable 
    $re
}

# This function allows the user to choose which duplicate hashes to keep or delete 
function Choose-Duplicates
{  
 [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )
       # Split the input array into smaller chunks using Split-Array function 
       $options = $input | %{$_.index} | Split-Array 
       # Prompt the user to choose from the alternatives and store the input in a variable 
       $selection = Read-Host "choose from the alternativs " ($input | measure-object).count
       # If the user chooses to keep all, return nothing 
       if ($selection -eq 'k' ) {
            return
        } 
        else {
            # Otherwise, filter out the objects that have the same index as the selection and store them in a variable 
            $q = $input | ?{ $_.index -ne $selection }
        } 
    
       # Return the filtered variable 
       $q
}

# This function deletes the chosen duplicate hashes using git rm command 
function Delete-Duplicates
{  
 [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )
    if($input -ne $null)
    {

       # Split the input array into smaller chunks using Split-Array function 
       $toDelete = $input | %{$_.relativepath} | Split-Array 
       
       # For each chunk, use git rm to delete the files 
       $toDelete | % { git rm $_ } 

       # Wait for 2 seconds before proceeding 
       sleep 2
    }
}

function Get-Commits {
    param (
        # The date parameter specifies the cut-off date for the commits
        [Parameter(Mandatory=$true)]
        [string]$Date
    )
    # Use git log to get all commit hashes before the date in a table format
    $commits = git log --all --before="$Date" --pretty=format:"%H"
    # Return the table of commits
    return $commits
}

# Define a function to search for a string in a commit using git grep
function Search-Commit {
    param (
        # The commit parameter specifies the commit hash to search in
        [Parameter(Mandatory=$true)]
        [string]$Commit,
        # The string parameter specifies the string to search for
        [Parameter(Mandatory=$true)]
        [string]$String
    )
    # Use git grep to search for the string in the commit and return a boolean value
    $result = git grep --ignore-case --word-regexp --fixed-strings -o $String -- $Commit
    return $result
}

# Define a function to search for a string in a commit using git log and regex
function Search-Commit-Regex {
    param (
        # The commit parameter specifies the commit hash to search in
        [Parameter(Mandatory=$true)]
        [string]$Commit,
        # The regex parameter specifies the regex pattern to search for
        [Parameter(Mandatory=$true)]
        [string]$Regex
    )
    # Use git log to search for the regex pattern in the commit and return a boolean value
    $result = git log -G $Regex -- $Commit
    return $result
}

# Define a function to create a hash table of commits and their frequencies of matching the search string
function Get-HashTable {
    param (
        # The commits parameter specifies the table of commits to process
        [Parameter(Mandatory=$true)]
        [array]$Commits,
        # The string parameter specifies the string to search for in each commit
        [Parameter(Mandatory=$true)]
        [string]$String,
        # The regex parameter specifies whether to use regex or not for searching (default is false)
        [Parameter(Mandatory=$false)]
        [bool]$Regex = $false
    )
    # Create an empty hash table to store the results
    $hashTable = @{}
    # Loop through each commit in the table of commits
    foreach ($commit in $commits) {
        # If regex is true, use Search-Commit-Regex function, otherwise use Search-Commit function
        if ($Regex) {
            $match = Search-Commit-Regex -Commit $commit -Regex $String
        }
        else {
            $match = Search-Commit -Commit $commit -String $String
        }
        # If there is a match, increment the frequency of the commit in the hash table, otherwise set it to zero
        if ($match) {
            $hashTable[$commit]++
        }
        else {
            $hashTable[$commit] = 0
        }
    }
    # Return the hash table of commits and frequencies
    return $hashTable
}

# Define a function to display a progress bar while processing a table of commits
function Show-Progress {
    param (
        [Parameter(Mandatory=$true)]
        [array]$Commits,
        # The activity parameter specifies the activity name for the progress bar (default is "Searching Events")
        [Parameter(Mandatory=$false)]
        [string]$Activity = "Searching Events",
        # The status parameter specifies the status name for the progress bar (default is "Progress:")
        [Parameter(Mandatory=$false)]
        [string]$Status = "Progress:"
    )
    # Set the counter variable to zero
    $i = 0
    # Loop through each commit in the table of commits
    foreach ($commit in $commits) {
        # Increment the counter variable
        $i = $i + 1
        # Determine the completion percentage
        $Completed = ($i / $commits.count * 100)
        # Use Write-Progress to output a progress bar with the activity and status parameters
        Write-Progress -Activity $Activity -Status $Status -PercentComplete $Completed
    }
}


function GitGrep {
	param ([string]$range, [string]$grepThis)
  
	git log --pretty=format:"%H" $range --no-merges --grep="$grepThis" | ForEach-Object {
	  $Body = git log -1 --pretty=format:"%b" $_ | Select-String "$grepThis"
	  if($Body) {
		git log -1 --pretty=format:"%H,%s" $_
		Write-Host $Body
	  }
	}
  }
  
  function Git-LsTree {
	param ([string]$range, [string]$grepThis)
	
	
  $Body =  git ls-tree $range -r
	
	   $body | % { 
	   $spl = $_ -split ' ',3
	   [pscustomobject]@{     
		   hash = $range
		   q = $spl[0].trim()
		   type = $spl[1].trim()
		   objectID = $spl[2].Substring(0,40).trim()
		   relative = $spl[2].Substring(40).trim()
   
   
		}
	  }
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
    