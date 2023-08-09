{
    $modsPath = 'B:\PF\Modding\Diablo II ressurected'
    
    # Get all the subfolders in the mods folder
    $modFolders = Get-ChildItem -Path $modsPath -Directory
    
    # Loop through each subfolder
    foreach ($modFolder in $modFolders) {
    
        # Get the full path of the mod.json file
        $modJsonPath = Join-Path -Path $modFolder.FullName -ChildPath 'mod.json'
        
        # Check if the mod.json file exists
        if (Test-Path -Path $modJsonPath) {
        
            # Read the mod.json file and convert it to a PowerShell object
            $modJson = Get-Content -Path $modJsonPath -Raw | ConvertFrom-Json
            
            # Check if the name field is different from the subfolder name
            if ($modJson.name -ne $modFolder.Name) {
            
                # Rename the subfolder to match the name field
                Rename-Item -Path $modFolder.FullName -NewName $modJson.name
                
                # Write a message to indicate the rename operation
                Write-Host "Renamed $($modFolder.Name) to $($modJson.name)"
            }
            
            if ([string]::IsNullOrEmpty($modJson.description)) {
            
                # Fill in the description field with some default text
                $modJson.description = "This is a mod for d2rmmm. Please edit this description to provide more details."
                
                # Convert the PowerShell object back to JSON and overwrite the mod.json file
                $modJson | ConvertTo-Json | Set-Content -Path $modJsonPath
                
                # Write a message to indicate the update operation
                Write-Host "Updated description for $($modJson.name)"
            }
        }
        else {
        
            # Write a message to indicate that the mod.json file is missing
            Write-Warning "No mod.json file found in $($modFolder.Name)"
        }
    }}