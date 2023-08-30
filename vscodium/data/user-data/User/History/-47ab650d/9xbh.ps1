# Define a function to delete reparse points using fsutil
# Define a function to delete reparse points using fsutil
function Delete-ReparsePoint {
    param (
        [string]$Path # The path of the file or folder that contains a reparse point
    )
    # Check if the path exists and is valid
    if (Test-Path -Path $Path -IsValid) {
        # Try to delete the reparse point using fsutil
        try {
            # Capture the output of fsutil
            $fsutilOutput = fsutil reparsepoint delete $Path 2>&1
            # Check if the output contains "error:"
            if ($fsutilOutput -match "error:") {
                # Throw the output as an exception
                throw $fsutilOutput
            }
            else {
                # Write the output to the host
                Write-Host $fsutilOutput
            }
        }
        catch {
            Write-Error "Failed to delete reparse point at $Path : $_"
        }
    }
    else {
        Write-Error "Invalid or non-existent path : $Path"
    }
}

# Run streams64.exe and capture its output
$streamsOutput = streams64.exe -s "C:\Documents and Settings\All Users" | Out-String

# Split the output by lines
$streamsLines = $streamsOutput -split "`r`n"

# Initialize a flag to indicate if the previous line was an error opening line
$errorOpening = $false

# Loop through each line
foreach ($line in $streamsLines) {
    # Check if the line contains "error opening"
    if ($line -match "error opening") {
        # Extract the path from the line
        $path = ($line -replace 'Error opening ' ,' ').trim().trim(":")
        # Set the flag to true
        $errorOpening = $true
    }
    # Check if the previous line was an error opening line and the current line is not blank
    elseif ($errorOpening -and $line) {
        # Extract the cause of the error from the line
        $cause = $line.trim().trim(":")
        # Check if the cause is not "access denied"
        if ($cause -ne "access is denied.") {
            # Call the function to delete the reparse point at the path
            Delete-ReparsePoint -Path $path
        }
        else {
            Write-Error "$cause : $Path"
        }
        # Reset the flag to false
        $errorOpening = $false
    }
}