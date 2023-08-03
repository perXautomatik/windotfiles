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

# Loop through each .git file
foreach ($git_file in $non_container_files) {
    # Get the content of the .git file
    $content = Get-Content $git_file
    $regex = "^gitdir:"
    
    # Check if the content starts with "gitdir:"
    if ($content -match "$regex")
     {
        # Extract the path to the git repository
        try {
            $repo_path = Get-RepoPath $content
        }
        catch {
            $repo_path = Get-RepoPath "gitdir: $git_file"
        }
        try {     
            $repoName = Get-RepoName $repo_path
        }
        catch {
            $repoName = $content
        }
    }
    else {
        $repoName = $content
    }
    
        # Check if the repo_path exists and is a directory
        if (Test-Path $repo_path -PathType Container) {
            # Get the parent folder of the repo_path
            $parentXfolder = Split-Path $git_file -Parent

            # Navigate to the parent folder of the repo_path
            Push-Location $parentXfolder

            # Invoke the git status command and capture its output
            $status = git status 2>&1

            # Pop back to the original location
            Pop-Location

            # Capture the first two words from the status output
            $status_words = (($status -join '') -split "\s+")[0..1] -join " "

            # Set the success variable to be those two words
            $success = $status_words

            # Add the result to the array with a success flag and a parent folder column
            $results += [PSCustomObject]@{
                GitFile = $git_file
                                Success = $success
                RepoName = $repoName
                                RepoPath = $repo_path
            }
        }
        else {
            # Add the result to the array with a failure flag and an empty parent folder column
            $results += [PSCustomObject]@{
                GitFile = $git_file
                                Success = $f
                RepoName = $repoName

                                RepoPath = $repo_path
            }
        }
}


# Initialize a hashtable to store the successful git file contents by parent folder
$success_content = @{}

# Loop through each result that is successful
foreach ($result in $results | Where-Object {$_.Success -notmatch $f}) {
    # Get the parent folder of the result
    $repoName = $result.RepoName

    # Get the content of the git file of the result
    $content = Get-Content $result.GitFile

    # Add or update the hashtable with the content by parent folder
    $success_content[$repoName] = $content
}

# Display a summary of different success states by grouping and counting them using Group-Object cmdlet[^1^][1]
Write-Host "Summary of success states:"
$results | Group-Object -Property Success | Format-Table -Property Name, Count

# Display a summary of different parent folders by grouping and counting them using Group-Object cmdlet[^1^][1]
Write-Host "Summary of parent folders:"
$results | Group-Object -Property RepoName | ?{$_.Count -gt 1 } | Sort-Object -Property Count | Format-Table -Property Name, Count

# Display all results in a table format sorted by parent folder using Sort-Object cmdlet[^2^][2]
Write-Host "All results:"
$results | Sort-Object -Property RepoName,Success,RepoPath,GitFile | Format-Table -AutoSize

# Use the LINQ Where method to filter the results by success
$success_results = [Linq.Enumerable]::Where($results, [Func[object,bool]] { param($r) $r.Success -notmatch $f })

# Use the LINQ ToDictionary method to create a hashtable from the success results
$success_content = [Linq.Enumerable]::ToDictionary($success_results, [Func[object,object]] { param($r) $r.RepoName }, [Func[object,object]] { param($r) Get-Content $r.GitFile })

# Loop through each result that is not successful
foreach ($result in $results | Where-Object {$_.Success -match $f}) {
    # Get the parent folder of the result
    $repoName = $result.RepoName

    # Check if there is a successful content for the same parent folder in the hashtable
    if ($success_content.ContainsKey($repoName)) {
        # Get the successful content from the hashtable
        $content = $success_content[$repoName]

        $toRepair += [PSCustomObject]@{
            GitFile = $result.git_file
            RepoName = $repoName
            failed = (get-content -Path $result.git_file)
            toReplace = $content
        }
    }
}

$toRepair

# Loop through each result that is not successful
foreach ($result in $results | Where-Object {$_.Success -match $f}) {
    # Get the parent folder of the result
    $repoName = $result.RepoName

    # Check if there is a successful content for the same parent folder in the hashtable
    if ($success_content.ContainsKey($repoName)) {
        # Get the successful content from the hashtable
        $content = $success_content[$repoName]

        # Create a backup of the old git file by appending ".bak" to its name
        Copy-Item -Path $result.GitFile -Destination "$($result.GitFile).bak"

        # Set the content of the git file of the result to be the same as the successful one
        Set-Content -Path $result.GitFile -Value $content

        # Update the result to be successful and have a valid repo path
        $result.Success = $true
        $result.RepoPath = "$repoName\$content"
    }
}


# Summarize the results by counting the success and failure cases, excluding fatal errors
$success_count = ($results | Where-Object {$_.Success -notmatch $f}).Count
$failure_count = ($results | Where-Object {$_.Success -match $f}).Count

Write-Host "Out of $($results.Count) .git files, excluding fatal errors, $success_count point to real git repositories and $failure_count do not."
