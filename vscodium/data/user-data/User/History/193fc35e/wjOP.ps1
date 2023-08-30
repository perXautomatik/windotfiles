<#
.SYNOPSIS
This script finds all the git repositories in a given path and tries to commit them. It also reports any errors that occur due to invalid paths.

.DESCRIPTION
This script uses the ES-1.1.0.26\es.exe tool to search for all the files that match a regex pattern in a given path. It then uses git commands to add and commit all the files in each git repository. It also creates a custom object with the add response, commit response, git file, git file content and x file properties for each repository. It then filters the custom object by the commit response that contains "fatal: cannot chdir" error and outputs the new target file for each error.

.PARAMETER path
The path to search for git repositories.

.EXAMPLE
Commit-GitRepos -path "B:\ToGit"

This example finds all the git repositories in the "B:\ToGit" path and tries to commit them. It also reports any errors that occur due to invalid paths.
#>
function Commit-GitRepos {
    # Define the parameter for the function
    param (
        # The path parameter specifies the path to search for git repositories
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    # Set an alias for the ES-1.1.0.26\es.exe tool using Set-Alias cmdlet with Name and Value parameters
    Set-Alias -Name Invoke-Everything -Value 'C:\Scripts\ES-1.1.0.26\es.exe'

    # Find all the files that match the regex pattern for git modules using Invoke-Everything cmdlet with Regex and Sort parameters
    # Store the result in an array variable
    $wholeGitz = @(Invoke-Everything -Regex "\\.git\\.*\\modules\\[a-z0-9]*$" -Sort size)

    # Find all the files that match the regex pattern for git config using Invoke-Everything cmdlet with Regex parameter
    # Store the result in an array variable
    $conf = @(Invoke-Everything -Regex "\\.git\\.*\\config$")

    # Get the directory name of each file in the conf variable using Get-DirectoryName method and store it in an array variable
    $confP = $conf | ForEach-Object { [System.IO.Path]::GetDirectoryName($_) }

    # Find all the files that match the regex pattern for git repositories in the path parameter using Invoke-Everything cmdlet with Regex parameter
    # Store the result in an array variable
    $gitz = @(Invoke-Everything -Regex "$path\\.*\\.git$")

    # Set the environment variable for git redirection using SetEnvironmentVariable method
    [Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

    # Loop through each file in the gitz variable using ForEach-Object cmdlet and store it in a variable
    $whitErrors = $gitz |
        ForEach-Object {
            # Get the directory name of the file using Get-DirectoryName method and store it in a variable
            $gDir = [System.IO.Path]::GetDirectoryName($_)
            # Change the current directory to the gDir variable using cd alias
            cd $gDir

            # Create a custom object with add response, commit response, git file, git file content and x file properties using pscustomobject type and hashtable literal
            [pscustomobject]@{
                addResponse = (git add .)
                commitResponse = (git commit -m "autoCommit")
                gitFile = $_
                gitFileContent = (Get-Content $_)
                xFile = [System.IO.Path]::GetFileName(((Get-Content $_) -split(" ", 2))[1])
            } |
                # Filter the custom object by the commit response that contains "fatal: cannot chdir" error using Where-Object cmdlet with ScriptBlock parameter
                Where-Object { $_.commitResponse.toString() -match "fatal: cannot chdir" }
        }

    # Loop through each custom object in the whitErrors variable using ForEach-Object cmdlet
    $whitErrors |
        ForEach-Object {
            # Store the x file property in a variable
            $u = $_.xFile

            # Find all the configs that have the same file name as the x file property using Where-Object cmdlet with ScriptBlock parameter
            $configs = ($confP | Where-Object { $x = $_; [System.IO.Path]::GetFileName($x) -eq $u })

            # Find the new target file that is in both configs and wholeGitz variables using Where-Object cmdlet with In operator and array indexing
            $newTarget = ($wholeGitz | Where-Object { $_ -in $configs })[0]
            # Output the new target file
            $newTarget
        }
}