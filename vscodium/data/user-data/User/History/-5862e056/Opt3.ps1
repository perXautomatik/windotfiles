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
function atBeginingofArray {
    $sortedx = @($current)+$sortedx
    break;    
}
function atEndofArray
{
    $sortedx +=$current
                    break;
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
            atBeginingofArray
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
                            atBeginingofArray
                        } 
                        else { # end of array 
                            atEndofArray
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
                    atEndofArray                    
                }
            }              
        }
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