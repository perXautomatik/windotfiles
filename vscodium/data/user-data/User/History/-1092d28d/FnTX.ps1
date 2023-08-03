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

        # Create an array to store the results
        $results = [ordered]@{}

        # Loop through each string in the array
        foreach ($string in $KeyPairStrings) {
            # Try to parse the key-value pairs using ConvertFrom-StringData cmdlet
            try {
                $q = ConvertFrom-StringData $string 
                
                $results= $data.Values[0]
            }
            catch {
                Write-Error "Could not parse the string: $_"
                continue
            }

            # Add the result to the array
            
        }
        # Create a custom object with properties from the data hashtable
        
        # Return the array of results
        return  New-Object -TypeName PSObject -Property $result
    }