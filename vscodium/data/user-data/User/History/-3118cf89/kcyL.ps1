# source https://stackoverflow.com/a/73343519
<#

#Usage example:

$JSON = Get-Content "C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks" -Raw | ConvertFrom-Json

# Unroll the JSON
$flatJSON = $JSON | Expand-Json   

# Filter by path - this outputs an array
$filteredJSON = $flatJSON | Where-Object Path -like 'data.b<*>.bData.bAbc<0>.bAbcZ'

# Convert data back to JSON string
$filteredJSON.Value | ConvertTo-Json

#>

Function Expand-Json {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)] $InputObject,
        [Parameter()] [string] $Path,
        [Parameter()] [string] $PathSeparator = '.',
        [Parameter()] [string] $IndexFormat = '<{0}>'
    )
    
    process {       
        if( $InputObject -is [Collections.IList] ) {
            # Iterate over array elements
            $i = 0
            foreach( $item in $InputObject ) {

                # Full path of current array item
                $itemPath = $Path + ($IndexFormat -f $i++)

                # Output current array item with path
                [PSCustomObject]@{ Path = $itemPath; Value = $item }

                if( $item -is [PSCustomObject] -or $item -is [Collections.IList] ) {
                    # Recurse into child container
                    Expand-Json -InputObject $item -Path $itemPath -PathSeparator $PathSeparator -IndexFormat $IndexFormat
                }
            }
        }
        elseif( $InputObject -is [PSCustomObject] ) {
            # Iterate over properties
            foreach( $prop in $InputObject.PSObject.Properties ) {

                # Full path of the current property
                $propertyPath = if( $Path ) { $Path, $prop.Name -join $PathSeparator } else { $prop.Name }

                # Output current property with path
                [PSCustomObject]@{ Path = $propertyPath; Value = $prop.Value }

                if( $prop.Value -is [PSCustomObject] -or $prop.Value -is [Collections.IList] ) {
                    # Recurse into child container
                    Expand-Json -InputObject $prop.Value -Path $propertyPath -PathSeparator $PathSeparator -IndexFormat $IndexFormat
                }
            }
        }
    }
}

#Usage example:

$inputPath = "C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"
$JSON = Get-Content $inputPath -Raw | ConvertFrom-Json

# Unroll the JSON
$flatJSON = $JSON | Expand-Json   

$flatJSON | ConvertTo-Csv | Out-File -FilePath "$inputPath.csv"
