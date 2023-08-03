# Get the folder path from the user input
$folderPath = "B:\PF\AhkProjectFolder"

# Use Everything to find all folders in the folder path
$folders = es -path $folderPath -a "folder:"

# Define a custom comparator that sorts in ascending order by comparing the remainder of dividing by 3
function comparatorX ($huba,$ruba) { 
     return (
        $huba.StartsWith($ruba)
        ) }

# Define a function to sort a list by a custom comparator
function Sort-List {
    param($list)
    # Loop through the list from the second element
    for ($i = 1; $i -lt $list.Count; $i++) {
        
        # Get the current element
        $current = $list | select -Index $i
        
        # Initialize the index of the previous element
        $j = $i - 1

        # Loop backwards until the beginning of the list or until the comparator returns false
        while ($j -ge 0 -and (comparatorX -huba $current -ruba $list[$j]) ) {
            # Move the previous element one position forward
            $list[$j + 1] = $list[$j]
            # Decrement the index of the previous element
            $j--
        }
        
        # Insert the current element in the correct position
        $list[$j + 1] = $current
    }
    # Return the sorted list
    return $list
}


# Call the function to sort the list by the custom comparator
$sorted = Sort-List -list $folders

# Display the sorted list
$sorted


# Define a function to get the depth of a folder
function Get-Depth {
    param($folder)
    # Split the folder by the path separator and count the number of parts
    return ($folder -split "\\").Count
}

# Sort the folders by depth in descending order
$sortedFolders = $folders | Sort-Object -Descending -Property {Get-Depth $_}

# Get the total number of folders
$total = $sortedFolders.Count

# Initialize the folder index
$index = 0

# For each folder in the sorted list
foreach ($folder in $sortedFolders) {
    # Increment the folder index
    $index++

    # Calculate the percentage of completion
    $percent = ($index / $total) * 100

    # Update the progress bar
    Write-Progress -Activity "Adding and committing folders" -Status "Current folder: $folder" -PercentComplete $percent

    # Change the current location to the folder
    Set-Location $folder

    # Get the folder name
    $folderName = Split-Path $folder -Leaf

    # Add all the files in the folder to the staging area
    git add .

    # Commit the changes with the message "folder name; toVerify"
    git commit -m "$folderName; toVerify"
}
