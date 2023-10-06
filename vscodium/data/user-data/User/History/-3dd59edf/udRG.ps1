<#can you write me a powershell script; given a number of relative paths to asingle local git repo,; using a function taking a single relative path as parameter, that uses git log --follow to get a list of all commits toutching a path including renames, returning a list of ps custom objects with properties "commit date" and sha1
#>

# Given a number of relative paths to a single local git repo
$paths = @("src/main.c", "src/helper.c", "README.md")


# Define a function that takes a relative path as a parameter
function Get-CommitsByPath ($path) {
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

<#can you also write a function that uses the get-commitsByPath to return a custom object with the properties "path",date and sha1#>


# Define a function that takes a relative path as a parameter
function Get-CommitInfoByPath ($path) {
    # Call the Get-CommitsByPath function and store the result in a variable
    $commits = Get-CommitsByPath $path
    # Create a custom object with properties "path", "date" and "sha1"
    $obj = [pscustomobject]@{
        "path" = $path
        "date" = $commits."commit date"
        "sha1" = $commits."sha1"
    }
    # Return the object
    return $obj
}


<#can you modify this function to only include the oldest commit from get-commitsbypath#>

# Define a function that takes a relative path as a parameter
function Get-CommitInfoByPath ($path) {
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


# Loop through each path and call the function
foreach ($path in $paths) {
    # Write the path to the console
    Write-Host "Commits for $path:"
    # Call the function and store the result in a variable
    $commits = Get-CommitsByPath $path
    # Format the result as a table and write it to the console
    $commits | Format-Table -AutoSize
}