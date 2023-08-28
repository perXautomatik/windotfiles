# Read the file content as a string
$file_content = Get-Content -Path "B:\Unsorted\TEMP\.git\filter-repo\analysis\path-all-sizes.txt"

# Split the file content by newlines
$lines = $file_content -split "`r`n"

# Create an empty array to store the parsed data
$data = @()

# Loop through each line
foreach ($line in $lines) {
    # Skip empty lines
    if ($line -eq "") {
        continue
    }

    # Split the line by whitespace
    $fields = $line -split "\s+"

    # Extract the unpacked size, packed size, date deleted and path name
    $unpacked_size = $fields[1]
    $packed_size = $fields[2]
    $date_deleted = $fields[3]
    $path_name = $fields[4..$fields.Length] -join ' '

    # Create a custom object with the extracted data
    $obj = [PSCustomObject]@{
        UnpackedSize = $unpacked_size
        PackedSize = $packed_size
        DateDeleted = $date_deleted
        PathName = $path_name
    }

    # Add the object to the data array
    $data += $obj
}

# Group the data by the path leafs (the last part of the path name)
$grouped_data = $data | Group-Object -Property {Split-Path $_.PathName -Leaf}

# Loop through each group and display the group name, count and total unpacked size
foreach ($group in $grouped_data) {
    # Calculate the total unpacked size for each group by summing up the unpacked size of each object in the group
    $total_unpacked_size = ($group.Group | Measure-Object -Property UnpackedSize -Sum).Sum

    # Format the total unpacked size with commas as thousands separators
    $formatted_unpacked_size = "{0:N0}" -f [int]$total_unpacked_size

    Write-Output "$($group.Name): $($group.Count) files, $($formatted_unpacked_size) bytes"
    # If there are more than one paths with the same file name, print them as a comma-separated list
    if ($group.Count -gt 1) { Write-Output "Paths with same file name: $($group.Group.PathName -join ", ")" } } | Sort-Object -Descending