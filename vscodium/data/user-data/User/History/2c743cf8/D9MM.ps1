# Define the base path and the list of folder names
$basePath = "K:\D2RMM 1.4.5\mods"
$folderNames = "hd|global|excel|tiles|ui"

# Split the list of folder names by "|" and store them in an array
$folderNamesArray = $folderNames -split "\|"

# Use Get-ChildItem to get all the subfolders of the base path
# Use -Directory to filter only folders and -ErrorAction SilentlyContinue to ignore any errors
$subfolders = Get-ChildItem -Path $basePath -Directory -ErrorAction SilentlyContinue

# Create an empty array to store the output
$output = @()

# Loop through each subfolder in the base path
# Loop through each subfolder in the base path
foreach ($subfolder in $subfolders) {
  # Loop through each folder name in the array
  foreach ($folderName in $folderNamesArray) {
    # Use Get-ChildItem to search for the folder name in the subfolder recursively
    # Use -Directory to filter only folders and -ErrorAction SilentlyContinue to ignore any errors
    # Use Select-Object -First 1 to get only the first occurrence of the folder
    $folder = Get-ChildItem -Path $subfolder.FullName -Filter $folderName -Recurse -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    
    # If the folder is found, add its name and full path to the output array
    if ($folder) {
      $output += [PSCustomObject]@{
        Name = $folder.Name
        Path = $folder.FullName
      }
      # Break the inner loop and move on to the next subfolder
      Break
    }
  }
  # If a folder name was found, use Get-ChildItem again to search for the other folder names on the same level
  # Use -Directory to filter only folders and -ErrorAction SilentlyContinue to ignore any errors
  # Use -Exclude to exclude the folder name that was found and search for the other names in the array
  if ($folder) {
    $otherFolders = Get-ChildItem -Path (Split-Path $folder.FullName) -Directory -ErrorAction SilentlyContinue -Exclude $folder.Name | Where-Object {$_.Name -in $folderNamesArray}
    
    # If any other folders are found, add their names and full paths to the output array
    if ($otherFolders) {
      foreach ($otherFolder in $otherFolders) {
        $output += [PSCustomObject]@{
          Name = $otherFolder.Name
          Path = $otherFolder.FullName
        }
      }
    }
  }
}


# Group the output by the folder name before the underscore character
# Use a script block as the value of the Property parameter to extract that part of the name
$qq = $output |  Group-Object -Property {Split-Path $_.Path -Parent}| ?{ (split-path -path $_.name -Leaf) -eq "data" } #| Format-Table -Property Name, Group -AutoSize -Wrap

# Define a function that takes a number of paths and a delimited list of words as parameters
function Remove-WordsFromParentFolders {
    param (
        [string[]]$Paths,
        [string]$Words
    )

    # Split the words by the delimiter and store them in an array
    $WordArray = $Words -split ","

    # Loop through each path in the Paths array
    foreach ($Path in $Paths) {
        # Get the parent folder name of the current path
        $ParentFolder = Split-Path $Path -Parent

        # Check if the parent folder name is entirely the word
        if ( (Split-Path -Path $ParentFolder -Leaf) -eq "out") {
            # Get the grandparent folder name of the current path
            $GrandParentFolder = Split-Path $ParentFolder -Parent
            # Set the parent folder name to the grandparent folder name
            $ParentFolder = $GrandParentFolder
        }

        # Loop through each word in the WordArray
        foreach ($Word in $WordArray) {
            # Check if the parent folder name contains the word
            if ($ParentFolder -match $Word) {
                # Remove the word from the parent folder name
                $ParentFolder = $ParentFolder -replace $Word, ""
            }
   
        }

        # Return the edited parent folder name
        Write-Output $ParentFolder
    }
}

# Example usage: provide some paths and a delimited list of words as arguments
$uu = $qq | select Name, @{name="parent"; e={Remove-WordsFromParentFolders -Paths $_.name -Words ".mpq,.installing"} } 

# Define a function that checks if a path is inside another path
function Is-PathInside {
    [CmdletBinding()]
      param (
        [ValidateNotNullOrEmpty()]
        [string]$Path1,
        [ValidateNotNullOrEmpty()]
        [string]$Path2     
          
      )
  # Normalize the paths and remove any trailing backslashes
  $q = (Resolve-Path $Path1 -ErrorAction SilentlyContinue).Path
  $u = (Resolve-Path $Path2 -ErrorAction SilentlyContinue).Path
  $Path1 = &{if($q){$q}else{$Path1}}
  try {
    $Path1 = $Path1.TrimEnd("\")  
  }
  catch {
    Write-Debug $Path1
  }
  try {
    $Path2 = &{if($u){$u}else{$Path2}}
  }
  catch {
    Write-Debug $Path1
  }
  $Path2 = $Path2.TrimEnd("\")
  # Check if the first path is a substring of the second path
  return $Path1.StartsWith($Path2, [System.StringComparison]::OrdinalIgnoreCase)
}

# Define an array to store the paths that are inside other paths or neither
$InsideOrNeither = @()

$input = $uu.parent
# Get the paths from the pipeline and loop through them
$Paths = $input | ForEach-Object { $_.ToString() }
foreach ($Path in $Paths) {
  # Initialize a flag to indicate if the path is inside or outside other paths
  $IsInside = $false
  $IsOutside = $false
  # Loop through the other paths and compare them with the current path
  foreach ($OtherPath in $Paths) {
      # Skip if the paths are the same
      if ($Path -eq $OtherPath) { continue }
      # Check if the current path is inside the other path
      if (Is-PathInside -Path1 $Path -Path2 $OtherPath) {
          # Set the flag to true and break the loop
          $IsInside = $true
          break
      }
      # Check if the current path is outside the other path
      if (Is-PathInside -Path1 $OtherPath -Path2 $Path) {
          # Set the flag to true and continue the loop
          $IsOutside = $true
      }
  }
  # If the path is inside or neither, add it to the array
  if ($IsInside -or -not $IsOutside) {
      $InsideOrNeither += $Path
  }
}

# Return the array of paths that are inside or neither
$InsideOrNeither | select -Unique

# Define a function that takes two parameters: a destination path and a list of names and paths
function Move-Files {
  param(
      [string]$DestinationPath,
      [psobject[]]$List
  )
  # Create a new folder at the destination path if it does not exist
  if (-not (Test-Path $DestinationPath)) {
      New-Item -ItemType Directory -Path $DestinationPath
  }
  # Loop through the list and process each entry
  foreach ($Entry in $List) {
      # Get the name and path from the entry
      $Name = $Entry.Name
      $Path = $Entry.Path
      # Create a new folder named according to the name at the destination path
      $NewFolder = Join-Path -Path $DestinationPath -ChildPath $Name
      New-Item -ItemType Directory -Path $NewFolder -ErrorAction SilentlyContinue
      # Move all folders and files found in the path to the new folder
      Get-ChildItem -Path $Path | Move-Item -Destination $NewFolder 
  }
}

$listx = $uu | ?{ $_.parent -in $InsideOrNeither} | select @{name="path"; e={$_.name} }, @{name="name"; e={Split-Path -Path $_.parent -leaf}}
$destx = "F:\O\Vortex Mods\diablo2resurrected\New folder"

#Move-Files -DestinationPath $destx -List $listx

# Define a function that takes one parameter: a path to a folder
function Create-JsonFiles {
  param(
      [string]$FolderPath
  )
  # Get all the subfolders in the folder
  $Subfolders = Get-ChildItem -Path $FolderPath -Directory
  # Loop through the subfolders and process each one
  foreach ($Subfolder in $Subfolders) {
      # Create a JSON file inside the subfolder with the same name as the subfolder
      $jsX = Join-Path -Path $Subfolder.FullName -ChildPath ("mod.js")
      New-Item -ItemType File -Path $jsX
      # Create an empty array to store the entries for the JSON file
      $Entries = @()
      # Get all the subfolders inside the subfolder
      $InnerSubfolders = Get-ChildItem -Path $Subfolder.FullName -Directory
      # Loop through the inner subfolders and add an entry for each one
      foreach ($InnerSubfolder in $InnerSubfolders) {
        $qdd = $InnerSubfolder.Name
          # Create an entry as a hashtable with the name and path of the inner subfolder
          $Entry = "D2RMM.copyFile('$qdd', '$qdd', true );"
          # Add the entry to the array
          $Entries += $Entry
      }
      # Convert the array to a JSON string and write it to the JSON file
      $JsonString = (ConvertTo-Json -InputObject $Entries).Trim("[").Trim("]")
      $JsonString = $JsonString.Trim()
      .Trim(",").Trim('"')
      Set-Content -Path $jsX -Value $JsonString

      # Create a new .js file inside the subfolder with JSON containing the given text
      $jsonFilex = Join-Path -Path $Subfolder.FullName -ChildPath ("mod.json")
      New-Item -ItemType File -Path $jsonFilex
      # Create a hashtable with the given text as key-value pairs
      $Text = @{
          name = $Subfolder.Name
          description = "autoConverted"
          author = "cb"
          website = "https://github.com/olegbl/d2rmm.mods"
          version = "1.0"
      }
      # Convert the hashtable to a JSON string and write it to the .js file
      $JsString = ConvertTo-Json -InputObject $Text
      Set-Content -Path $jsonFilex -Value $JsString
  }
}


# Call the function with the example path as an argument
Create-JsonFiles -FolderPath $destx