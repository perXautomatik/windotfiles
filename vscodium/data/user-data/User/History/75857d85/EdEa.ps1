# Define a function that takes an array of tree objects and returns a new tree object
function ResolveConflict($trees) {
    # Create an empty hashtable to store the file names and blob objects
    $files = @{}

    # Loop through each tree object in the input array
    foreach ($tree in $trees) {
        # Get the type and content of the tree object
        $type, $content = git cat-file -p $tree

        # Check if the type is "tree" and throw an error if not
        if ($type -ne "tree") {
            throw "Invalid tree object: $tree"
        }

        # Split the content by newline and loop through each line
        foreach ($line in $content -split "`n") {
            # Split the line by whitespace and assign the parts to variables
            $mode, $blob, $file = $line -split "\s+"

            # Check if the file name already exists in the hashtable
            if ($files.ContainsKey($file)) {
                # Check if the blob object is different from the existing one
                if ($blob -ne $files[$file]) {
                    # Merge the two blob objects and create a new blob object
                    git merge-file -p "$blob" "$files[$file]" "$blob" | git hash-object -w --stdin
                    # Update the hashtable with the new blob object for the file name
                    $files[$file] = (git rev-parse --verify --quiet --short HEAD)
                }
            }
            else {
                # Add the file name and blob object pair to the hashtable
                $files[$file] = $blob
            }
        }
    }

    # Create an empty string to store the content of the new tree object
    $treeContent = ""

    # Loop through each key-value pair in the hashtable
    foreach ($file in $files.Keys) {
        # Get the type of the blob object
        $type = git cat-file -t $files[$file]

        # Check if the type is "blob" and throw an error if not
        if ($type -ne "blob") {
            throw "Invalid blob object: $files[$file]"
        }

        # Append a line with mode, type, blob and file to the string
        $treeContent += "100644 {0} {1}`t{2}`n" -f $type, $files[$file], $file
    }

    # Create a new tree object with the string and return its SHA
    return (git mktree <<< $treeContent)
}



<#
can you rewrite this pseudocode into a powershell script with functions with synopsis, 
with parameter validation and error checking,
USING GIT PLUMMING COMMANDS ( important, not recomended dangereus but that is what this code is supposed to do ) ;
 inside a git local repo, taken a number of commit sha's createa a new branch, create a new branch, 
 create a new commit to be head of the new branch, taking the components of the paramted commits, 
 take the objects, the tree objects, the metadata of the commit messages, 
 using a function called ResolveConflict( that does not need to be implemented by us here in this script now), 
 take the resolved object properties and createa a new commti sha, 
 with a the combined tree object of the input commits tree objects through the resolveCOnflict function, 
 and the all objects
#>
# Function to create a new branch from a number of commit SHA's
function createNewBranch {
    <#
    .SYNOPSIS
    Creates a new branch from a number of commit SHA's.
    .DESCRIPTION
    Takes an array of commit SHA's as parameter and creates a new branch with a new commit that combines the components of the input commits. The new commit has the resolved tree object and the concatenated commit messages of the input commits. The function uses git plumbing commands to manipulate the objects and references.
    .PARAMETER commits
    An array of commit SHA's that will be used to create the new branch.
    .PARAMETER branchName
    The name of the new branch that will be created.
    .EXAMPLE
    createNewBranch -commits @("123456","789abc","def012") -branchName "new-branch"
    Creates a new branch called "new-branch" with a new commit that combines the components of the commits 123456, 789abc and def012.
    #>

    # Define the parameters for the function
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$commits,
        [Parameter(Mandatory=$true)]
        [string]$branchName
    )

    # Create an empty array to store the tree objects of the input commits
    $trees = @()

    # Create an empty string to store the concatenated commit messages of the input commits
    $message = ""

    # Loop through each commit SHA in the input array
    foreach ($commit in $commits) {
        # Use git cat-file to get the type and content of the commit object
        $type, $content = git cat-file -p $commit

        # Check if the type is "commit"
        if ($type -eq "commit") {
            # Split the content by newline and assign the first line to a variable called header
            $header = $content -split "`n" | Select-Object -First 1

            # Split the header by whitespace and assign the third part to a variable called tree
            $tree = $header -split "\s+" | Select-Object -Index 2

            # Add the tree object to the trees array
            $trees += $tree

            # Remove the header and the empty line from the content and assign the rest to a variable called body
            $body = $content -replace "$header`n`n",""

            # Add the body to the message string with a newline separator
            $message += "$body`n"
        }
        else {
            # Throw an error if the type is not "commit"
            throw "The object '$commit' is not a commit."
        }
        
    }

    # Use ResolveConflict function (not implemented here) to resolve any conflicts among the tree objects and return a new tree object
    $resolvedTree = ResolveConflict -trees $trees

    # Use git hash-object to create a new commit object with the resolved tree object and the message string and return its SHA
    $newCommit = echo "tree $resolvedTree`n$message" | git hash-object -t commit -w --stdin


    # Use git update-ref to create a new branch with the new commit as its head
    git update-ref refs/heads/$branchName $newCommit

    # Write the new branch name as output
    Write-Output $branchName

}
