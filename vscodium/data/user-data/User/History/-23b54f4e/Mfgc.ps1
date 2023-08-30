<# Synopsis: Searches for a string in all branches of a git repository and counts the occurrences
# Parameters:
#   -Match: The string to search for
#   -Path: The path to the git repository
# Example usage:
Search-GitAllBranches -Match 'echo' -Path 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell'

#>
function Search-GitAllBranches {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Match,
 
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
 
    # Change directory to the path
    Set-Location $Path

    # Get the first 10 revisions from the git history and grep for the match in each of them
    $mytable = ((git rev-list --all) | 
    Select-Object -First 10 |
    ForEach-Object { (git grep $Match $_ )})  | ForEach-Object { $all = $_.Split(':') ; [system.String]::Join(":", $all[2..$all.length]) }

    # Initialize an empty hashtable
    $HashTable=@{}

    # For each line in mytable, increment the count for that line in the hashtable
    foreach($r in $mytable)
    {
        $HashTable[$r]++
    }

    # Initialize a null variable for errors
    $errors = $null

    # Get the hashtable entries and sort them by value and name
    $HashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name 
}

