# Define a function A that takes a path and returns a custom object with the leaf, parent, and subparent
function Get-PathComponents ($path) {
    # Split the path by the directory separator
    $parts = $path -split "\\"
    # Get the last element as the leaf
    $leaf = $parts[-1]
    # Get the second last element as the parent
    $parent = $parts[-2]
    # Get the third last element as the subparent
    $subparent = $parts[-3]
    # Create a custom object with the properties
    $obj = [PSCustomObject]@{
        Leaf = $leaf
        Parent = $parent
        Subparent = $subparent
    }
    # Return the object
    return $obj
}

# Define a function that takes a path and returns the root of the parent git repo, or null if not found
function Get-GitRoot ($path) {
    # Check if the path is a valid directory
    if (Test-Path -Path $path -PathType Container) {
        # Get the current location
        $current = Get-Location
        # Change to the path directory
        Set-Location -Path $path
        # Invoke git rev-parse to get the root of the git repo, or an error message if not found
        $output = git rev-parse --show-toplevel 2>&1
        # Check if the output is an error message
        if ($output -match "not a git repository") {
            # Return null
            return $null
        }
        else {
            # Return the output as the root of the git repo
            return $output
        }
        # Restore the original location
        Set-Location -Path $current
    }
    else {
        # Return null
        return $null
    }
}

# Define a function that takes a path and removes the memory of the parent directory of Q in the parent git repo, if any
# Define a function that takes a path and removes the memory of the parent directory of Q in the parent git repo, if any
function Remove-Memory ($path) {
    # Try to get the parent directory of Q
    try {
        $qq = (Split-Path -Path $path -Parent)
        $parent = Split-Path -Path $qq -Parent 
    }
    catch {
        # Write an error message to the console and exit the function
        Write-Error "Invalid path: '$path'"
        return
    }
    # Try to get the root of the parent git repo, if any
    try {
        $root = Get-GitRoot -Path $parent
    }
    catch {
        # Write an error message to the console and exit the function
        Write-Error "Failed to get the root of the parent git repo for '$parent'"
        return
    }
    # Check if the root is not null
    if ($root) {
        # Try to change the current directory to the root of the git repo
        try {
            cd $root
        }
        catch {
            # Write an error message to the console and exit the function
            Write-Error "Failed to change directory to '$root'"
            return
        }
        # Try to get the relative path of the parent directory from the root of the git repo
        try {
            $relative = (Resolve-Path -Path $qq -Relative -ErrorAction Stop ) 
        }
        catch {
            # Write an error message to the console and exit the function
            Write-Error "Failed to resolve relative path for '$qq'"
            return
        }
        # Try to invoke git filter-branch to remove the memory of the parent directory from the git history, or an error message if not found or failed
        try {
            $output = git rm --cached -r $relative 2>&1 
            # Check if the output is an error message
            if ($output -match "fatal") {
                # Throw an exception with the output as the message
                throw $output
            }
            else {
                # Write a success message to the console
                Write-Output "Successfully removed memory of '$relative' from git history"
            }
        }
        catch {
            # Write an error message to the console with the exception message
            Write-Error "Failed to remove memory of '$relative' from git history: $_"
        }
    }
}


# Get content of file Q and extract a path from it (assuming it is in plain text and has only one line)
$Q = "B:\PF\chris\autohotkey\script\fork\NoahHotell\.git"
$content = Get-Content -Path $Q | Select-Object -First 1

# Use function Get-PathComponents on the content of file Q and display it as a table
$A_content = Get-PathComponents -path $content 
$A_content | Format-Table

# Use function Get-PathComponents on the path of file Q and display it as a table 
$A_Q = Get-PathComponents -path $Q 
$A_Q | Format-Table

# Use function Remove-Memory on file Q 
Remove-Memory -path $Q
