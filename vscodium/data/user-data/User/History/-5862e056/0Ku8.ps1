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
                        if ($jStartWithCur) { # place in front of j

                            $above = $sortedx | select -first $j
                            $below = $sortedx | select -Skip $j
                        }
                        else # place after j
                        {
                            $above = $sortedx | select -first $j+1
                            $below = $sortedx | select -Skip $j+1
                        }

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


# Define a sample list of numbers
$numbers = 28, 2, 11, 12, 5, 6, 7, 1, 288

# Call the function to sort the list using insertion sort
$sorted = Insertion-Sort -list $numbers

# Display the sorted list
$sorted