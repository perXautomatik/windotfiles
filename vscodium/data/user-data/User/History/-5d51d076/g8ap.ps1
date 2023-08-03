

    # Define a function to split text by a regular expression
  # Define a function to split text by a regular expression
  function Split-TextByRegex {
    <#
    .SYNOPSIS
    Splits text by a regular expression and returns an array of objects with the start index, end index, and value of each match.

    .DESCRIPTION
    This function takes a path to a text file and a regular expression as parameters, and returns an array of objects with the start index, end index, and value of each match. The function uses the Select-String cmdlet to find the matches, and then creates custom objects with the properties of each match.

    .PARAMETER Path
    The path to the text file to be split.

    .PARAMETER Regx
    The regular expression to use for splitting.

    .EXAMPLE
    Split-TextByRegex -Path ".\test.txt" -Regx "submodule"

    This example splits the text in the test.txt file by the word "submodule" and returns an array of objects with the start index, end index, and value of each match.
    #>

    # Validate the parameters
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path $_ -ErrorAction stop})] 
        [string]$Path,
        [Parameter(Mandatory=$true)]        
        [string][ValidateNotNullOrEmpty()]$Regx
        
    )

        # Try to read the text from the file
    try {
        $Content = Get-Content $Path -Raw
    }
    catch {
            Write-Error "Could not read the file: $_"
        return
    }

    # Try to split the content by the regular expression
    try {
        $Matchez = [regex]::Matches($Content, $Regx)
        $NonMatches = [regex]::Split($Content, $Regx)        
        $single = Select-String -InputObject $Content -Pattern $Regx -AllMatches | Select-Object -ExpandProperty Matches
    }
    catch {
        Write-Error "Could not split the content by $Regx"
        return
    }

        # Create an array to store the results
    $Results = @()

    if($IncNonmatches)
    {
        # Loop through the matches and non-matches and create custom objects with the index and value properties
        for ($i = 0; $i -lt $Matchez.Count; $i++) {
            $Results += [PSCustomObject]@{
                index = $Matchez[$i].Index
                value = $Matchez[$i].Value
            }
            $Results += [PSCustomObject]@{
                index = $Matchez[$i].Index + $Matches[$i].Length
                value = $NonMatches[$i + 1]
            }
        }
    }        
    else {    
            # Loop through each match and create a custom object with its properties
        foreach ($match in $single) {
            $result = [PSCustomObject]@{
                StartIndex = $match.Index
                EndIndex = $match.Index + $match.Length - 1
                Value = $match.Value
            }
            # Add the result to the array
            $results += $result
        }
    }

    # Return the results
    return $Results

}
