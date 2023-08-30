<#
.SYNOPSIS
Splits the text of a file by a regular expression and returns an array of custom objects.

.DESCRIPTION
This function splits the text of a file by a regular expression and returns an array of custom objects. Each object represents a text range that starts with a line that matches the regular expression and ends with the line before the next match or the end of the file. Each object has three properties: match, value and linenumber. The match property is the line that matches the regular expression, the value property is an array of lines that follow the match, and the linenumber property is an array of line numbers that correspond to the value property.

.PARAMETER Path
The path of the file to split.

.PARAMETER Regx
The regular expression to use for splitting.
#>
function Split-TextByRegex {
    param(
        # Validate that the path parameter is not null or empty and points to an existing file
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]
        $Path,

        # Validate that the regx parameter is not null or empty and is a valid regular expression
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({[regex]::new($_)})]
        [string]
        $Regx
    )

    # Get the content of the file as an array of strings
    $input = Get-Content -Path $Path

    # Append the line number to each line as a custom object
    $lineNrAppended = $input | Select-String -Pattern '.*' | Select-Object LineNumber, Line

    # Get the total number of lines in the file
    $endOfFile = $input.Length

    # Find all the lines that match the regular expression and store them as an array of custom objects
    $Delimeters = @($lineNrAppended | Where-Object { $_ -match $Regx })

    # Initialize an empty array for the result
    $TextRange = @()

    # Loop through each delimiter in the array
    for ($i = 0; $i -lt $Delimeters.length; $i++) {

        # Get the line number of the next delimiter or use the end of file as the upper bound
        $upper = ( $Delimeters | Select-Object -Index ($i+1) ).LineNumber - 1

        if ($upper -eq -1 ) { $upper = $endOfFile }

        # Get all the lines between the current delimiter and the upper bound as an array of custom objects
        $q = ($lineNrAppended | Where-Object { $_.lineNumber -in (( $Delimeters | Select-Object -Index $i ).LineNumber .. $upper) })

        # Create a custom object with match, value and linenumber properties and add it to the result array
        $TextRange += , [PSCustomObject]@{
            PSTypeName = 'match.range' #give the object a type name
            match = $q.line[0] ; value = @($q.line | Select-Object -Skip 1) ; linenumber = $q.lineNumber 
        }
    }

    # Check if there is already a type data for match.range objects and update it if not
    if (!(Get-TypeData -TypeName 'match.range').defaultDisplayPropertySet) {
        $TypeData = @{
            TypeName = 'match.range' #refere to object by it's type name
            DefaultDisplayPropertySet = 'match','value'
        }
        Update-TypeData @TypeData
    }

    # Return the result array as output
    return  $TextRange
}
