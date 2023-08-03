  function keyPairTo-PsCustom {
        <#
        .SYNOPSIS
        Converts key-value pairs to custom objects with properties corresponding to the keys and values.

        .DESCRIPTION
        This function takes an array of strings containing key-value pairs as a parameter, and returns an array of custom objects with properties corresponding to the keys and values. The function uses the ConvertFrom-StringData cmdlet to parse the key-value pairs, and then creates custom objects with the properties.

        .PARAMETER KeyPairStrings
        The array of strings containing key-value pairs.

        .EXAMPLE
        keyPairTo-PsCustom -KeyPairStrings @("name=John", "age=25")

        This example converts the key-value pairs in the array to custom objects with properties name and age.
        
        #>

        # Validate the parameter
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$true)]
            [string[]]$KeyPairStrings
        )
        
        $resolved = @();
        
        # Loop through each element in the array using a for loop
for ($i = 0; $i -lt $KeyPairStrings.Length; $i++) {
    # Get the current element from the array by its index
    $d = $KeyPairStrings[$i] | ConvertTo-Csv
    
    # Create a hashtable to store the key-value pairs
    $data = @{}
    
    # Loop through each element in the sub-array using another for loop
    for ($j = 0; $j -lt $d.Length; $j++) {
        # Get the current element from the sub-array by its index
            $c = $d[$j]                
            $data = $data + [hashtable](ConvertFrom-StringData $c)                    

        }

                # Add the result to the array                
            
            $data
            $resolved.Add($data)
        }
            # Create a custom object with properties from the data hashtable
    
    # Return the array of results
    return  $data
}