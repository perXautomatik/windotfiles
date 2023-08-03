# Define the path to search for .git files
$path = "B:\PF\"

# Define the path to the Everything command line tool
$es = "C:\ProgramData\scoop\shims\es.exe"
$f = "fatal"
# Get the list of .git files using Everything
$git_files = & $es -p $path -s -regex "[.]git$"

# Define two array variables to store the files by their path type
$container_files = @()
$non_container_files = @()
# Define a function to extract the path to the git repository from the content of a .git file
function Get-RepoPath {
    <#
    .SYNOPSIS
    Extracts the path to the git repository from the content of a .git file.

    .DESCRIPTION
    This function takes the content of a .git file as a parameter and returns the path to the git repository.
    It assumes that the content starts with "gitdir:" followed by the relative or absolute path to the repository.
    If the path is relative, it converts it to an absolute path using System.IO.Path.GetFullPath method.

    .PARAMETER Content
    The content of a .git file as a string.

    .EXAMPLE
    PS C:\> Get-RepoPath "gitdir: ../.git/modules/project1"
    C:\Users\user\.git\modules\project1

    .EXAMPLE
    PS C:\> Get-RepoPath "gitdir: C:\Users\user\Documents\project2\.git"
    C:\Users\user\Documents\project2\.git
    #>

    # Validate the parameter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Content
    )

    # Define a regular expression to match the gitdir prefix
    $regex = "^gitdir:"

    # Check if the content matches the regex
    if ($Content -match $regex) {
        # Extract the path to the git repository
            $rp = ($Content -replace "$regex\s*")

            # Check if the rp is not empty
            if ($rp) {
                # Check if the rp is a valid path
                try {
                    # Try to get the full path of the rp
                    $repo_path = [System.IO.Path]::GetFullPath($rp)
                }
                catch {
                    # Catch any exception and throw an error
                    throw "Invalid path. The path '$rp' is not a valid path."
                }
            }
            else {
                # Throw an error if the rp is empty
                throw "Empty path. The content must contain a non-empty path after 'gitdir:'."
            }


        # Return the repo_path
        
        if((Get-RepoName $repo_path) -like "*.git")
        {
            # Get the parent folder name as the repo name using Split-Path cmdlet
            $repo_path = Split-Path $repo_path -Parent
        }
        
        return $repo_path

    }
    else {
        # The content does not match the regex, throw an error
        throw "Invalid content. The content must start with 'gitdir:' followed by the path to the git repository."
    }


}

# Define a function to get the repo name from the repo path
function Get-RepoName {
    <#
    .SYNOPSIS
    Gets the repo name from the repo path.

    .DESCRIPTION
    This function takes the repo path as a parameter and returns the repo name.
    It uses Split-Path cmdlet to get the last part of the repo path as the repo name.
    If the repo name is ".git", it uses Split-Path cmdlet again to get the parent folder name as the repo name.

    .PARAMETER RepoPath
    The repo path as a string.

    .EXAMPLE
    PS C:\> Get-RepoName "C:\Users\user\.git\modules\project1"
    project1

    .EXAMPLE
    PS C:\> Get-RepoName "C:\Users\user\Documents\project2\.git"
    project2
    #>

    # Validate the parameter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath
    )
        # Get the last part of the repo path as the repo name using Split-Path cmdlet
        $repoName = Split-Path $RepoPath -Leaf

        # Check if the repo name is ".git"
        if($repoName -like ".git")
        {
            # Get the parent folder name as the repo name using Split-Path cmdlet
            $repoName = Split-Path (Split-Path $RepoPath -Parent) -Leaf
        }

        # Return the repo name
        
        return $repoName
    
}
# Define a function to get the content of a .git file
function Get-GitFileContent {
    <#
    .SYNOPSIS
    Gets the content of a .git file.

    .DESCRIPTION
    This function takes the path of a .git file as a parameter and returns its content as a string.
    It uses Get-Content cmdlet to read the file content.

    .PARAMETER GitFile
    The path of a .git file as a string.

    .EXAMPLE
    PS C:\> Get-GitFileContent "B:\PF\project1\.git"
    gitdir: ../.git/modules/project1
    #>

    # Validate the parameter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$GitFile
    )

    # Check if the GitFile exists and is not a directory
    if (Test-Path $GitFile -PathType Leaf) {
        # Get the content of the GitFile using Get-Content cmdlet
        $content = Get-Content $GitFile

        # Return the content
        return $content
    }
    else {
        # Throw an error if the GitFile does not exist or is a directory
        throw "Invalid file. The GitFile '$GitFile' does not exist or is a directory."
    }
}

# Define a function to extract the path to the git repository from the content of a .git file
function Get-RepoPath {
    <#
    .SYNOPSIS
    Extracts the path to the git repository from the content of a .git file.

    .DESCRIPTION
    This function takes the content of a .git file as a parameter and returns the path to the git repository.
    It assumes that the content starts with "gitdir:" followed by the relative or absolute path to the repository.
    If the path is relative, it converts it to an absolute path using System.IO.Path.GetFullPath method.

    .PARAMETER Content
    The content of a .git file as a string.

    .EXAMPLE
    PS C:\> Get-RepoPath "gitdir: ../.git/modules/project1"
    C:\Users\user\.git\modules\project1

    .EXAMPLE
    PS C:\> Get-RepoPath "gitdir: C:\Users\user\Documents\project2\.git"
    C:\Users\user\Documents\project2\.git
    #>

    # Validate the parameter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Content
    )

    # Define a regular expression to match the gitdir prefix
    $regex = "^gitdir:"

    # Check if the content matches the regex
    if ($Content -match $regex) {
        # Extract the path to the git repository
            $rp = ($Content -replace "$regex\s*")

            # Check if the rp is not empty
            if ($rp) {
                # Check if the rp is a valid path
                try {
                    # Try to get the full path of the rp using System.IO.Path.GetFullPath method
                    $repo_path = [System.IO.Path]::GetFullPath($rp)
                }
                catch {
                    # Catch any exception and throw an error
                    throw "Invalid path. The path '$rp' is not a valid path."
                }
            }
            else {
                # Throw an error if the rp is empty
                throw "Empty path. The content must contain a non-empty path after 'gitdir:'."
            }


        # Return the repo_path
        
        return $repo_path
    }
    else {
        # The content does not match the regex, throw an error
        throw "Invalid content. The content must start with 'gitdir:' followed by the path to the git repository."
    }


}

# Define a function to get the repo name from the repo path
function Get-RepoName {
    <#
    .SYNOPSIS
    Gets the repo name from the repo path.

    .DESCRIPTION
    This function takes the repo path as a parameter and returns the repo name.
    It uses Split-Path cmdlet to get the last part of the repo path as the repo name.
    If the repo name is ".git", it uses Split-Path cmdlet again to get the parent folder name as the repo name.

    .PARAMETER RepoPath
    The repo path as a string.

    .EXAMPLE
    PS C:\> Get-RepoName "C:\Users\user\.git\modules\project1"
    project1

    .EXAMPLE
    PS C:\> Get-RepoName "C:\Users\user\Documents\project2\.git"
    project2
    #>

    # Validate the parameter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath
    )

    
        # Get the last part of the repo path as the repo name using Split-Path cmdlet
        $repoName = Split-Path $RepoPath -Leaf

        # Check if the repo name is ".git"
        if($repoName -eq ".git")
        {
            # Get the parent folder name as the repo name using Split-Path cmdlet
            $repoName = Split-Path (Split-Path $RepoPath -Parent) -Leaf
        }

        # Return the repo name
        
        return $repoName
    
}

# Define a function to get the git status of a repo path
function Get-GitStatus {
    <#
    .SYNOPSIS
    Gets the git status of a repo path.

    .DESCRIPTION
    This function takes the repo path and the parent folder of the .git file as parameters and returns the git status as a string.
    It uses git status command to get the status of the repository and captures its output.
    It returns the first two words from the output as the status.

    .PARAMETER RepoPath
    The repo path as a string.

    .PARAMETER ParentFolder
    The parent folder of the .git file as a string.

    .EXAMPLE
    PS C:\> Get-GitStatus "C:\Users\user\.git\modules\project1" "B:\PF\project1"
    On branch

    .EXAMPLE
    PS C:\> Get-GitStatus "C:\Users\user\Documents\project2\.git" "C:\Users\user\Documents\project2"
    fatal: not
    #>

    # Validate the parameters
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ParentFolder
    )

            # Navigate to the ParentFolder using Push-Location cmdlet
            Push-Location $ParentFolder

            # Invoke the git status command and capture its output using Invoke-Expression cmdlet
            $status = Invoke-Expression "git status" 2>&1

            # Pop back to the original location using Pop-Location cmdlet
            Pop-Location

            # Capture the first two words from the status output using split and slice methods
            $status_words = (($status -join '') -split "\s+")[0..1] -join " "

            # Return the status words
            return $status_words
}
# Define a function to get the content of a .git file
function Get-GitFileContent {
    <#
    .SYNOPSIS
    Gets the content of a .git file.

    .DESCRIPTION
    This function takes the path of a .git file as a parameter and returns its content as a string.
    It uses Get-Content cmdlet to read the file content.

    .PARAMETER GitFile
    The path of a .git file as a string.

    .EXAMPLE
    PS C:\> Get-GitFileContent "B:\PF\project1\.git"
    gitdir: ../.git/modules/project1
    #>

    # Validate the parameter
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$GitFile
    )

    # Check if the GitFile exists and is not a directory
    if (Test-Path $GitFile -PathType Leaf) {
        # Get the content of the GitFile using Get-Content cmdlet
        $content = Get-Content $GitFile

        # Return the content
        return $content
    }
    else {
        # Throw an error if the GitFile does not exist or is a directory
        throw "Invalid file. The GitFile '$GitFile' does not exist or is a directory."
    }
}

# Define a function to add or update the hashtable with the content by repo name
function Add-ContentByRepoName {
    <#
    .SYNOPSIS
    Adds or updates the hashtable with the content by repo name.

    .DESCRIPTION
    This function takes a result object, a hashtable, and a regex as parameters and adds or updates the hashtable with the content by repo name.
    It uses Get-GitFileContent function to get the content of the git file of the result.
    It uses Test-Path cmdlet to check if the result is successful or not.
    
    .PARAMETER Result
    A result object that contains the properties GitFile, Success, RepoName, and RepoPath.

    .PARAMETER Hashtable
    A hashtable that stores the content by repo name.

    .PARAMETER Regex
    A regular expression that matches the success pattern.

    .EXAMPLE
    PS C:\> Add-ContentByRepoName $result $success_content "fatal"
    
    #>

    # Validate the parameters
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [PSCustomObject]$Result,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [hashtable]$Hashtable,

        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Regex
    )

    
        # Get the repo name of the result
        $repoName = $Result.RepoName

        # Check if the result is successful or not using Test-Path cmdlet and Regex parameter
        if (Test-Path $Result.RepoPath -PathType Container -and $Result.Success -notmatch $Regex) {
            # Get the content of the git file of the result using Get-GitFileContent function
            $content = Get-GitFileContent $Result.GitFile

            # Add or update the hashtable with the content by repo name
            $Hashtable[$repoName] = $content
        }
    
}

# Define a function to create an object for repairing a failed result
function New-RepairObject {
    <#
    .SYNOPSIS
    Creates an object for repairing a failed result.

    .DESCRIPTION
    This function takes a result object, a hashtable, and a regex as parameters and creates an object for repairing a failed result.
    It uses Get-GitFileContent function to get the content of the git file of the result.
    It uses Test-Path cmdlet and ContainsKey method to check if there is a successful content for the same repo name in the hashtable.
    
    .PARAMETER Result
    A result object that contains the properties GitFile, Success, RepoName, and RepoPath.

    .PARAMETER Hashtable
    A hashtable that stores the content by repo name.

    .PARAMETER Regex
    A regular expression that matches the failure pattern.

     .EXAMPLE
     PS C:\> New-RepairObject $result $success_content "fatal"
     
     #>

     # Validate the parameters
     [CmdletBinding()]
     param (
         [Parameter(Mandatory=$true)]
         [ValidateNotNull()]
         [PSCustomObject]$Result,
 
         [Parameter(Mandatory=$true)]
         [ValidateNotNull()]
         [hashtable]$Hashtable,
 
         [Parameter(Mandatory=$true)]
         [ValidateNotNullOrEmpty()]
         [string]$Regex
     )

     
         # Get the repo name of the result
         $repoName = $Result.RepoName
 
         # Check if the result is not successful using Test-Path cmdlet and Regex parameter
         if (-not (Test-Path $Result.RepoPath -PathType Container) -or $Result.Success -match $Regex) {
             # Check if there is a successful content for the same repo name in the hashtable using ContainsKey method
             if ($Hashtable.ContainsKey($repoName)) {
                 # Get the successful content from the hashtable
                 $content = $Hashtable[$repoName]
 
                 # Get the failed content of the git file of the result using Get-GitFileContent function
                 $failed = Get-GitFileContent $Result.GitFile
 
                 # Create an object for repairing the failed result with properties RepoName, toReplace, failed, and GitFile
                 $repairObject = [PSCustomObject]@{
                     RepoName = $repoName
                     toReplace = $content
                     failed = $failed
                     GitFile = $Result.GitFile
                 }
 
                 # Return the repair object
                 return $repairObject
             }
         }
     
 }


# Loop through the files and check their path type using Test-Path
foreach ($file in $git_files) {
    if (Test-Path $file -PathType Container) {
        # Add the file to the container array
        $container_files += $file
    } else {
        # Add the file to the non-container array
        $non_container_files += $file
    }
}

# Display the arrays and their counts
Write-Host "Container files: $($container_files.Count)"

Write-Host "Non-container files: $($non_container_files.Count)"

# Initialize an empty array to store the results
$results = @()
$toRepair = @()
# Initialize a counter variable to track the progress
$counter = 0


# Loop through each .git file using ForEach-Object cmdlet
$non_container_files | ForEach-Object {
    
    # Increment the counter by one
    $counter++

    # Write a progress message using Write-Progress cmdlet
    Write-Progress -Activity "Processing .git files" -Status "Processing file $counter of $($non_container_files.Count)" -PercentComplete ($counter / $non_container_files.Count * 100)

    # Get the content of the .git file using Get-GitFileContent function
    try {
        $content = Get-GitFileContent $_
        
        # Extract the path to the git repository using Get-RepoPath function
        try {
            $repo_path = Get-RepoPath $content
            
            # Get the repo name from the repo path using Get-RepoName function
            try {
                $repoName = Get-RepoName $repo_path
                
                # Get the git status of the repo path using Get-GitStatus function
                try {
                    # Check if the repo_path exists and is a directory
                    if (Test-Path $repo_path -PathType Container) {
                        # Get the parent folder of the repo_path
        
                    $success = Get-GitStatus -ParentFolder ($_ | split-path -parent )
                }
                else {
                    $success = "fatal"
                }

                    # Add the result to the array with a success flag and a repo name column
                    $results += [PSCustomObject]@{
                        GitFile = $_
                        Success = $success
                        RepoName = $repoName
                        RepoPath = $repo_path
                    }
                }catch {}
            }catch {}
        }catch {}
    }catch {}
}


# Initialize a hashtable to store the successful git file contents by parent folder
$success_content = @{}


# Display a summary of different success states by grouping and counting them using Group-Object cmdlet[^1^][1]
Write-Host "Summary of success states:"
$results | Group-Object -Property Success | Format-Table -Property Name, Count

# Display a summary of different parent folders by grouping and counting them using Group-Object cmdlet[^1^][1]
Write-Host "Summary of parent folders:"
$results | Group-Object -Property RepoName | ?{$_.Count -gt 1 } | Sort-Object -Property Count | Format-Table -Property Name, Count

# Display all results in a table format sorted by parent folder using Sort-Object cmdlet[^2^][2]
Write-Host "All results:"
$results | Sort-Object -Property RepoName,Success,RepoPath,GitFile | Format-Table -AutoSize

# Use the LINQ ToDictionary method to create a hashtable from the success results# Use the LINQ Where method to filter the success results by content
$success_results = [Linq.Enumerable]::Where($results, [Func[object,bool]] { param($r) $r.Success -notmatch $f -and $r.Success -ne "" -and (Get-Content $r.GitFile) -ne "gitdir: " })
# Initialize a hashtable to store the successful git file contents by repo name
$success_content = @{}

# Initialize an empty array to store the objects for repairing the failed results
$toRepair = @()

# Loop through each result using ForEach-Object cmdlet
$success_results | ForEach-Object {

    # Add or update the hashtable with the content by repo name using Add-ContentByRepoName function
    Add-ContentByRepoName $_ $success_content "fatal"

    # Create an object for repairing a failed result using New-RepairObject function
    $repairObject = New-RepairObject $_ $success_content "fatal"

    # Check if the repair object is not null
    if ($repairObject) {
        # Add the repair object to the array
        $toRepair += $repairObject
    }
}

# Display the array of repair objects in a table format sorted by repo name, to replace, failed, and git file using Sort-Object and Format-Table cmdlets
$toRepair | Sort-Object -Property RepoName,toReplace,failed,GitFile | Format-Table -AutoSize


# Loop through each result that is not successful
foreach ($resultx in $toRepair) {
    # Get the parent folder of the result
    $repoName = $resultx.RepoName

    # Get the successful content from the hashtable
    $content = $resultx.toReplace

    # Create a backup of the old git file by appending ".bak" to its name
    Copy-Item -Path $resultx.GitFile -Destination "$($resultx.GitFile).bak"

    # Set the content of the git file of the result to be the same as the successful one
    Set-Content -Path $resultx.GitFile -Value $content

    # Update the result to be successful and have a valid repo path
}


# Summarize the results by counting the success and failure cases, excluding fatal errors
$success_count = ($results | Where-Object {$_.Success -notmatch $f}).Count
$failure_count = ($results | Where-Object {$_.Success -match $f}).Count

Write-Host "Out of $($results.Count) .git files, excluding fatal errors, $success_count point to real git repositories and $failure_count do not."
