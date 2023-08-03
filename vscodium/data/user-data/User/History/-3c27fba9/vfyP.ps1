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
    [string[]]$Strings,

    # Add a new switch parameter to indicate if only folder paths should be returned
    [switch]$OnlyFolders,

    # Add another switch parameter to indicate if the strings need to be valid paths or not
    [switch]$ValidatePaths
  )

  # Check if the array is empty or has only one element
  if ($Strings.Length -eq 0) {
    return ""
  }
  elseif ($Strings.Length -eq 1) {
    return $Strings[0]
  }

  # If the strings need to be valid paths, check each string with Test-Path
  if ($ValidatePaths) {
    foreach ($String in $Strings) {
      
      # If any string is not a valid path, throw an error or return an empty string
      if (-not (Test-Path -Path $String -IsValid)) {
        Write-Error "Invalid path: $String"
        return ""
      }
      # If any string is not a valid path, throw an error or return an empty string
      if (-not (Test-Path -Path $String -IsValid)) {
        Write-Error "Invalid path: $String"
        return ""
      }
    }
  }

  # Initialize the common prefix as the first string in the array
  $commonPrefix = Get-ArrayCommonPrefix -Strings $Strings
  # Check if the array is empty or has only one element
  if ($commonPrefix.Length -eq 0) {
    return ""
  }
# If only folder paths are requested, use Split-Path to get only the folder part of the common prefix
if ($OnlyFolders) {
  # Check if the common prefix is a folder

  $endsWith = $commonPrefix.EndsWith('\')
  #$IsFolder = Test-Path -Path $commonPrefix -PathType Container -IsValid

  # If the common prefix is not a folder, use Split-Path to get the parent folder
  if (-not $endsWith) {
    $commonPrefix = Split-Path -Path $commonPrefix -Parent
  }
}
  # Return the common prefix after looping through all the strings
  return $commonPrefix
}

# A function that compares two strings character by character and returns the common prefix
<#
.SYNOPSIS
Compares two strings character by character and returns the common prefix.

.DESCRIPTION
This function takes two strings as input and compares them character by character from left to right. It returns the substring that is common to both strings up to the first mismatching character. If there is no common prefix, it returns an empty string.

.PARAMETER String1
The first string to compare.

.PARAMETER String2
The second string to compare.

.EXAMPLE
Get-StringCommonPrefix -String1 "C:\foo\bar.txt" -String2 "C:\foo\baz.txt"

Returns "C:\foo\"
#>
function Get-StringCommonPrefix {
  [CmdletBinding()]
  param(
    # Validate that the parameters are not null or empty strings
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$String1,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$String2
  )

  # Initialize the common prefix as an empty string
  $commonPrefix = ""

  # Loop through the characters of the shorter string
  for ($i = 0; $i -lt [Math]::Min($String1.Length, $String2.Length); $i++) {
    # If the characters are different, break the loop
    if ($String1[$i] -ne $String2[$i]) {
      break
    }

    # Append the matching character to the common prefix
    $commonPrefix += $String1[$i]
  }

  # Return the common prefix
  return $commonPrefix
}

# A function that loops through an array of strings and returns the common prefix
<#
.SYNOPSIS
Loops through an array of strings and returns the common prefix.

.DESCRIPTION
This function takes an array of strings as input and loops through them, calling the Get-StringCommonPrefix function to compare them and find the common prefix. It returns the substring that is common to all the strings in the array. If there is no common prefix, it returns an empty string.

.PARAMETER Strings
The array of strings to compare.

.EXAMPLE
Get-ArrayCommonPrefix -Strings @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")

Returns "C:\foo"
#>
function Get-ArrayCommonPrefix {
  [CmdletBinding()]
  param(
    # Validate that the parameter is not null or empty, and contains only strings
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
   # [ValidateScript({$_ -is [string[]]})]
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
    # Call the Get-StringCommonPrefix function to compare the common prefix with the current string
    $commonPrefix = Get-StringCommonPrefix -String1 $commonPrefix -String2 $Strings[$i]

    # If the common prefix becomes empty, return it or write an error
    if ($commonPrefix -eq "") {
      # Uncomment this line to return an empty string
      #return $commonPrefix

      # Uncomment this line to write an error and stop execution
      #Write-Error "No common prefix found in the array"
      break
    }
  }

  # Return the common prefix after looping through all the strings
  return $commonPrefix
}
