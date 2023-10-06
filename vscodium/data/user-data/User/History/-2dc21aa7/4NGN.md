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
    createValidBranchName -array @("foo","bar","baz") -stringEmbedding "{1}_{2}-{3}" -repoPath "C:\Users\user\repo" -checkAgainstRepo
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

    # Trim the final string to a suitable length for a git branch name (63 characters)
    $returnName = $returnName.Substring(0,[Math]::Min($returnName.Length,63))

    # Remove unsuitable characters not supported for a git branch name (such as spaces, dots, slashes, etc.)
    $returnName = $returnName -replace "[\s\.\/\\:*?""<>|~^]",""

    # Check if the checkAgainstRepo switch is set
    if ($checkAgainstRepo) {
        # Check if the repoPath parameter is provided
        if ($repoPath) {
            # Change directory to the repoPath
            cd $repoPath
            # Check if the returnName already exists among branch names in the repository
            if (git branch --list | Select-String -Pattern $returnName) {
                # Throw an error if the branch name already exists
                throw "The branch name '$returnName' already exists in the repository."
            }
        }
        else {
            # Throw an error if the repoPath parameter is not provided
            throw "The repoPath parameter is required when using the checkAgainstRepo switch."
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

     # Use git to set remote for the tracking branch
     git remote add origin $remoteUrl/$trackingBranch

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
        $branchTable[$name] = $ref
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
    A dictionary of branch names and references that will be used to create new branches. The keys are the branch names and the values are the references.
    .EXAMPLE
    createMultipleBranches -dictionary @{"foo"="refs/heads/master";"bar"="refs/heads/dev"}
    Creates two new branches named foo and bar with references refs/heads/master and refs/heads/dev respectively. Returns an array of foo and bar.
    
    #>

    # Define the parameter for the function
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScript({
            # Check if there are any duplicate keys in the dictionary
            if ($_.Keys.Count -ne $_.Keys | Select-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) {
                throw "The dictionary contains duplicate keys."
            }
            # Check if any key in the dictionary is same as a repo's branch name
            if ($_.Keys | Where-Object {getRepoBranchNames.ContainsKey($_)}) {
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
        if (git branch --no-track $name) {
            # If successful, set the branch head to ref
            git update-ref refs/heads/$name $ref

            # Add the name to the created array
            $created += $name

            # Return the name as output
            return $name

        }
        else {
            # If failed, throw an error with the name
            throw "Failed to create '$name'."
        }
        
    }

}

# Main script

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

# Loop through each key-value pair in branches hashtable 
foreach ($pair in $branches.GetEnumerator()) {
    
   # Assign the key to a variable called bName and the value to a variable called ref 
   $bName = $pair.Key