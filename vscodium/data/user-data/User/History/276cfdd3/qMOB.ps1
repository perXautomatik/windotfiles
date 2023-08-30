# Synopsis: Remove a range of tokens from an array of tokens and return the modified array
function Remove-Tokens {
  param(
      # The start index of the range to remove, inclusive
      [Parameter(Mandatory=$true)]
      [int]$StartIndex,

      # The end index of the range to remove, inclusive
      [Parameter(Mandatory=$true)]
      [int]$EndIndex,

      # The array of tokens to modify
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken[]]$Tokens
  )

  # Check if the start and end index are valid for the array length
  if ($StartIndex -lt 0 -or $StartIndex -ge $Tokens.Length) {
      Write-Error "Invalid start index: $StartIndex"
      exit 1
  }
  
  if ($EndIndex -lt 0 -or $EndIndex -ge $Tokens.Length) {
      Write-Error "Invalid end index: $EndIndex"
      exit 1
  }

  if ($StartIndex -gt $EndIndex) {
      Write-Error "Start index cannot be greater than end index"
      exit 1
  }

  # Remove the range of tokens from the array and return it
  return $Tokens[0..($StartIndex-1)] + $Tokens[($EndIndex+1)..($Tokens.Length-1)]
}


# Synopsis: Get the content of a group of tokens between a group start and a group end token
function Get-GroupContent {
  param(
      # The group start token
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken]$GroupStart,

      # The group end token
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken]$GroupEnd,

      # The tokens to get the content from
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken[]]$Tokens
  )

  # Get the range of tokens between the group start and the group end token, inclusive
$st = $tokens.IndexOf($groupStart)
$en = $tokens.IndexOf($GroupEnd)

  $range = $Tokens[$st..$en]
  $y = ($range | ForEach-Object {$_.Content})
  $q = $y -join " "
  # Join the content of each token in the range and return it
  return $q
}
# Synopsis: Find the matching group start token for a given group end token
function Find-GroupStart {
  param(
      # The group end token to match
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken]$GroupEnd,

      # The tokens to search from
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken[]]$Tokens
  )

  # Find the last group start token that has a smaller index than the group end token
  $groupStart = $Tokens | Where-Object {$_.Type -eq "GroupStart" -and $_.Start -lt $GroupEnd.Start} | Select-Object -Last 1

  # Return the group start token or null if not found
  return $groupStart
}
function Find-GroupName {
  param(
      # The group end token to match
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken]$groupStart,

      # The tokens to search from
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken[]]$Tokens
  )

  
function not-insideOtherGroup
{
  #if in group, make sure to not be partially in group, that is a group start between object and start but no end
  param ($ob,$x)

  $subr = $Tokens[$tokens.IndexOf($ob)..$tokens.IndexOf($x)]
  
  return -not ($subr.type -contains "groupStart") -or ($subr.type -contains "groupEnd")
}

  # Find the last group start token that has a smaller index than the group end token
  $groupName = $Tokens | Where-Object {$_.Type -eq "CommandArgument" -and $_.Start -lt $groupStart.Start -and (not-insideOtherGroup -ob $_ -x $groupStart.Start )} | Select-Object -Last 1

  # Return the group start token or null if not found
  return $groupName
}
# Synopsis: Filter the tokens by type Function
function Get-FunctionTokens {
  param(
      # The tokens to filter
      [Parameter(Mandatory=$true)]
      [System.Management.Automation.PSToken[]]$Tokens
  )

  # Filter the tokens by type Function
  $functionTokens = $Tokens | Where-Object {$_.Type -eq "Function"}

  # Return the function tokens
  return $functionTokens
}
function Get-Tokens {
  param(
      # The full name of the file to parse
      [Parameter(Mandatory=$true)]
      [string]$FileName
  )

  # Get the raw content of the file
  $content = Get-Content -Path $FileName -Raw

  # Parse the content into tokens and errors
  $tokens = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)

  # Return the tokens
  return $tokens
}
<# 


Source: Conversation with Bing, 2023-06-26
(1) Recursive file search using PowerShell - Stack Overflow. https://stackoverflow.com/questions/8677628/recursive-file-search-using-powershell.
(2) powershell - Get List Of Functions From Script - Stack Overflow. https://stackoverflow.com/questions/40967449/get-list-of-functions-from-script.
(3) function - Powershell Recursion with Return - Stack Overflow. https://stackoverflow.com/questions/4989021/powershell-recursion-with-return.
(4) Recursion in PowerShell - DEV Community. https://dev.to/omiossec/recursion-in-powershell-2b85.
(5) Is there a way to retrieve a PowerShell function name from within a .... https://stackoverflow.com/questions/3689543/is-there-a-way-to-retrieve-a-powershell-function-name-from-within-a-function.
(6) Functions - PowerShell | Microsoft Learn. https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.3.
#>

# Define a pattern to match function names
$pattern = 'function\s+([_\-\w]+)'

# Search recursively for PowerShell script and module files
$files = Get-ChildItem -Path 'B:\GitPs1Module' -Filter *.ps*1 -Recurse -ErrorAction SilentlyContinue -Force

# Create an empty list to store the results
$results = @()

# Loop through each file
foreach ($file in $files) {
      # Read the file content as a single string
    # Synopsis: Get the content of a file and parse it into tokens
    
    $tokenz = Get-Tokens $file
    $ends = $tokenz | ? { $_.type -eq "groupEnd"}

    $groups = $ends | select @{name = "end" ; e={ $_}}, @{
      name = "start" 
      expres={ (Find-GroupStart -groupend $_ -Tokens $tokenz) }} 

    $res =  $groups | select start,end, @{ 
      name = "functionBody" 
      express={ Get-GroupContent -GroupStart $_.start -GroupEnd $_.end -Tokens $tokenz } }

    $results += $res | % {
      # Create a custom object with the file location, function name and function body
      $statIndex = $tokenz.IndexOf($_.start)
      [PSCustomObject]@{
        FileLocation = $file
        FunctionName = $tokenz[($statIndex)]
        FunctionBody = $_.functionBody
      }
    }     
} 

# Sort the results by function name and file location
$results = $results | ? { $_.FunctionName.type -eq "CommandArgument"} | Sort-Object FunctionName, FileLocation

# Display the results as a table
$results | Format-Table -AutoSize
