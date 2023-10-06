# Import the required modules.
import-module re

# Define a function to sort using directives and functions.
function Sort-UsingDirectivesAndFunctions($text) {
  # Define a regular expression pattern to match using directives and functions.
  $pattern = "(using\s+\S+;)|(public|private)\s+\S+\s+\S+\(.*?\)\s*\{.*?\}"

  # Create a hashtable to group directives and functions by their type.
  $groups = @{}

  # Use re.findall to find all matches of the pattern in the text.
  $matches = re.findall($pattern, $text)

  # Loop through each match in the matches.
  foreach ($match in $matches) {
    # Get the type of the match (using, public, or private) by splitting it by whitespace and taking the first part.
    $type = ($match -split "\s+")[0]

    # Check if the type already exists as a key in the hashtable.
    if ($groups.ContainsKey($type)) {
      # Add the match to the existing value list for the key.
      $groups[$type] += $match
    }
    else {
      # Create a new key-value pair for the type and the match in the hashtable.
      $groups[$type] = @($match)
    }
  }

  # Define a custom comparer function to sort functions by their name, ignoring the parameters and return type.
  function Compare-FunctionName($x, $y) {
    # Get the name of the first function by splitting it by whitespace and taking the second part.
    $nameX = ($x -split "\s+")[1]

    # Get the name of the second function by splitting it by whitespace and taking the second part.
    $nameY = ($y -split "\s+")[1]

    # Compare the names using string comparison and return the result.
    return [string]::Compare($nameX, $nameY)
  }

  # Sort each value list in the hashtable using Sort-Object with or without the custom comparer depending on the type.
  foreach ($type in $groups.Keys) {
    if ($type -eq "using") {
      # Sort using directives alphabetically.
      $groups[$type] = $groups[$type] | Sort-Object
    }
    else {
      # Sort functions by their name using the custom comparer.
      $groups[$type] = $groups[$type] | Sort-Object -Comparer ${function:Compare-FunctionName}
    }
  }

  # Use re.subn to replace each match of the pattern in the text with its corresponding sorted value from the hashtable.
  $sortedText, $count = re.subn($pattern, {
    param($match)

    # Get the type of the match by splitting it by whitespace and taking the first part.
    $type = ($match.Value -split "\s+")[0]

    # Get the sorted value for the type from the hashtable and remove it from the list.
    $sortedValue = $groups[$type][0]
    $groups[$type] = $groups[$type][1..$($groups[$type].Length)]

    # Return the sorted value as a replacement for the match.
    return $sortedValue
  }, $text)

  # Return the sorted text.
  return $sortedText
}

# Get the text of the C# file.
$text = Get-Content -Path $args[0]

# Sort using directives and functions in C# code
$sortedText = Sort-UsingDirectivesAndFunctions($text)

# Write sorted text to output file
Set-Content -Path $args[1] -Value $sortedText
