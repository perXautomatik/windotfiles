<#
.SYNOPSIS
Finds and deletes duplicate files in a sorted list.

.DESCRIPTION
This function finds and deletes duplicate files in a sorted list of custom objects. Each object has three properties: size, name and path. The function groups the objects by size and name, filters out the ones that have unique size or name, and compares the paths of the remaining ones. The function uses a delegate function to decide which file to delete based on some criteria. The function also outputs a list of truth statements that indicate which files are the same with different parent directories.

.PARAMETER Initial
The sorted list of custom objects that represent the files.

.PARAMETER DeleteDelegate
The delegate function that decides which file to delete.
#>
function Remove-DuplicateFiles {
    param(
        # Validate that the Initial parameter is not null or empty and is an array of custom objects
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -is [object[]]})]
        [object[]]
        $Initial,

        # Validate that the DeleteDelegate parameter is not null or empty and is a script block
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({$_ -is [scriptblock]})]
        [scriptblock]
        $DeleteDelegate
    )

    # Group the initial list by size and store it as an array of custom objects
    $gS = $Initial | Group-Object -Property size | ForEach-Object {
        [PSCustomObject]@{
            count = $_.Count
            size = $_.Name
            name = $_.Group.name
            path = $_.Group.path
        }
    }

    # Define a label for filtering the list by size
    filterStart:

    # Loop through each item in the list by size
    foreach ($gr in $gS) {
        
		# Check if the item has only one file with the same size
		
		if ($gr.count -eq 1) {
			
			# Delete the item from the list
			
			$gS = $gS | Where-Object { $_ -ne $gr }
			
		}
		
		else {
			
			# Loop through each file in the item
			
			foreach ($g in $gr) {
				
				# Get the other files in the item that have different paths
				
				$other = $gr | Where-Object { $_.path -ne $g.path }
				
				# Check if the file path is a substring of any other file path
				
				if ($g.path -in $other.path) {
					
					# Call the delegate function to decide which file to delete
					
					& $DeleteDelegate -a $g -b $other
					
					# Go back to the filter label
					
					goto filterStart
					
				}
				
			}
			
		}
		
	}

    # Group the list by name and store it as an array of custom objects
    $gSn = $gS | Group-Object -Property name | ForEach-Object {
        [PSCustomObject]@{
            count = $_.Count
            name = $_.Name
            path = $_.Group.path
        }
    }

    # Define a recursive function to group the list by parent directories at different levels
    function Group-By-Parent {
        param(
            [object[]]$Root, # The list of custom objects to group by parent directories
            [int]$Index # The level of parent directories to group by
        )

        # Check if the index is greater than the number of parent directories for any item in the list
        if ($Index -gt ($Root | ForEach-Object { Split-Path -Path $_.path -Parent }).Length) {
            # Return the list as output
            return $Root
        }
        else {
            # Group the list by parent directories at the given index and store it as an array of custom objects
            $grouped = $Root | Group-Object -Property @{Expression = { (Split-Path -Path $_.path -Parent)[$Index] }} | ForEach-Object {
                [PSCustomObject]@{
                    count = $_.Count
                    index = $Index + 1 # Increment the index for the next level of grouping
                    parents = $_.Name # Store the parent directory as a property
                    path = $_.Group.path 
                }
            }
            # Call the recursive function on each item in the grouped array and return the result as output
            return ($grouped | ForEach-Object { Group-By-Parent -Root $_ -Index $_.index })
        }
    }

    # Call the recursive function on the list by name and store the result as an array of custom objects
    $result = Group-By-Parent -Root $gSn -Index 0

    # Output the result as a list of truth statements
    Write-Host "The truth statements are:"
    Write-Host ($result | Format-List | Out-String)

}



<#given a sorted list of [Initial]{size, name, path}
    group by size => [gS](count,size){name,path}

;filterStart
filter gr in [gs] 
    if count = 1
        delete gr
    else 
        for each g in gr
            gr excluding g => [other] 
             if g.path in [other].path 
                deleteDelegate(a,b)
                goto ;filterStart
              
group [gS] by name => [gSn](count,name){path}


recursive on [root][Index] => [ressult]
    while index > getParents().length
        for each entry in [gsn] where count > 1
            group by getParents()[Index] => [root](count,index++,{parrents}){path}


deleteDelegate(a,b)
{
    a type requiring obj a, obj b, delgate x <= deciding which to delete

    throw error if a & b still excists    
}

[ressult]

a list of truth statements
objects who are the same with different parrent whos node at index has same name

 obja,[parentId],objb,[parentId]
 obja,[subparentId],objb,[subparentId]
 objc,[parentId],objb,[parentId]


 obja @ c:\temp = objb @ c:\etc\osv\temp
 and
 obja @ c:\ = objb @ c:\etc\osv\
    for every subparent they share

 
ressult can then be consumed 
    group by size or number
        => path = path relationship


into a que of beond compare session files

aditionally could name be replaced with hash, and in the final step, we decouple names being != as a list of translations


            
#>    