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
	[Parameter()] [string] $IndexFormat = '[{0}]'
    )

    process {

        if( $InputObject -is [Collections.IList] ) {
	        # Iterate over array elements
	        $i = 0
	        foreach( $item in $InputObject ) {
	            $itemPath = $Path + ($IndexFormat -f $i++) # Full path of current array item
                
	            propOrRecurse $item $itemPath $InputObject
	        }
        }
        elseif( $InputObject -is [PSCustomObject] ) {
	        # Iterate over properties
	        foreach( $prop in $InputObject.PSObject.Properties ) {
		        $propertyPath = if( $Path ) { $Path, $prop.Name -join $PathSeparator } else { $prop.Name } # Full path of the current property

		        propOrRecurse $prop.value $propertyPath $InputObject
	        }
        }
    }
}
function propOrRecurse($propxValue,$propertyPathx,$InputObjectx)
{
    if( $propxValue -is [PSCustomObject] -or $propxValue -is [Collections.IList] ) {
	# Recurse into child container
	    Expand-Json -InputObject $propxValue -Path $propertyPathx -PathSeparator $PathSeparator -IndexFormat $IndexFormat
    } else # Output current property with path
    {
        
    	    [PSCustomObject]@{ Path = ,$propertyPathx; Value = $propxValue }
        
    }

}

cls
#Usage example:

$inputPath = "C:\Users\chris\AppData\Roaming\Opera Software\Opera GX Stable\_side_profiles\a_Theater\Bookmarks"
$JSON = Get-Content $inputPath -Raw | ConvertFrom-Json

# Unroll the JSON
$flatJSON = $JSON | Expand-Json

add-type -Path "C:\Program Files\PackageManagement\NuGet\Packages\chilkat-x64.9.5.0.93\lib\net47\ChilkatDotNet47.dll"

#build your json from paths

$json = New-Object Chilkat.JsonObject

Set-Alias -Name jq -Value 'Z:\PortableApplauncher\AppManager\.free\Beyond Compare 4\Helpers\JSON\jq64.exe'

$flatJSON |
 select -First 10 | 
 % {

 $json.UpdateString($_.path,$_.value) 
 
 }

$regex = "([:,{}\[])"
$json.EmitCompact = 0;

$json.toString() >"$inputPath.bxy"



$r = $json.ToString() -replace $regex, '$1 `n'





#-replace(",",", ")  -replace("{","{ ")-replace("\[","[ ") 
 
 
 $r  >"$inputPath.bxy"

$qq = "cd Z:\PortableApplauncher\AppManager\.free && cd Beyond Compare 4  && Helpers\JSON\JSON_tidied.bat"
$Arg1 = """"+"$inputPath.bxy"+""""
$Arg2 = """"+"$inputPath.bxx"+""""
$k = "/k cd Z:\PortableApplauncher\AppManager\.free && cd Beyond Compare 4  && Helpers\JSON\JSON_tidied.bat " + $Arg1 + " " + $Arg2 

# start-process cmd.exe -ArgumentList "/k", $qq, $Arg1, $Arg2


#mv -Path $inputPath "$inputPath.bx" 
#$JSON.ToString() | Out-File $inputPath 