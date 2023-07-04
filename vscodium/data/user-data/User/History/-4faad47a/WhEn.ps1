
# This function takes an array of objects and splits it into smaller chunks of a given size
# It also executes a script block on each chunk if provided
function Split-Array
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true,
                   ValueFromPipeline = $true,
                   ValueFromPipelineByPropertyName = $true)] [object[]] $InputObject,
        [Parameter()] [scriptblock] $Process,
        [Parameter()] [int] $ChunkSize
    )

    Begin { #run once
        # Initialize an empty array to store the chunks
        $cache = @();
        # Initialize an index to keep track of the chunk size
        $index = 0;
    }
    Process { #run each entry

        if($cache.Length -eq $ChunkSize) {
            # if the cache array is full, send it out to the pipe line
            write-host '{'  –NoNewline
            write-host $cache –NoNewline
            write-host '}'

            # Then we add the current pipe line object to the cache array and reset the index
            $cache = @($_);
            $index = 1;
        }
        else {
            # Otherwise, we append the current pipe line object to the cache array and increment the index
            $cache += $_;
            $index++;
        }

      }
    End { #run once
        # Here we check if there are any remaining objects in the cache array, if so, send them out to pipe line
        if($cache) {
            Write-Output ($cache );
        }
    }
}

# This function parses the output of git ls-tree and converts it into a custom object with properties
function Parse-LsTree
{

    [CmdletBinding()]
       param(
            # The script or file path to parse
            [Parameter(Mandatory, ValueFromPipeline)]                        
            [string[]]$LsTree
        )
        process {
            # Extract the blob type from the input string
            $blobType = $_.substring(7,4)
            # Set the starting positions of the hash and relative path based on the blob type
            $hashStartPos = 12
            $relativePathStartPos = 53

            if ($blobType -ne 'blob')
                {
                $hashStartPos+=2
                $relativePathStartPos+=2
                } 

            # Create a custom object with properties for unknown, blob, hash and relative path
            [pscustomobject]@{unkown=$_.substring(0,6);blob=$blobType; hash=$_.substring($hashStartPos,40);relativePath=$_.substring($relativePathStartPos)} 
     
     } 
}

# This function lists the duplicate object hashes in a git repository using git ls-tree and Parse-LsTree functions
function List-Git-DuplicateHashes
{
    param([string]$path)
    # Save the current working directory
    $current = $PWD

    # Change to the given path
    cd $path

    # Use git ls-tree to list all the objects in the HEAD revision
    git ls-tree -r HEAD |
    # Parse the output using Parse-LsTree function
    Parse-LsTree |
            # Group the objects by hash and filter out the ones that have only one occurrence 
            Group-Object -Property hash |
            ? { $_.count -ne 1 } | 
            # Sort the groups by count in descending order
                Sort-Object -Property count -Descending

    # Change back to the original working directory            
    cd $current
 }               

# This function adds an index property to each object in an array using a counter variable 
function Add-Index { #https://stackoverflow.com/questions/33718168/exclude-index-in-powershell
   
    begin {
        # Initialize the counter variable as -1
        $i=-1
    }
   
    process {
        if($_ -ne $null) {
        # Increment the counter variable and add it as an index property to the input object 
        Add-Member Index (++$i) -InputObject $_ -PassThru
        }
    }
}

# This function displays the indexed groups of duplicate hashes in a clear format 
function Show-Duplicates
{    
    [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )

     Clear-Host
     Write-Host "================ k for keep all ================"
                 

    # Add an index property to each group using Add-Index function 
    $indexed = ( $input |  %{$_.group} | Add-Index )
            
    # Display the index and relative path of each group and store the output in a variable 
    $indexed | Tee-Object -variable re |  
    % {
        $index = $_.index
        $relativePath = $_.relativePath 
        Write-Host "$index $relativePath"
    }

    # Return the output variable 
    $re
}

# This function allows the user to choose which duplicate hashes to keep or delete 
function Choose-Duplicates
{  
 [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )
       # Split the input array into smaller chunks using Split-Array function 
       $options = $input | %{$_.index} | Split-Array 
       # Prompt the user to choose from the alternatives and store the input in a variable 
       $selection = Read-Host "choose from the alternativs " ($input | measure-object).count
       # If the user chooses to keep all, return nothing 
       if ($selection -eq 'k' ) {
            return
        } 
        else {
            # Otherwise, filter out the objects that have the same index as the selection and store them in a variable 
            $q = $input | ?{ $_.index -ne $selection }
        } 
    
       # Return the filtered variable 
       $q
}

# This function deletes the chosen duplicate hashes using git rm command 
function Delete-Duplicates
{  
 [cmdletbinding()]
    param(                 
        [parameter(ValueFromPipeline)]
        [ValidateNotNullOrEmpty()] 
        [object[]] $input
    )
    if($input -ne $null)
    {

       # Split the input array into smaller chunks using Split-Array function 
       $toDelete = $input | %{$_.relativepath} | Split-Array 
       
       # For each chunk, use git rm to delete the files 
       $toDelete | % { git rm $_ } 

       # Wait for 2 seconds before proceeding 
       sleep 2
    }
}

                     
                
# Use List-Git-DuplicateHashes function to list the duplicate hashes in a given path and pipe them to Show-Duplicates function 
 list-git-DuplicateHashes -path 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\SubProjects\Kvutsokning' | 
 #select -first 1 | 
 % { $_ | Show-Duplicates | Choose-Duplicates | Delete-Duplicates }