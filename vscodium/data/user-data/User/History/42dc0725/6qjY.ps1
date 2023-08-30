<# Example usage: Get the duplicate files in the current branch and format them as a table
Get-DuplicateFiles | Format-DuplicateFiles
#>

# Synopsis: List duplicate files in a git repository
function Get-DuplicateFiles {
    param(
        # The name of the git branch to check
        [string]$Branch = "HEAD"
    )

    # Get the tree objects from the git branch
    $tree = git ls-tree -r $Branch

    # Parse the tree objects into custom objects with properties
    $objects = $tree | ForEach-Object {
        [pscustomobject]@{
            unkown = $_.substring(0,6)
            blob = $_.substring(7,4)
            hash = $_.substring(12,40)
            relativePath = $_.substring(53)
        }
    }

    # Group the objects by hash and filter out the ones with unique hashes
    $duplicates = $objects | Group-Object -Property hash | Where-Object { $_.count -ne 1 }

    # Sort the duplicates by count in descending order and select the desired properties
    $duplicates | Sort-Object -Property count -Descending | ForEach-Object { $_.group } | Select-Object @{name="h1";expression={$_.hash.substring(38)}}, relativePath
}

# Synopsis: Format the output of Get-DuplicateFiles as a table
function Format-DuplicateFiles {
    param(
        # The output of Get-DuplicateFiles
        [psobject[]]$InputObject
    )

    # Format the input object as a table with headers and auto-sizing
    $InputObject | Format-Table -AutoSize -Property h1, relativePath -GroupBy h1
}
