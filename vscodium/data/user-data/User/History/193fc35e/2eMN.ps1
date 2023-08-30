
<#
.SYNOPSIS
This function creates a custom object with properties related to a git file.

.DESCRIPTION
This function takes a git file as a parameter and uses git commands to get the add response and commit response for the file. It also gets the content of the file and the x file name from the content. It then creates a custom object with add response, commit response, git file, git file content and x file properties and returns it.

.PARAMETER gitFile
The path of the git file to process.

.EXAMPLE
Create-CustomObject -gitFile "B:\ToGit\CmdHistory\.git"

This example creates a custom object with properties related to the "B:\ToGit\CmdHistory\.git" file.
#>
function Create-CustomObject {
    # Define the parameter for the function
    param (
        # The gitFile parameter specifies the path of the git file to process
        [Parameter(Mandatory=$true)]
        [string]$gitFile
    )

    # Get the directory name of the git file using Get-DirectoryName method and store it in a variable
    $gDir = [System.IO.Path]::GetDirectoryName($gitFile)
    # Change the current directory to the gDir variable using cd alias
    cd $gDir

    # Create a custom object with add response, commit response, git file, git file content and x file properties using pscustomobject type and hashtable literal
    [pscustomobject]@{
        addResponse = (git add .)
        commitResponse = (git commit -m "autoCommit")
        gitFile = $gitFile
        gitFileContent = (Get-Content $gitFile)
        xFile = [System.IO.Path]::GetFileName(((Get-Content $gitFile) -split(" ", 2))[1])
    }
}
Yes, I can turn each invoke-everything statement into separate new functions. Here is one possible way:

<#
.SYNOPSIS
This function finds all the files that match a regex pattern for git modules in a given path.

.DESCRIPTION
This function takes a path as a parameter and uses the ES-1.1.0.26\es.exe tool to search for all the files that match the regex pattern for git modules in the path. It also sorts the files by size in descending order and returns them as an array.

.PARAMETER path
The path to search for git modules.

.EXAMPLE
Find-GitModules -path "B:\ToGit"

This example finds all the files that match the regex pattern for git modules in the "B:\ToGit" path and sorts them by size in descending order.
#>
function Find-GitModules {
    # Define the parameter for the function
    param (
        # The path parameter specifies the path to search for git modules
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    # Set an alias for the ES-1.1.0.26\es.exe tool using Set-Alias cmdlet with Name and Value parameters
    Set-Alias -Name Invoke-Everything -Value 'C:\Scripts\ES-1.1.0.26\es.exe'

    # Find all the files that match the regex pattern for git modules using Invoke-Everything cmdlet with Regex and Sort parameters
    # Store the result in an array variable and return it
    $gitModules = @(Invoke-Everything -Regex "$path\\.*\\.git\\.*\\modules\\[a-z0-9]*$" -Sort size)
    return $gitModules
}

<#
.SYNOPSIS
This function finds all the files that match a regex pattern for git config in a given path.

.DESCRIPTION
This function takes a path as a parameter and uses the ES-1.1.0.26\es.exe tool to search for all the files that match the regex pattern for git config in the path. It returns them as an array.

.PARAMETER path
The path to search for git config.

.EXAMPLE
Find-GitConfig -path "B:\ToGit"

This example finds all the files that match the regex pattern for git config in the "B:\ToGit" path.
#>
function Find-GitConfig {
    # Define the parameter for the function
    param (
        # The path parameter specifies the path to search for git config
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    # Set an alias for the ES-1.1.0.26\es.exe tool using Set-Alias cmdlet with Name and Value parameters
    Set-Alias -Name Invoke-Everything -Value 'C:\Scripts\ES-1.1.0.26\es.exe'

    # Find all the files that match the regex pattern for git config using Invoke-Everything cmdlet with Regex parameter
    # Store the result in an array variable and return it
    $gitConfig = @(Invoke-Everything -Regex "$path\\.*\\.git\\.*\\config$")
    return $gitConfig
}

<#
.SYNOPSIS
This function finds all the files that match a regex pattern for git repositories in a given path.

.DESCRIPTION
This function takes a path as a parameter and uses the ES-1.1.0.26\es.exe tool to search for all the files that match the regex pattern for git repositories in the path. It returns them as an array.

.PARAMETER path
The path to search for git repositories.

.EXAMPLE
Find-GitRepos -path "B:\ToGit"

This example finds all the files that match the regex pattern for git repositories in the "B:\ToGit" path.
#>
function Find-GitRepos {
    # Define the parameter for the function
    param (
        # The path parameter specifies the path to search for git repositories
        [Parameter(Mandatory=$true)]
        [string]$path
    )

    # Set an alias for the ES-1.1.0.26\es.exe tool using Set-Alias cmdlet with Name and Value parameters
    Set-Alias -Name Invoke-Everything -Value 'C:\Scripts\ES-1.1.0.26\es.exe'

    # Find all the files that match the regex pattern for git repositories using Invoke-Everything cmdlet with Regex parameter
    # Store the result in an array variable and return it
    $gitRepos = @(Invoke-Everything -Regex "$path\\.*\\.git$")
    return $gitRepos
}
    # Set the environment variable for git redirection using SetEnvironmentVariable method
    [Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

    # Loop through each file in the gitz variable using ForEach-Object cmdlet and store it in a variable
    $whitErrors = $gitz |
        ForEach-Object {
            # Get the directory name of the file using Get-DirectoryName method and store it in a variable
            # Create a custom object with add response, commit response, git file, git file content and x file properties using pscustomobject type and hashtable literal
            Create-CustomObject -gitFile $_ |
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