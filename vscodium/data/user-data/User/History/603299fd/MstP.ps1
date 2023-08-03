# Get the folder path from the user input
$folderPath = "B:\PF\NoteTakingProjectFolder"
$folderPath = $folderPath.trim("\\")
install-module pseverything ;
 Import-Module pseverything ; 


# Use Everything to find all folders in the folder path
$filter = '<wholefilename:child:.git file:>|<wholefilename:child:.git folder:>'
$filter = 'folder:'
$folders =  Search-Everything  -PathInclude $folderPath -Filter $filter -global
$folders += $folderPath
# Define a custom comparator that sorts in ascending order by comparing the remainder of dividing by 3
# Define a function to sort a list using insertion sort
function checkPredicate($ax,$bx)
{
    # Check if either parameter is null
    if ($ax -eq $null -or $bx -eq $null) {
        # Return true
        return $false
    }
    # Otherwise, proceed with the original logic
    [string]$current = $ax
    [string]$sortedj = $bx
    [System.Boolean]$conclusion = $current.StartsWith($sortedj) # current starts with sortedj
    return $conclusion
}

function Insertion-Sort {
    param($list)

    $unsorted = $list
    $sortedx = [System.Collections.ArrayList]@()

    $current = "";

    # Loop through the list from the second element
    for ($i = 0; $i -lt $unsorted.Count; $i++) {
        
        # Get the current element
        $current = $unsorted[$i]
                
        if($sortedx.Count -eq 0) # empty array
        {
            $sortedx += $current
        }
        else
        {
            for($j = 0; $j -lt $sortedx.Count; $j++ )
            {
                $curStartWithJ = checkPredicate $current $sortedx[$j]  # current starts with sortedj
                $jStartWithCur = checkPredicate $sortedx[$j] $current  # sortedj start with current
                
                $endOfArray = $j -eq ($sortedx.Count-1)
    
                if($curStartWithJ -or $jStartWithCur)
                {                    
                    if(($j -eq 0) -or ($endOfArray))
                    {
                        if ($jStartWithCur) { # begining of arrau
                            $sortedx = @($current)+$sortedx
                            break;
                        } 
                        else { # end of array 
                            $sortedx +=$current
                            break;
                        }
                    }
                    else # middle of array
                    {
                        
                        if($curStartWithJ)
                        {$b = 1; $u = 0}
                        else
                        {$b = 0; $u = 1}

                        $above = $sortedx | select -first $j
                        $below = $sortedx | select -Skip $j
                        
                        $sortedx.Clear()

                        $sortedx = @($above)+$current                        
                        $sortedx = @($sortedx)+$below
                        break;
                    }     
                }

                if ($endOfArray)
                {
                    $sortedx +=$current
                    break;
                }
            }              
        }
    }
            
    # Return the sorted list
    return $sortedx
}

# Call the function to sort the list using insertion sort
#$sorted = Insertion-Sort -list $folders

# Display the sorted list
$sorted


# Define a function to get the depth of a folder
function Get-Depth {
    param($folder)
    # Split the folder by the path separator and count the number of parts
    return ($folder -split "\\").Count
}

# Sort the folders by depth in descending order
$sortedFolders = $folders | Sort-Object -Descending -Property {Get-Depth $_}

# Get the total number of folders
$total = $sortedFolders.Count

# Initialize the folder index
$index = 0

# For each folder in the sorted list
foreach ($folder in $sortedFolders) {
    # Increment the folder index
    $index++

    # Calculate the percentage of completion
    $percent = ($index / $total) * 100

    # Update the progress bar
    Write-Progress -Activity "Adding and committing folders" -Status "Current folder: $folder" -PercentComplete $percent

    # Change the current location to the folder
    Set-Location $folder

    # Get the folder name
    $folderName = Split-Path $folder -Leaf

    # Add all the files in the folder to the staging area
    git add .

    $xq = invoke-expression "git status"

    if( $xq[-1] -ne "nothing to commit, working tree clean" )
    {
        # Commit the changes with the message "folder name; toVerify"
        git commit -m "$folderName; toVerify"
    }
}
