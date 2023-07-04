Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % { . $_.FullName }

<#
.SYNOPSIS
This function searches for a string in a repository of SQL files and returns a hash table of commits and frequencies of matching the string.

.DESCRIPTION
This function takes four parameters: repoPath, fileName, searchString and date. It uses the Tokenization.ps1 script to tokenize the SQL files in the repository. It then uses git commands to get all commits before the date and search for the string in each commit using regex. It creates a hash table of commits and frequencies of matching the string and sorts it in descending order. It also displays a progress bar while processing the table of commits.

.PARAMETER repoPath
The path to the repository of SQL files.

.PARAMETER fileName
The name of the SQL file to search in.

.PARAMETER searchString
The string to search for in the SQL file.

.PARAMETER date
The cut-off date for the commits.

.EXAMPLE
Search-Repository -repoPath 'D:\Users\crbk01\AppData\Roaming\JetBrains\Datagrip\consolex\db\' -fileName 'harAnsökan (3).sql' -searchString "utanOnÃ¶digaHandlingar" -date "2020-03-02"

This example searches for the string "utanOnÃ¶digaHandlingar" in the file "harAnsökan (3).sql" in the repository "D:\Users\crbk01\AppData\Roaming\JetBrains\Datagrip\consolex\db\" and returns a hash table of commits and frequencies before the date "2020-03-02".
#>
function Search-Repository {
    # Clear the screen
    cls

    # Define the parameters for the function
    param(
        # The repoPath parameter specifies the path to the repository of SQL files
        [Parameter(Mandatory=$true)]
        [string]$repoPath,
        # The fileName parameter specifies the name of the SQL file to search in
        [Parameter(Mandatory=$true)]
        [string]$fileName,
        # The searchString parameter specifies the string to search for in the SQL file
        [Parameter(Mandatory=$true)]
        [string]$searchString,
        # The date parameter specifies the cut-off date for the commits
        [Parameter(Mandatory=$true)]
        [string]$date
    )

    # Set the execution policy to bypass for the current user
    Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

    # Import the Tokenization.ps1 script from the network path
    . '\\100.84.7.151\NetBackup\Project Shelf\ToGit\PowerShellProjectFolder\scripts\TodoProjects\Tokenization.ps1'

    # Escape the search string for regex
    $regexSearchstring = [Regex]::Escape($searchString)

    # Change the current directory to the repository path
    cd $repoPath

    # Define a function to get all commits in the repository before a given date

    # Get all commits before the date using Get-Commits function and store them in a variable
    $mytable = Get-Commits -Date $date

    # Create a hash table of commits and frequencies using Get-HashTable function and store it in a variable
    $hashTable = Get-HashTable -Commits $mytable -String $searchString -Regex $true

    # Display a progress bar while processing the table of commits using Show-Progress function
    Show-Progress -Commits $mytable

    # Sort the hash table by frequency in descending order and display the results
    $hashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name
}