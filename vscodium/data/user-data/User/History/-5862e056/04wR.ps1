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

function Insertion-Sort {
    param($list)

    # Create an ArrayList object from the original list
    $unsorted = [System.Collections.ArrayList]$list
    # Create an empty ArrayList object for the sorted list
    $sortedx = New-Object System.Collections.ArrayList

    # Loop through each element in the unsorted list
    foreach ($current in $unsorted) {
        # Initialize an index variable for the insertion position
        $index = 0
        # Loop through each element in the sorted list until finding the correct position
        while ($index -lt $sortedx.Count -and (checkPredicate $current $sortedx[$index])) {
            # Increment the index variable
            $index++
        }
        # Insert the current element in the correct position using the Insert method
        $sortedx.Insert($index, $current)
    }

    # Return the sorted list
    return $sortedx
}

# Define a sample list of numbers
$numbers = 28, 2, 11, 12, 5, 6, 7, 1

# Call the function to sort the list using insertion sort
$sorted = Insertion-Sort -list $numbers

# Display the sorted list
$sorted