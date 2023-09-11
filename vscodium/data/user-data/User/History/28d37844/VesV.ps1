

# Get the path of the object to search for
$object_path = Read-Host "Enter the path of the object to search for"

# Write the object as a blob object and get its hash
$object_hash = Git hash-object $object_path

# Get the content and the number of lines of the object
$object_content = Get-Content $object_path
$object_lines = $object_content.Length

# Initialize a variable to store the result
$result = $null

# Initialize a progress bar
$progress = @{
    Activity = "Searching for a commit that contains an exact or partial copy of the object"
    Status = "Searching..."
    PercentComplete = 0
}

# Loop through all the commits in the repository
foreach ($commit in Git rev-list --all) {
    # Update the progress bar
    Write-Progress @progress

    # Check if the commit contains an exact copy of the object by comparing the hashes
    if (Git ls-tree -r $commit -- $object_path | Select-String -Pattern $object_hash) {
        # If yes, store the commit hash as the result and break the loop
        $result = $commit
        break
    }
    else {
        # If not, check if the commit contains a partial copy of the object by comparing the content
        # Get the content and the number of lines of the file in the commit
        $file_content = Git show $commit:$object_path
        $file_lines = $file_content.Length

        # Count how many lines are common between the object and the file
        $common_lines = Compare-Object -ReferenceObject $object_content -DifferenceObject $file_content -ExcludeDifferent -IncludeEqual | Measure-Object | Select-Object -ExpandProperty Count

        # Calculate the percentage of common lines
        $common_percentage = ($common_lines / [Math]::Max($object_lines, $file_lines)) * 100

        # Check if the percentage is at least 50%
        if ($common_percentage -ge 50) {
            # If yes, store the commit hash as the result and break the loop
            $result = $commit
            break
        }
    }
}

# Clear the progress bar
Write-Progress @progress -Completed

# Check if a result was found
if ($result) {
    # If yes, display the result
    Write-Host "Found a commit that contains an exact or partial copy of the object: $result"
}
else {
    # If not, display a message
    Write-Host "No commit was found that contains an exact or partial copy of the object"
}
