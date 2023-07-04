# Define a function to prefix the duplicate elements in an array with a number
function PrefixDupes {
    [CmdletBinding()]
    param (
        # The array to process
        [Parameter(Mandatory=$true)]
        [string[]]$Array
    )
    # Add a synopsis comment
    <#
        .SYNOPSIS
        Prefix the duplicate elements in an array with a number.

        .DESCRIPTION
        This function takes an array of strings as input and returns a hashtable with the elements as keys and their indices as values. If an element is duplicated in the array, it is prefixed with a number and a plus sign to make it unique.

        .EXAMPLE
        PrefixDupes -Array @("a","b","c","a","d","b")

        This example returns a hashtable with the following entries:

        Name                           Value
        ----                           -----
        a+1                            0
        b+1                            1
        c                              2
        a+2                            3
        d                              4
        b+2                            5

    #>
    # Create an empty hashtable to store the results
    $ha = @{}

    # Define a recursive function that takes a string as a parameter and adds it to the hashtable with its index as value
    function recursive ($l) {

        # Check if the hashtable does not contain the key $l
        if (!$ha.ContainsKey($l)) {

            # Assign the value of $i to the key $l
            $ha[$l] = $i

        } else {

            # Store the value of $ha[$l] in a variable $q
            $q = $ha[$l]

            # Call the recursive function with a new key "$l+1"
            recursive ("$l+1")

            # Assign the value of $q to the new key "$l+1"
            $ha["$l+1"] = $q

        }
    }

    # Loop through the elements of the array
    for ($i = 0; $i -lt $Array.length; $i++) {

        # Call the recursive function with the element of the array at index $i
        recursive ($Array[$i])
    }

    # Return the hashtable sorted by value
    $ha.GetEnumerator() | Sort-Object Value
}

# Define a function to create a CSV file for the node list from an array of lines
function New-NodeFile {
    [CmdletBinding()]
    param (
        # The array of lines to use as nodes
        [Parameter(Mandatory=$true)]
        [psobject[]]$Lines,
        # The path of the CSV file to create
        [Parameter(Mandatory=$true)]
        [string]$NodeFile,
        # The prefix to add to each node id and label
        [Parameter(Mandatory=$true)]
        [string]$Prefix
    )
    # Add a synopsis comment
    <#
        .SYNOPSIS
        Create a CSV file for the node list from an array of lines.

        .DESCRIPTION
        This function takes an array of lines as input and creates a CSV file with two columns: Id and Label. Each line in the array is used as a node, with its key as Id and its value as Label. A prefix is added to each Id and Label to distinguish them from other nodes.

        .EXAMPLE
        New-NodeFile -Lines (PrefixDupes -Array (Get-Content "file1.txt")) -NodeFile "nodes.csv" -Prefix "1"

        This example creates a CSV file named "nodes.csv" with the following content:

        Id,Label
        1a+1,1a+1_value
        1b+1,1b+1_value
        1c,1c_value
        1a+2,1a+2_value
        1d,1d_value
        1b+2,1b+2_value

    #>
    
    # Create the header for the CSV file
    $nodeHeader = "Id,Label"
    # Write the header to the CSV file
    $nodeHeader | Out-File $NodeFile

    # Loop through each line in the array 
    foreach ($keyvalues in $Lines) {
        
         # Get the label from the line value and add the prefix 
         $label = "$Prefix$keyvalues.value"
         # Get the id from the line key and add the prefix 
         $id = "$Prefix$keyvalues.key"
         # Write the id and label to the CSV file 
         "$id,$label" | Out-File $NodeFile -Append
    }
}

# Define a function to create a CSV file for the edge list from an array of lines
function New-EdgeFile {
    [CmdletBinding()]
    param (
        # The array of lines to use as edges
        [Parameter(Mandatory=$true)]
        [psobject[]]$Lines,
        # The path of the CSV file to create
        [Parameter(Mandatory=$true)]
        [string]$EdgeFile,
        # The prefix to add to each edge source and target
        [Parameter(Mandatory=$true)]
        [string]$Prefix
    )
    # Add a synopsis comment
    <#
        .SYNOPSIS
        Create a CSV file for the edge list from an array of lines.

        .DESCRIPTION
        This function takes an array of lines as input and creates a CSV file with three columns: Source, Target and Type. Each pair of consecutive lines in the array is used as an edge, with the first line as Source and the second line as Target. The Type is set to Directed. A prefix is added to each Source and Target to match the node ids.

        .EXAMPLE
        New-EdgeFile -Lines (PrefixDupes -Array (Get-Content "file1.txt")) -EdgeFile "edges.csv" -Prefix "1"

        This example creates a CSV file named "edges.csv" with the following content:

        Source,Target,Type
        1a+1,1b+1,Directed
        1b+1,1c,Directed
        1c,1a+2,Directed
        1a+2,1d,Directed
        1d,1b+2,Directed

    #>
    
    # Create the header for the CSV file
    $edgeHeader = "Source,Target,Type"
    # Write the header to the CSV file
    $edgeHeader | Out-File $EdgeFile

    # Loop through each pair of consecutive lines in the array 
    for ($i = 0; $i -lt ($Lines.Count - 1); $i++) {
        
         # Get the source from the first line key and add the prefix 
         $source = "$Prefix$($Lines[$i].key)"
         # Get the target from the second line key and add the prefix 
         $target = "$Prefix$($Lines[$i+1].key)"
         # Write the source, target and type to the CSV file 
         "$source,$target,Directed" | Out-File $EdgeFile -Append
    }
}

# Main script

# Define the names of the two files to compare
$importFolder = "B:\PF\Gephi"
$file1 = "C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket\EverythingToolbar_dodorz.json"
$file2 = "C:\ProgramData\scoop\buckets\anderlli0053_DEV-tools\bucket\EverythingToolbar.json"

# Read the lines of the text files and store them in arrays with prefixes for duplicates
$lines1 = PrefixDupes (Get-Content $file1) 
$lines2 = PrefixDupes (Get-Content $file2) 

# Create a CSV file for the node list from each array with different prefixes
New-NodeFile -Lines $lines1 -NodeFile "$importFolder\nodes.csv" -Prefix "1"
New-NodeFile -Lines $lines2 -NodeFile "$importFolder\nodes.csv" -Prefix "2" -Append

# Create a CSV file for the edge list from each array with different prefixes
New-EdgeFile -Lines $lines1 -EdgeFile "$importFolder\edges.csv" -Prefix "1"
New-EdgeFile -Lines $lines2 -EdgeFile "$importFolder\edges.csv" -Prefix "2" -Append

# Import the CSV files into Gephi using the Data Laboratory

