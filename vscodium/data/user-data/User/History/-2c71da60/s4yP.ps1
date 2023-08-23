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

# Define a function to create a node in the graph table with the chunk hash and the file id
function Create-Node {
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
            # If it is, do nothing (the node already exists)
            return 
        }
        else {
            # If it is not, add it to the node object's file ids array 
            $NodeObject.FileIds += $FileId
        }
    }
    else {
        # If it does not, create a new node object with the chunk hash and the file id
        $NodeObject = New-Object -TypeName PSObject -Property @{
            Id = $ChunkHash
            FileIds = @($FileId)
            Edges = @()
        }

        # Add the node object to the graph table with the chunk hash as the key
        $GraphTable[$ChunkHash] = $NodeObject
    }

    # Return the node object
    return $NodeObject
}

# Define a function to create an edge in the graph table between two nodes with a given weight
function Create-Edge {
    param(
        [Parameter(Mandatory=$true)]
        [PSObject]$SourceNode, # The source node of the edge
        [Parameter(Mandatory=$true)]
        [PSObject]$TargetNode, # The target node of the edge
        [Parameter(Mandatory=$true)]
        [double]$Weight # The weight of the edge
    )

    # Create a new edge object with the source, target, and weight properties
    $EdgeObject = New-Object -TypeName PSObject -Property @{
        Source = $SourceNode.Id
        Target = $TargetNode.Id
        Weight = $Weight 
    }

    # Add the edge object to both nodes' edges arrays, if it does not already exist
    if ($SourceNode.Edges | Where-Object { $_.Source -eq $EdgeObject.Source -and $_.Target -eq $EdgeObject.Target }) {
        # Do nothing (the edge already exists)
    }
    else {
        # Add the edge to the source node's edges array
        $SourceNode.Edges += $EdgeObject
    }

    if ($TargetNode.Edges | Where-Object { $_.Source -eq $EdgeObject.Source -and $_.Target -eq $EdgeObject.Target }) {
        # Do nothing (the edge already exists)
    }
    else {
        # Add the edge to the target node's edges array
        $TargetNode.Edges += $EdgeObject
    }
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

    # Create a node in the graph table with the chunk hash and the file id using Create-Node function 
    $NodeObject = Create-Node -ChunkHash $ChunkHash -FileId $FileId -GraphTable $GraphTable

    # Create an edge in the graph table with a strong relationship between the node and the file id using Create-Edge function 
    Create-Edge -SourceNode $NodeObject -TargetNode @{Id = $FileId} -Weight 1

    # Loop through all the other nodes in the graph table
    foreach ($OtherNode in $GraphTable.Values) {
        # Check if the other node is different from the current node and has a common file id with it
        if ($OtherNode.Id -ne $NodeObject.Id -and ($OtherNode.FileIds | Where-Object { $_ -in $NodeObject.FileIds })) {
            # If it does, create an edge in the graph table with a weak relationship between the two nodes using Create-Edge function 
            Create-Edge -SourceNode $NodeObject -TargetNode $OtherNode -Weight 0.5
        }
    }
}
