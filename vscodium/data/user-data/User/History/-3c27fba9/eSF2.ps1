<#
.SYNOPSIS
A function to get the common prefix of a set of strings.

.DESCRIPTION
This function takes an array of strings as a parameter and returns the longest common prefix among them. If there is no common prefix, it returns an empty string.

.PARAMETER Strings
The array of strings to be compared.

.EXAMPLE
GetCommonPrefix -Strings @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")

This will return "C:\foo\" as the common prefix.
#>
function GetCommonPrefix {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection ()]
    [string[]]$Strings
  )

  # Check if the array is empty or has only one element
  if ($Strings.Length -eq 0) {
    return ""
  }
  elseif ($Strings.Length -eq 1) {
    return $Strings[0]
  }

  # Initialize the common prefix as the first string in the array
  $commonPrefix = $Strings[0]

  # Loop through the rest of the strings in the array
  for ($i = 1; $i -lt $Strings.Length; $i++) {
    # Compare the common prefix with the current string character by character
    for ($j = 0; $j -lt [Math]::Min($commonPrefix.Length, $Strings[$i].Length); $j++) {
      # If the characters are different, break the loop
      if ($commonPrefix[$j] -ne $Strings[$i][$j]) {
        break
      }
    }

    # Update the common prefix as the substring up to the last matching character
    $commonPrefix = $commonPrefix.Substring(0, $j)

    # If the common prefix becomes empty, return it
    if ($commonPrefix -eq "") {
      return $commonPrefix
    }
  }

  # Return the common prefix after looping through all the strings
  return $commonPrefix
}
