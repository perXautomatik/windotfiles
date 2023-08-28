# Invoke git config with the --list and --show-origin options
$output = git config --list --show-origin

# Create an empty array to store the custom PSObjects
$objects = @()

# Loop through each line of the output
foreach ($line in $output) {
  # Split the line by the tab character to get the origin and the setting
  $parts = $line -split "\t"
  $origin = ($parts[0] -split ':' | select -Skip 1) -join ':'
  $setting = $parts[1]

  # Split the setting by the equal sign to get the key and the value
  $keyvalue = $setting -split "="
  $key = $keyvalue[0]
  $value = $keyvalue[1]

  # Split the key by the dot character to get the segment and the key name
  $segmentkey = $key -split "\."
  $segment = $segmentkey[0]
  $keyname = ($segmentkey | select -Skip 1) -join '.'

  # Create a custom PSObject with the properties path, segment, key, and value
  $object = [PSCustomObject]@{
    Path = $origin
    Segment = $segment
    Key = $keyname
    Value = $value
  }

  # Add the object to the array
  $objects += $object
}


# Group the array of objects by path and store it in a variable
$grouped = $objects | Group-Object -Property Path

# Loop through each group and display its name and its expanded objects in a table format
foreach ($group in $grouped) {
  Write-Output "Path: $($group.Name)"
  Write-Output "------------------------"
  $group.Group | sort -Property segment,key | Format-Table -Property Segment, Key, Value -AutoSize 
  Write-Output ""
}