<#
.SYNOPSIS
This script creates a JSON object from a list of paths that contain .git folders.

.DESCRIPTION
This script changes the current directory to 'B:\Users\chris\Documents\' and gets all the subfolders that contain .git folders using Get-ChildItem cmdlet. It then selects the full path and depth properties of each folder and sorts them by depth in descending order. It then creates an empty JSON object with a root property and loops through each path in the list. It splits each path by the backslash character and adds each segment as a property to the JSON object, creating nested properties as needed. It finally outputs the JSON object.

.PARAMETER blockcvalue
The value to use for the blockc property in the JSON object.

.EXAMPLE
Create-JsonObject -blockcvalue "some value"

This example creates a JSON object from the list of paths that contain .git folders and uses "some value" as the value for the blockc property.
#>
function Create-JsonObject {
    # Define the parameter for the function
    param (
        # The blockcvalue parameter specifies the value to use for the blockc property in the JSON object
        [Parameter(Mandatory=$true)]
        [string]$blockcvalue
    )

    # Change the current directory to 'B:\Users\chris\Documents\'
    cd 'B:\Users\chris\Documents\'

    # Get all the subfolders that contain .git folders using Get-ChildItem cmdlet with Recurse and Filter parameters
    $list = Get-ChildItem -Recurse -Filter '.git'

    # Select the full path and depth properties of each folder using Select-Object cmdlet with Property and Expression parameters
    # Sort the folders by depth in descending order using Sort-Object cmdlet with Property and Descending parameters
    $q = $list | Select-Object -Property @{name='path'; expression={$_.FullName}}, @{name='depth';expression={$_.path.split('\').Length}} | Sort-Object -Property depth -Descending

    # Create an empty JSON object with a root property using ConvertFrom-Json cmdlet
    $json = @"
{ "root": {} } 
"@
    $jobj = ConvertFrom-Json -InputObject $json

    # Loop through each path in the list using ForEach-Object cmdlet
    $q | ForEach-Object {

        # Split the path by the backslash character and store it in a variable
        $ToBeHashed = $_.path.split('\')

        # Loop through each segment in the variable using a for loop
        for ($i = 0; $i -lt $ToBeHashed.length; $i++){

            # Store the current segment in a variable
            $m = $ToBeHashed[$i]

            # Check if the segment is not null using If statement
            if ($m -ne $null )
            {
                # Check if the segment is not already a property of the JSON object using If statement
                if ($jobj.$m -eq $null )
                {
                    # Add the segment as a property to the JSON object using Add-Member cmdlet with Name, NotePropertyMembers and MemberType parameters
                    $jobj | Add-Member -Name $m -NotePropertyMembers @{}
                }

                # Set the JSON object to be its own property using dot notation
                $jobj = $jobj.$m
            }
        }
        # Add a blockc property to the JSON object with the blockcvalue parameter as its value using Add-Member cmdlet with Name, Value and MemberType parameters
        $jobj | Add-Member -Name "blockc" -Value $blockcvalue -MemberType NoteProperty

    }

    # Output the JSON object using ConvertTo-Json cmdlet
    $jobj | ConvertTo-Json

}