<# .SYNOPSIS
Converts a string array of key-value pairs into a PowerShell custom object.

        .DESCRIPTION
        This function takes an array of strings containing key-value pairs as a parameter, and returns an array of custom objects with properties corresponding to the keys and values. The function uses the ConvertFrom-StringData cmdlet to parse the key-value pairs, and then creates custom objects with the properties.

.PARAMETER KeyPairStrings
An array of strings that contain key-value pairs separated by a delimiter.
.PARAMETER Delim
The delimiter that separates the key and value in each string. The default is '='.
.EXAMPLE
PS C:\> "name=John","age=25" | keyPairTo-PsCustom
name age
---- ---
John 25
.EXAMPLE
PS C:\> keyPairTo-PsCustom -KeyPairStrings "color:blue","size:large" -Delim ':'
color size
----- ----
blue  large
#>
function keyPairTo-PsCustom {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$KeyPairStrings,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Delim = '='
    )
    begin {
        # Check if the delimiter exists in the input array
        if (-not ($KeyPairStrings -match $Delim)) {
            Write-Error "Delimiter '$Delim' not found in the input array."
            return $null
        }
    }
    process {
        # Convert each string into a JSON object and merge them into one object
        $JsonObject = $KeyPairStrings | ForEach-Object {
            try {
                # Split the string by the delimiter and trim the whitespace
                $Key, $Value = $_ -split $Delim | ForEach-Object { $_.Trim() }
                # Create a JSON object with the key and value
                ConvertTo-Json -InputObject @{ $Key = $Value } -Compress
            }
            catch {
                # Handle any errors during the conversion
                Write-Error "Failed to convert '$_' to a JSON object: $($_.Exception.Message)"
                return $null
            }
        } | Join-String -Separator ',' -Prefix '{' -Suffix '}'
        # Convert the JSON object into a PowerShell custom object and output it
        try {
            ConvertFrom-Json -InputObject $JsonObject
        }
        catch {
            # Handle any errors during the conversion
            Write-Error "Failed to convert '$JsonObject' to a PowerShell custom object: $($_.Exception.Message)"
            return $null
        }
    }
}
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
        $dd = $KeyPairStrings | ConvertTo-Json
        
        # Loop through each element in the array using a for loop
for ($i = 0; $i -lt $KeyPairStrings.Length; $i++) {
    # Get the current element from the array by its index
    $d = $KeyPairStrings[$i] -split " "
    
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