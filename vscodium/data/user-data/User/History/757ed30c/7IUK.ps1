. 'B:\PF\Archive\ps1\git\repair\status\Invoke-Git.ps1'

# Function to create a valid branch name from an array and a string embedding
function createValidBranchName {
    <#
    .SYNOPSIS
    Creates a valid branch name from an array and a string embedding.
    .DESCRIPTION
    Takes an array of strings and a string embedding as parameters and returns a final string that is suitable for a git branch name.
    .PARAMETER array
    An array of strings that will be used to create the branch name.
    .PARAMETER stringEmbedding
    A string embedding that will be used to format the array elements into the branch name.
    .PARAMETER repoPath
    An optional parameter that specifies the path to the git repository where the branch name will be checked against existing branches.
    .PARAMETER checkAgainstRepo
    A switch parameter that indicates whether to check the branch name against the existing branches in the repository or not.
    .EXAMPLE
    createValidBranchName -array @("foo","bar","baz") -stringEmbedding "{0}_{1}-{2}" -repoPath "C:\Users\user\repo" -checkAgainstRepo
    Creates a branch name "bar_foo-baz" and checks if it already exists in the repository at "C:\Users\user\repo".
    #>

    # Define the parameters for the function
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$array,
        [Parameter(Mandatory=$true)]
        [string]$stringEmbedding,
        [Parameter(Mandatory=$false)]
        [string]$repoPath,
        [Parameter(Mandatory=$false)]
        [switch]$checkAgainstRepo
    )

    # Create the final string from the array and the string embedding
    $returnName = $stringEmbedding -f $array

    # Remove unsuitable characters not supported for a git branch name (such as spaces, dots, slashes, etc.)
    $regex = '[\s\.\/\\:*?""<>|~^]'
    $returnName = $returnName -replace $regex,""

    # Trim the final string to a suitable length for a git branch name (63 characters)
    $returnName = $returnName.Substring(0,[Math]::Min($returnName.Length,63))


    # Check if the checkAgainstRepo switch is set
    if ($checkAgainstRepo) {
        # Check if the repoPath parameter is provided
        if ($repoPath) {
            # Change directory to the repoPath
            set-location $repoPath
			}
        else {
			if (!(Test-Path -Path ".git")) {
			            # Throw an error if the repoPath parameter is not provided
	            throw "The repoPath parameter is required not exectuing from repo"
			}
			# assume this is the repo
        }
            # Check if the returnName already exists among branch names in the repository
            if (git branch --list | Select-String -Pattern $returnName) {
                # Throw an error if the branch name already exists
                throw "The branch name '$returnName' already exists in the repository."
            }

    }

    # Return the final string as the branch name
    return $returnName
}

# Function to set remote for a tracking branch
function setRemote {
    <#
    .SYNOPSIS
    Sets remote for a tracking branch.
    .DESCRIPTION
    Takes a remote URL and a tracking branch as parameters and uses git to set remote for the tracking branch.
    .PARAMETER remoteUrl
    The URL of the remote repository where the tracking branch will be pushed or pulled.
    .PARAMETER trackingBranch
    The name of the local branch that will track the remote branch. This parameter can accept values from pipeline.
    .EXAMPLE
    setRemote -remoteUrl "https://github.com/user/repo.git" -trackingBranch "master"
    Sets remote for the local master branch to "https://github.com/user/repo.git".

    .EXAMPLE
    "master","dev" | setRemote -remoteUrl "https://github.com/user/repo.git"
    Sets remote for both local master and dev branches to "https://github.com/user/repo.git".

    #>

     # Define the parameters for the function
     param(
         [Parameter(Mandatory=$true)]
         [string]$remoteUrl,
         [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
         [string]$trackingBranch
     )

     # Use git to set remote for each tracking branch in the pipeline
     process {
        git remote add origin $remoteUrl/$PSItem
    }

}

# Function to get relative paths of a branch head
function getBranchHeadPaths {
     <#
     .SYNOPSIS
     Gets relative paths of a branch head.
     .DESCRIPTION
     Takes a branch name as parameter and returns an array of relative paths of files in the branch head.
     .PARAMETER branchName
     The name of the branch whose head paths will be returned.
     .EXAMPLE
     getBranchHeadPaths -branchName "master"
     Returns an array of relative paths of files in the master branch head.
     #>

     # Define the parameter for the function
     param(
         [Parameter(Mandatory=$true)]
         [string]$branchName
     )

     # Use git to get relative paths of files in the branch head
     $paths = git ls-tree -r --name-only $branchName

     # Return the array of paths
     return $paths
}

# Function to get repository branch names
function getRepoBranchNames {
    <#
    .SYNOPSIS
    Gets repository branch names.
    .DESCRIPTION
    Returns a hashtable of branch names and branch head references in the current repository.
    .EXAMPLE
    getRepoBranchNames
    Returns a hashtable of branch names and branch head references in the current repository.
    #>

    # Use git to get branch names and references in the current repository
    $branches = git show-ref --heads

    # Create an empty hashtable to store the branch names and references
    $branchTable = @{}

    # Loop through each line of the git output
    foreach ($line in $branches) {
        # Split the line by whitespace and assign the first part to a variable called ref and the second part to a variable called name
        $ref, $name = $line -split "\s+"
        # Remove the "refs/heads/" prefix from the name
        $name = $name -replace "refs/heads/",""
        # Add the name and ref pair to the hashtable
        $branchTable[$name] =  $ref
    }

    # Return the hashtable of branch names and references
    return $branchTable

}

# Function to create multiple branches
function createMultipleBranches {
    <#
    .SYNOPSIS
    Creates multiple branches.
    .DESCRIPTION
    Takes a dictionary of branch names and references as parameter and creates new branches with those names and references. Returns an array of created branch names.
    .PARAMETER dictionary
    A dictionary of branch names and references that will be used to create new branches. 
    The keys are the branch names 
    and 
    the values are the references.
    .EXAMPLE
    createMultipleBranches -dictionary @{"foo"="refs/heads/master";"bar"="refs/heads/dev"}
    Creates two new branches named foo and bar with references refs/heads/master and refs/heads/dev respectively. Returns an array of foo and bar.

    #>

    # Define the parameter for the function
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            # Check if there are any duplicate keys in the dictionary
            if (!($_.Keys.Count -eq ($_.Keys | Select-Object -Unique | Measure-Object).Count)) {
                throw "The dictionary contains duplicate keys."
            }
            # Check if any key in the dictionary is same as a repo's branch name
            $branches = getRepoBranchNames
            if ($_.Keys -in $branches) {
                throw "The dictionary contains keys that are same as repo's branch names."
            }
            return $true
        })]
        [hashtable]$dictionary
    )

    # Create an empty array to store the created branch names
    $created = @()

    # Loop through each key-value pair in the dictionary
    foreach ($pair in $dictionary.GetEnumerator()) {
        # Assign the key to a variable called name and the value to a variable called ref
        $name = $pair.Key
        $ref = $pair.Value

        # Use git to create a new branch by name without checking out to it
        $response = Invoke-Git "branch --no-track $name"
        if (!$response) {
            # If successful, set the branch head to ref
            $response2 = Invoke-Git "update-ref refs/heads/$name $ref"
            if (!$response2)
			{
	            # Add the name to the created array
	            $created = $created + $name
			}
        }
        else {
            # If failed, throw an error with the name
            throw "Failed to create '$name'."
        }
    }
    return $created
}

# Synopsis: Validates that a branch name is unique among the branches in the dictionary.
# Parameters:
#   -BranchName: The branch name to validate.
#   -Branches: The dictionary of branches to check against.
function BranchNameIsUnique {
    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [Parameter(Mandatory=$true)]
        [Dictionary[string, string]] $Branches
    )

    if ($Branches.ContainsKey($BranchName)) {
        throw "The branch name '$BranchName' is already in use."
    }

    return $true
}

# Synopsis: Validates that a branch name is not already in the repository.
# Parameters:
#   -BranchName: The branch name to validate.
#   -Branches: The dictionary of branches in the repository.
function BranchNameIsNotInRepo {
    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [Parameter(Mandatory=$true)]
        [Dictionary[string, string]] $Branches
    )

    $repoBranches = Get-RepoBranchNames
    if ($repoBranches.ContainsKey($BranchName)) {
        throw "The branch name '$BranchName' is already in use in the repository."
    }

    return $true
}

# Synopsis: Gets the relative paths of the branches in the repository.
# Returns: A dictionary of branch names and relative paths.
function Get-RepoBranchNames {
    $branches = @()
    $branchNames = git branch | Out-String -Stream | Select-String -Pattern '^[*]\s+(.+)' | Where-Object { $_.Matches.Count -eq 1 } | Select-Object -ExpandProperty Matches
    foreach ($branchName in $branchNames) {
        $branchRef = git rev-parse $branchName
        $branches += New-Object PSObject -Property @{
            BranchName = $branchName
            Ref = $branchRef
        }
    }

    return $branches
}


function getPathInRe($path)    
{
    
    $dirx = (get-item -Path $path).Directory
    Set-location $dirx; 
    return (git ls-files --full-name $path)
}
function filterOutSingleFile ()
{
    # Define the parameter for the script
    <#
filterOutSingleFile -path 'B:\Unsorted\tempRepo\module\GitTemp.ps1'
    #>
param(
    [Parameter(Mandatory=$true)]
    [string]$path
)
    # Get the base name of the path and store it in a variable
    $name = (get-item -Path $path) | Split-Path -Leaf

 
    $relP = getPathInRe -path $path
    # Create a valid branch name from the base name using createValidBranchName function
    $branch = createValidBranchName -array @($name) -stringEmbedding "{0}"

    # Use git to create a new branch by the branch name without checking out to it
    git branch --no-track $branch

    # Use git filter-repo to remove everything else but the file name in the branch
    git filter-repo --path $relP --refs $branch --force

    # Write the branch name as output
    Write-Output $branch
}

function renameTwoFilesInTwoBranches($branchesSeparatedWithSpaces, $from1,$from2,$to)
{
    <#
    If you do a --path-rename to something that was already in use, it will be silently overwritten. However, if you try to rename multiple files to the same location (e.g. src/scripts/run_release.sh and cmds/run_release.sh both existed and had different content with the renames above), then you will be given an error. If you have such a case, you may want to add another rename command to move one of the paths somewhere else where it won’t collide:

git filter-repo --path-rename cmds/run_release.sh:tools/do_release.sh \
                --path-rename cmds/:tools/ \
                --path-rename src/scripts/:tools/


Note that path renaming does not do path filtering, thus the following command

    git filter-repo --path src/main/ --path-rename tools/:scripts/

would not result in the tools or scripts directories being present, because the single filter selected only src/main/. It’s likely that you would instead want to run:

                git filter-repo --path src/main/ --path tools/ --path-rename tools/:scripts/
    #>
    
    $m = "git filter-repo "
    $from1, $from2 | %{ $m = $m + "--path-rename '"+ $_ + "':" + $to + " "  } 
    
    $m = $m + "--refs " + $branchesSeparatedWithSpaces
     $m.Trim()

    invoke-expression $m

}

<# main script ------------------------------#>
function Split-Branches-ByFiles
{
    # Define the parameters for the main script
    param(
        [Parameter(Mandatory=$true)]
        [hashtable]$rp,
        [Parameter(Mandatory=$true)]
        [string]$remotePath
    )

    # Get a hashtable of repo's branch names and references using getRepoBranchNames function
    $branches = getRepoBranchNames

    # Create an empty hashtable to store successful branch names and paths
    $successful = @{}

    # Get the count of the branches hashtable
    $count = $branches.Count; $i = 0

    # Loop through each key-value pair in branches hashtable
    foreach ($pair in $branches.GetEnumerator()) {

        # Assign the key to a variable called bName and the value to a variable called ref
        $bName = $pair.Key
        $ref = $pair.Value

        # Get an array of relative paths of files in the branch head using getBranchHeadPaths function
        $relPath = getBranchHeadPaths -branchName $bName

        # Filter the array of paths by matching them with the keys of the rp hashtable
        $relPath = $relPath | Where-Object {$rp.ContainsKey($_)}

        # Create an empty array to store the creation parameters
        $creationArray = @()

        # Loop through each relative path in the filtered array
        foreach ($rPath in $relPath) {
            # Create an array of strings from the base name of the relative path, the branch name and the parent of the relative path
            $nameArray = @(
                    (Split-Path -LeafBase (($ExecutionContext).SessionState.Path.GetUnresolvedProviderPathFromPSPath($rPath))),
                    $bName,
                    (Split-Path -Parent (($ExecutionContext).SessionState.Path.GetUnresolvedProviderPathFromPSPath($rPath)))    
                )

            # Create a valid branch name from the name array and the string embedding using createValidBranchName function with checkAgainstRepo switch
            $name = createValidBranchName -array $nameArray -stringEmbedding "{0}_{1}-{2}" -checkAgainstRepo

            # Add a hashtable of name, ref and relative path to the creation array
            $creationArray += @{"name"=$name;"ref"=$ref;"path"=$rPath}
        }

        $zx = @{}; $creationArray | %{$zx[$_.name]=$_.ref}; 
        $yx = @{}; $creationArray | %{$yx[$_.name]=$_.path}; 
        # Create multiple branches from the creation array using createMultipleBranches function and pipe the output to setRemote function with remotePath parameter
        $uuu = createMultipleBranches -dictionary ($zx)
        $uuu | ForEach-Object {
            # Add a hashtable of branch name and relative path to the successful hashtable
            $successful[$_] = $yx[$_]
            # Return the branch name as output
            
            }
            
            $successful.Keys | setRemote -remoteUrl "$remotePath"

        # Increment the counter and write progress to the debug stream if running in debug mode
        $i++
        if ($PSBoundParameters['Debug']) {
            Write-Debug -Message "Processed: $i of $($count)"
        }
    }


    # Get the count of the successful hashtable
    $count = $successful.Count; $i = 0

    # Loop through each key-value pair in successful hashtable
    foreach ($pair in $successful.GetEnumerator()) {
        # Assign the key to a variable called bName and the value to a variable called path
        $bName = $pair.Key
        $path = $pair.Value

        # Try to filter the branch by ref and path using git filter-repo command and push it to remote tracked path using git push command
        try {
            git filter-repo --refs $bName --path $path
            #git push origin/$bName

            # Write the remote path and branch name as output
            Write-Output "$remotePath : $bName"
        }
        catch {
            # Write the error message as output
            Write-Output $_.Exception.Message
        }

        # Increment the counter and write progress to the debug stream if running in debug mode
        $i++
        if ($PSBoundParameters['Debug']) {
            Write-Debug -Message "Processed: $i of $count"
        }
    }
}
Set-Location 'B:\Unsorted\tempRepo';

#$p1 = getPathInRe 'B:\Unsorted\tempRepo\repair\Gitmodules\New folder\lib\Check-GitStatus.ps1'
#$p2 = getPathInRe 'B:\Unsorted\tempRepo\repair\submodule\Check-GitStatus.ps1'
#git filter-repo --path-rename repair/submodule/Check-GitStatus.ps1:'repair/Gitmodules/New folder/lib/Check-GitStatus.ps1'

$filterTable = @( $u = Get-Clipboard ; $u -split '\r?\n|\r' | %{ $_.trim() } )

function parseFilterRepoAnalysis
{
    param(
        $pathAllSizes = 'B:\Unsorted\tempRepo\.git\filter-repo\analysis\path-all-sizes.txt',
        $pathprefix = "B:\Unsorted\tempRepo\",
        $Pattern = "^(.{13})(.{11})(\S{3,})\s(.*)$"
      
    )

$Data = Get-Content $pathAllSizes -Encoding UTF8 | select -Skip 1 ; 
$Headers = $Data[0].replace(" ","_") -split "," ;
 $Data = $data | select -Skip 1 ; $Headers[0],$Headers[1],$Headers[2],$Headers[3] ;
   $Data | %{ $Match = (($_ | Select-String $Pattern).matches.groups) ;
    [PSCustomObject]@{ $Headers[0] = $Match[1].Value.Trim() ;
    $Headers[1] = $Match[2].Value.Trim(); $Headers[2] = $Match[3].Value.Trim();
    $Headers[3] = $Match[4].Value.Trim() ;
    filename=( $pathprefix + $match[4].Value.Trim() -replace("/","\") | split-path -Leaf ) }} 
    | %{ [PSCustomObject]@{ path=$_._path_name; alias=$_.filename } }
}
$rpx = @{}
parseFilterRepoAnalysis | ?{  $filterTable -contains $_.alias } | %{ $rpx[$_.path] = $_.alias }

Split-Branches-ByFiles -rp $rpx -remotePath 'B:\PF\CSharpVisualStudio\repos\karlstad\KarlstadButik'


