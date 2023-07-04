# A function that parses the output of git ls-tree command and returns a custom object with properties
function Parse-GitLsTreeOutput
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTreeOutput
        )
        process {
            # Extract the blob type from the output line
            $blobType = $_.substring(7,4)
            # Set the hash start position based on the blob type
            $hashStartPos = 12
            if ($blobType -ne 'blob') { $hashStartPos+=2 } 
            # Set the relative path start position based on the blob type
            $relativePathStartPos = 53
            if ($blobType -ne 'blob') { $relativePathStartPos+=2 } 
            # Create a custom object with properties for unknown, blob, hash and relative path
            [pscustomobject]@{unknown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     
     } 
}

# A function that resolves the absolute path of a file from its relative path
function Resolve-AbsolutePath
{
    param(
        [Parameter(Mandatory)]
        [string]$RelativePath
    )
    # Escape the backslash character for regex matching
    $backslash = [regex]::escape('\')
    # Define a regex pattern for matching octal escape sequences in the relative path
    $octalPattern = $backslash+'\d{3}'+$backslash+'\d{3}'
    # Trim the double quotes from the relative path
    $relativePath =  $RelativePath.Trim('"')
    # Try to resolve the relative path to an absolute path
    $absolutePath = Resolve-Path $relativePath -ErrorAction SilentlyContinue  
    # If the absolute path is not found and the relative path contains octal escape sequences, try to resolve it with wildcard matching
    if(!$absolutePath -and $relativePath -match ($octalPattern))
    { 
       $absolutePath = Resolve-Path  (($relativePath -split($octalPattern) ) -join('*')) 
    }
    # Return the absolute path or null if not found
    return $absolutePath     
}

# A function that takes a collection of parsed git ls-tree output objects and adds more properties to them such as absolute path, file name and parent folder
function Add-MorePropertiesToGitLsTreeOutput
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$GitLsTreeOutputObjects
    )
    # For each object in the collection, add more properties using calculated expressions
    $GitLsTreeOutputObjects | Select-Object -Property *,@{Name = 'absolute'; Expression = {Resolve-AbsolutePath $_.relativePath}},@{Name = 'FileName'; Expression = {$path = $_.absolute;$filename = [System.IO.Path]::GetFileNameWithoutExtension("$path");if(!($filename)) { $filename = [System.IO.Path]::GetFileName("$path") };$filename}},@{Name = 'Parent'; Expression = {Split-Path -Path $_.relativePath}}
}

# A function that joins two collections of parsed git ls-tree output objects based on their file names and returns a custom object with properties for hash and absolute paths of both collections
function Join-GitLsTreeOutputCollectionsByFileName
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$Collection1,
        [Parameter(Mandatory)]
        [psobject[]]$Collection2
    )
    # Define a delegate function that returns the file name of an object as the join key
    $KeyDelegate = [System.Func[Object,string]] {$args[0].FileName}
    # Define a delegate function that returns a custom object with properties for hash and absolute paths of both collections as the join result
    $resultDelegate = [System.Func[Object,Object,Object]]{ 
                    param ($x,$y);
                    
                    New-Object -TypeName PSObject -Property @{
                    Hash = $x.hash;
                    AbsoluteX = $x.absolute;
                    AbsoluteY = $y.absolute
                    }
                }
    
    # Use LINQ Join method to join the two collections by file name and return an array of custom objects as the result
    $joinedDataset = [System.Linq.Enumerable]::Join( $Collection1, $Collection2, #tableReference
        
                                                     $KeyDelegate,$KeyDelegate, #onClause
                
                                                     $resultDelegate
    )
    $OutputArray = [System.Linq.Enumerable]::ToArray($joinedDataset)

    return $OutputArray
}

# A function that creates a lookup table from a collection of parsed git ls-tree output objects based on their hash values
function Create-LookupTableByHash
{
    param(
        [Parameter(Mandatory)]
        [psobject[]]$GitLsTreeOutputObjects
    )
    # Define a delegate function that returns the hash value of an object as the lookup key
    $HashDelegate = [system.Func[Object,String]] { $args[0].hash }
    # Define a delegate function that returns the object itself as the lookup element
    $ElementDelegate = [system.Func[Object]] { $args[0] }
    # Use LINQ ToLookup method to create a lookup table from the collection by hash value and return an array of lookup groups as the result
    $lookup = [system.Linq.Enumerable]::ToLookup($GitLsTreeOutputObjects, $HashDelegate,$ElementDelegate)

    return [Linq.Enumerable]::ToArray($lookup)
}

# Save the current location
Push-Location

# Change to the first repository location
cd 'D:\Project Shelf\PowerShellProjectFolder\scripts'

# Parse the output of git ls-tree command and add more properties to the objects
$repo1 = git ls-tree -r HEAD  | Parse-GitLsTreeOutput  | Add-MorePropertiesToGitLsTreeOutput

# Change to the second repository location
cd 'D:\Project Shelf\PowerShellProjectFolder'

# Parse the output of git ls-tree command and add more properties to the objects
$repo2 = git ls-tree -r HEAD  | Parse-GitLsTreeOutput  | Add-MorePropertiesToGitLsTreeOutput

# Select the first object from the first repository for testing
$repo1 | select -First 1

# Join the two collections by file name and get the result array
$joinedResult = Join-GitLsTreeOutputCollectionsByFileName $repo1 $repo2

# Create a lookup table by hash from the first collection and get the result array
$lookupResult = Create-LookupTableByHash $repo1

# Restore the original location
Pop-Location

