<#
can you write me a powershell script; given a number of relative paths to asingle local git repo,;
 using a function taking a single relative path as parameter, 
 that uses git log --follow to get a list of all commits toutching a path including renames, 
 returning a list of ps custom objects with properties "commit date" and sha1
 #>

 function Get-CommitsByPath ($path) {
    # Define a function that takes a relative path as a parameter
    # Use git log --follow to get a list of all commits touching the path, including renames
    $log = git log --follow --format="%ad %H" --date=iso $path
    # Split the log by newline and loop through each line
    foreach ($line in $log -split "`n") {
        # Split the line by space and assign the first part to $date and the second part to $sha1
        $date, $sha1 = $line -split " ", 2
        # Create a custom object with properties "commit date" and "sha1"
        $obj = [pscustomobject]@{
            "commit date" = $date
            "sha1" = $sha1
        }
        # Return the object
        return $obj
    }
}


function Get-CommitInfoByPath ($path) {
    <#can you also write a function that uses the get-commitsByPath to return a custom object with the properties "path",date and sha1
    can you modify this function to only include the oldest commit from get-commitsbypath#>
    
    # Define a function that takes a relative path as a parameter
    # Call the Get-CommitsByPath function and store the result in a variable
    $commits = Get-CommitsByPath $path
    # Sort the commits by date in ascending order and select the first one
    $oldest = $commits | Sort-Object -Property "commit date" | Select-Object -First 1
    # Create a custom object with properties "path", "date" and "sha1"
    $obj = [pscustomobject]@{
        "path" = $path
        "date" = $oldest."commit date"
        "sha1" = $oldest."sha1"
    }
    # Return the object
    return $obj
}

<#can you write me a powershell function with a filename as parameter, that uses git log --follow to list each unique path the file has bin at#>

# Define a function that takes a filename as a parameter
function Get-PathsByFile ($filename) {
    # Use git log --follow to get a list of all commits touching the file, including renames
    $log = git log --follow --name-only --format="" $filename
    # Split the log by newline and store it in an array
    $paths = $log -split "`n"
    # Remove any empty elements from the array
    $paths = $paths | Where-Object {$_}
    # Get the unique elements from the array
    $paths = $paths | Select-Object -Unique
    # Return the array
    return $paths
}

# Given a number of relative paths to a single local git repo
$paths = @("src/main.c", "src/helper.c", "README.md")


<#can you write me a script that, given a list of paths ; sort each path in order of oldest to youngest by there oldest "commit date", identifying the oldest commit as $oldest, #>

# Loop through each path and call the function
$sorted = $paths| % { Get-CommitInfoByPath $_ } | sort -property date 

$oldest = $sorted | select -first 1
$toMove = $sorted | select -skip 1

<#then uses a function that lists the relative paths $oldest have had through out the repo into an array $oldPaths, #>
$oldPaths = get-pathsByFile $oldest

# Define a function that takes an array of paths and a new filename as parameters
function chain-renamePaths ($paths, $newname) {
    # Initialize an empty array to store the arguments for git filter-repo
    $args = @()

    # Loop through each path and add a rename-path option to the argument array
    foreach ($path in $paths) {
        # Add a rename-path option with the old and new filenames
        $args += "--rename-path", "$path:$newname"
    }

    # Invoke git filter-repo with the argument array
    git filter-repo $args
}


chain-renamePaths $oldPaths $oldest.path

<# Define a function that takes an array of paths and a new filename as parameters
 with a callback function to change any commit with a path contained in the parameter array, moving any file in the commit that has a path 
contained in the array parameter to the path by the relative path parameter.
position, then use a function that eather uses git filter-branch or git filter-repo to move each of the other paths into the "oldest paths" 
head location, except in case of the repository at the commit already have a file occypying that path at the time, then it overwrites that 
path with the content of the newer path,#>

function chain-RenameForced ($paths, $newname) {
    # Initialize an empty string to store the Python callback code
    $callback = ""

    # Loop through each path and add a rename-path option to the callback code
    foreach ($path in $paths) {
        # Add a line of Python code that checks if the file already exists at the new filename
        $callback += "if os.path.exists(os.path.join(repopath, b'$newname')): "
        # If it does, remove the file
        $callback += "os.remove(os.path.join(repopath, b'$newname')); "
        # Then rename the path to the new filename
        $callback += "if filepath == b'$path': filepath = b'$newname'; "
    }

    # Invoke git filter-repo with the --filename-callback option and the callback code
    git filter-repo --filename-callback $callback
}

$toMove | ? { $_.path -notin $oldPaths } | 
%{ 
    $tm = $_ 
    $op = ( get-pathsByFile $tm ) | ? { $_.path -notin $oldPaths } 

    if($op)
    {
        chain-RenameForced $op $tm
    }
}
    



