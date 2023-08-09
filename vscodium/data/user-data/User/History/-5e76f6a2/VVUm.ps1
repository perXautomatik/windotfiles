# Define the file name that contains the list of paths
$FileName = $args[0]

# Read the file content and split it by line
$paths = (Get-Content -Path $FileName | Out-String) -split "`n"

    # Get all the files in the path and sort them by size
    $files =  $paths | Sort-Object -Property Length

    # Get the smallest file as the target
    $target = $files[0]

    # Loop through each path
    foreach ($path in ($files | select -Skip 1  | ? { $_ -ne "" }  | ? { $_ -ne $null } ) )
    {
            # Get the current file and its name before moving
            $oldName = $path.Name

            # Move and rename the file to the target with force
            Move-Item -Path $path.FullName -Destination $target.FullName -Force
            git add .
            # Commit with a message containing the old name
            git commit -m "Moved and renamed $oldName to $target.Name"
    }
