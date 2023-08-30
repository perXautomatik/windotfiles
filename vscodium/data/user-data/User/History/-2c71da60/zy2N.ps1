# Define the parameters for the script
param(
    [Parameter(Mandatory=$true)]
    [string[]]$FilePaths, # A list of file paths to process
    [Parameter(Mandatory=$true)]
    [int]$ChunkSize, # The number of lines in each chunk
    [Parameter(Mandatory=$false)]
    [string]$OutputPath # The path to save the graph relationships as CSV files
)

# Import the required modules
Import-Module Microsoft.PowerShell.Utility
Import-Module Microsoft.PowerShell.GraphicalTools

# Define a function to chunk the content of a file into a set of lines
function Chunk-File {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath, # The path of the file to chunk
        [Parameter(Mandatory=$true)]
        [int]$ChunkSize # The number of lines in each chunk
    )

    # Read the file content as an array of lines
    $FileContent = Get-Content -Path $FilePath

    # Initialize an empty array to store the chunks
    $Chunks = @()

    # Loop through the file content and create chunks
    for ($i = 0; $i -lt $FileContent.Count; $i += $ChunkSize) {
        # Get a subset of lines from the file content
        $Lines = $FileContent[$i..($i + $ChunkSize - 1)]

        # Join the lines into a single string
        $Chunk = $Lines -join "`n"

        # Add the chunk to the array
        $Chunks += $Chunk
    }

    # Return the array of chunks
    return $Chunks
}

# Define a function to calculate an identifying hash of the lines in each chunk
function Hash-Chunk {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Chunk, # The chunk to hash
        [Parameter(Mandatory=$true)]
        [string]$FilePath, # The path of the file that contains the chunk
        [Parameter(Mandatory=$false)]
        [hashtable]$MetadataTable # The table to store the metadata of the file and chunk
    )

    # Calculate a SHA256 hash of the chunk using .NET methods
    $Hasher = [System.Security.Cryptography.SHA256]::Create()
    $Bytes = [System.Text.Encoding]::UTF8.GetBytes($Chunk)
    $HashBytes = $Hasher.ComputeHash($Bytes)
    $HashString = [System.BitConverter]::ToString($HashBytes).Replace("-","")

    # Generate a unique identifier for the file using .NET methods
    $FileId = [System.Guid]::NewGuid().ToString()

    # Store the metadata of the file and chunk in the table using a custom object
    $MetadataObject = New-Object -TypeName PSObject -Property @{
        FileId = $FileId
        FilePath = $FilePath
        ChunkHash = $HashString
        ChunkContent = $Chunk
    }
    
    if ($MetadataTable.ContainsKey($FileId)) {
        # If the file id already exists in the table, append the metadata object to the existing array
        $MetadataTable[$FileId] += $MetadataObject
    }
    else {
        # If the file id does not exist in the table, create a new array with the metadata object
        $MetadataTable[$FileId] = @($MetadataObject)
    }

    # Return the hash string and the file id as a tuple
    return ($HashString, $FileId)
}

# Define a function to insert the chunk identifiers into the graph as nodes and create relationships between them
function Graph-Chunk {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ChunkHash, # The hash of the chunk to graph
        [Parameter(Mandatory=$true)]
        [string]$FileId, # The id of the file that contains the chunk to graph
        [Parameter(Mandatory=$false)]
        [hashtable]$GraphTable # The table to store the graph nodes and edges as custom objects
    )

    # Check if the chunk hash already exists as a node in the graph table
    if ($GraphTable.ContainsKey($ChunkHash)) {
        # If it does, get the existing node object from the table
        $NodeObject = $GraphTable[$ChunkHash]
        
        # Check if the file id is already associated with the node object
        if ($NodeObject.FileIds -contains $FileId) {
            # If it is, do nothing (the node and edge already exist)
            return 
        }
        else {
            # If it is not, add it to the node object's file ids array 
            $NodeObject.FileIds += $FileId

            # Create a new edge object with a strong relationship between the node and the file id
            $EdgeObject = New-Object -TypeName PSObject -Property @{
                Source = $ChunkHash
                Target = $FileId
                Weight = 1 # A strong relationship has a weight of 1
            }

            # Add the edge object to the node object's edges array
            $NodeObject.Edges += $EdgeObject
        }
    }
    else {
        # If it does not, create a new node object with the chunk hash and the file id
        $NodeObject = New-Object -TypeName PSObject -Property @{
            Id = $ChunkHash
            FileIds = @($FileId)
            Edges = @()
        }

        # Create a new edge object with a strong relationship between the node and the file id
        $EdgeObject = New-Object -TypeName PSObject -Property @{
            Source = $ChunkHash
            Target = $FileId
            Weight = 1 # A strong relationship has a weight of 1
        }

        # Add the edge object to the node object's edges array
        $NodeObject.Edges += $EdgeObject

        # Add the node object to the graph table with the chunk hash as the key
        $GraphTable[$ChunkHash] = $NodeObject
    }

    # Loop through all the other nodes in the graph table
    foreach ($OtherNode in $GraphTable.Values) {
        # Check if the other node is different from the current node and has a common file id with it
        if ($OtherNode.Id -ne $NodeObject.Id -and ($OtherNode.FileIds | Where-Object { $_ -in $NodeObject.FileIds })) {
            # If it does, create a new edge object with a weak relationship between the two nodes
            $EdgeObject = New-Object -TypeName PSObject -Property @{
                Source = $NodeObject.Id
                Target = $OtherNode.Id
                Weight = 0.5 # A weak relationship has a weight of 0.5
            }

            # Add the edge object to both nodes' edges arrays, if it does not already exist
            if ($NodeObject.Edges | Where-Object { $_.Source -eq $EdgeObject.Source -and $_.Target -eq $EdgeObject.Target }) {
                # Do nothing (the edge already exists)
            }
            else {
                # Add the edge to the node object's edges array
                $NodeObject.Edges += $EdgeObject
            }

            if ($OtherNode.Edges | Where-Object { $_.Source -eq $EdgeObject.Source -and $_.Target -eq $EdgeObject.Target }) {
                # Do nothing (the edge already exists)
            }
            else {
                # Add the edge to the other node's edges array
                $OtherNode.Edges += $EdgeObject
            }
        }
    }
}

# Initialize an empty table to store the metadata of the files and chunks
$MetadataTable = @{}

# Initialize an empty table to store the graph nodes and edges
$GraphTable = @{}

# Loop through each file path in the input list
foreach ($FilePath in $FilePaths) {
    # Check if the file path is valid and exists
    if (Test-Path -Path $FilePath) {
        # If it is, chunk the file content into a set of lines using the chunk size parameter
        $Chunks = Chunk-File -FilePath $FilePath -ChunkSize $ChunkSize

        # Loop through each chunk in the array of chunks
        foreach ($Chunk in $Chunks) {
            # Hash the chunk and get its hash string and file id using the metadata table parameter
            ($ChunkHash, $FileId) = Hash-Chunk -Chunk $Chunk -FilePath $FilePath -MetadataTable $MetadataTable

            # Graph the chunk and create relationships between nodes using the graph table parameter 
            Graph-Chunk -ChunkHash $ChunkHash -FileId $FileId -GraphTable $GraphTable 
        }
    }
    else {
        # If it is not, write an error message and continue to the next file path
        Write-Error "The file path '$FilePath' is invalid or does not exist."
    }
}

# Check if an output path parameter is provided 
if ($OutputPath) {
    # If it is, save the graph relationships as CSV files for Gephi to import

    # Create an empty array to store the nodes as custom objects with id and label properties 
    $NodesArray = @()

    # Loop through each node in the graph table 
    foreach ($Node in $GraphTable.Values) {
        # Create a new node object with its id and label properties 
        $NodeObject = New-Object -TypeName PSObject -Property @{
            Id = $Node.Id 
            Label = "Chunk: $($Node.Id)"
        }

        # Add the node object to the nodes
