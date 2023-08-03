<#
.SYNOPSIS
Creates a custom object of type match.range and updates its type data.

.DESCRIPTION
This script creates a custom object of type match.range with three properties: match, value, and linenumber. It then updates the type data of the match.range type to specify the default display property set and a script property that returns the upper case value. It also defines a function that accepts a match.range object as a parameter and outputs its upper case value.

.PARAMETER Match
The match property of the custom object. This parameter is mandatory and cannot be null or empty.

.PARAMETER Value
The value property of the custom object. This parameter is mandatory and cannot be null or empty.

.PARAMETER LineNumber
The linenumber property of the custom object. This parameter is optional and defaults to 1.

.EXAMPLE
.\script.ps1 -Match "a" -Value "b"

This example creates a custom object of type match.range with match "a" and value "b" and outputs its properties and upper case value.
#>
param (
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Match,

    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Value,

    [Parameter()]
    [int]$LineNumber = 1
)

try {
    # Create a custom object of type match.range with the given properties
    $q = [PSCustomObject]@{
        PSTypeName = 'match.range' #give the object a type name
        match = $Match 
        value = $Value 
        linenumber = $LineNumber 
    }

    # Update the type data of the match.range type to specify the default display property set
    $TypeData = @{
        TypeName = 'match.range' #refere to object by it's type name
        DefaultDisplayPropertySet = 'match','value'
    }

    Update-TypeData @TypeData

    # Output the custom object
    $q

    # Update the type data of the match.range type to add a script property that returns the upper case value
    $typedata = @{
        TypeName = 'match.range' # not PstypeName...
        MemberType = 'ScriptProperty'
        MemberName = 'UpperCaseName'
        Value = {$this.value.toUpper()}
    }

    Update-TypeData @TypeData

    # Output the upper case value
    $q.UpperCaseName

    # Define a function that accepts a match.range object as a parameter and outputs its upper case value
    function abc(){
        param( 
            [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [PSTypeName('match.range')]$Data # throws validation error if not correct type name
        )
    
        $data.UpperCaseName
    }

    # Call the function with the custom object as an argument
    abc -Data $q
}
catch {
    # Write an error message and exit
    Write-Error "Failed to create or update custom object: $_"
    exit 1
}
