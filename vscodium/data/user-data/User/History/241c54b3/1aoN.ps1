# Parse the output of git ls-tree command and return a custom object
function Consume-LsTree {
    [CmdletBinding()]
    param(
        # The script or file path to parse
        [Parameter(Mandatory, ValueFromPipeline)]                        
        [string[]]$LsTree
    )
    # Add a synopsis comment
    <#
        .SYNOPSIS
        Parse the output of git ls-tree command and return a custom object.

        .DESCRIPTION
        This function takes the output of git ls-tree command as input and extracts the blob type, hash and relative path of each file. It returns a custom object with these properties.

        .EXAMPLE
        git ls-tree -r HEAD | Consume-LsTree

        This example parses the output of git ls-tree -r HEAD command and returns a custom object with blob type, hash and relative path of each file in the current branch.
    #>
    process {
        # Get the blob type from the input string
        $blobType = $_.substring(7,4)
        # Set the start positions of hash and relative path based on the blob type
        $hashStartPos = 12
        $relativePathStartPos = 53

        if ($blobType -ne 'blob')
            {
            $hashStartPos+=2
            $relativePathStartPos+=2
            } 

        # Create and return a custom object with the extracted properties
        [pscustomobject]@{unkown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     
     } 
}

# Get the absolute path and file name of each file in a repository
function Get-RepoInfo {
    param (
        # The repository path to scan
        [Parameter(Mandatory=$true)]
        [string]$RepoPath
    )
    # Validate the repo path parameter
    if (-not (Test-Path $RepoPath)) {
        throw "Invalid repository path: $RepoPath"
    }
    # Change the current location to the repo path
    Push-Location $RepoPath

    # Run the code block to get the output of git ls-tree command and parse it with Consume-LsTree function
    $codeBlock = {  (git ls-tree -r HEAD  | Consume-LsTree  | Select-Object -Property *,@{Name = 'absolute'; Expression = {
               $agressor = [regex]::escape('\')
               $replacement = $agressor+'\d{3}'+$agressor+'\d{3}'
       
       
                    $rp =  $_.relativePath.Trim('"')
                
                    $q = Resolve-Path $rp -ErrorAction SilentlyContinue  ; 
                 
                    if(!($q) -and $rp -match ($replacement ))
                    { 
                       $q = Resolve-Path  (($rp -split($replacement) ) -join('*')) 
                    }

                    return $q     
     } } | Select-Object -Property *,@{Name = 'FileName'; Expression = {$path = $_.absolute;$filename = [System.IO.Path]::GetFileNameWithoutExtension("$path");if(!($filename)) { $filename = [System.IO.Path]::GetFileName("$path") };$filename}},@{Name = 'Parent'; Expression = {Split-Path -Path $_.relativePath}}
) }

    # Return the output of the code block as an array
    [Linq.Enumerable]::ToArray(&$codeBlock)

    # Restore the previous location
    Pop-Location

}

# Join two repositories based on their file names and return a custom object with their hashes and absolute paths
function Join-Repos {
    param (
        # The first repository to join
        [Parameter(Mandatory=$true)]
        [psobject[]]$Repo1,
        # The second repository to join
        [Parameter(Mandatory=$true)]
        [psobject[]]$Repo2,
        # The result delegate to define the output format
        [Parameter(Mandatory=$true)]
        [System.Func[Object,Object,Object]]$ResultDelegate
    )
    
    # Define the key delegate to use the file name as the join condition
    $KeyDelegate = [System.Func[Object,string]] {$args[0].FileName}
    
    # Join the two repositories using Linq and return the output as an array
    $linqJoinedDataset = [System.Linq.Enumerable]::Join( $Repo1, $Repo2, #tableReference
        
                                                     $KeyDelegate,$KeyDelegate, #onClause
                
                                                     $ResultDelegate
    )
    [System.Linq.Enumerable]::ToArray($linqJoinedDataset)

}

# Create a lookup table based on the hash of each file in a repository
function Lookup-Repo {
    param (
        # The repository to create the lookup table from
        [Parameter(Mandatory=$true)]
        [psobject[]]$Repo
    )

    # Define the hash delegate to use the hash as the key
    $HashDelegate = [system.Func[Object,String]] { $args[0].hash }
    # Define the element delegate to use the whole object as the value
    $ElementDelegate = [system.Func[Object]] { $args[0] }
    # Create and return the lookup table using Linq
    $lookup = [system.Linq.Enumerable]::ToLookup($Repo, $HashDelegate,$ElementDelegate)
    [Linq.Enumerable]::ToArray($lookup)
}

# Main script

# Get the paths of the two repositories to compare
$repoPath1 = 'D:\Project Shelf\PowerShellProjectFolder\scripts'
$repoPath2 = 'D:\Project Shelf\PowerShellProjectFolder'

# Get the info of each repository using Get-RepoInfo function
$repo1 = Get-RepoInfo -RepoPath $repoPath1
$repo2 = Get-RepoInfo -RepoPath $repoPath2

# Define the result delegate to format the output of Join-Repos function
$resultDelegate = [System.Func[Object,Object,string]] { '{0} x_x {1}' -f $args[0].absolute, $args[1].absolute }

# Join the two repositories using Join-Repos function and store the output in an array
$OutputArray = Join-Repos -Repo1 $repo1 -Repo2 $repo2 -ResultDelegate $resultDelegate

# Create a lookup table for each repository using Lookup-Repo function
$lookup1 = Lookup-Repo -Repo $repo1
$lookup2 = Lookup-Repo -Repo $repo2

# Display the results
Write-Output "Output array:"
$OutputArray

Write-Output "Lookup table 1:"
$lookup1

Write-Output "Lookup table 2:"
$lookup2

