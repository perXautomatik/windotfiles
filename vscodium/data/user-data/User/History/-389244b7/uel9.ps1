# A function to validate the arguments
function Validate-Arguments ($modules, $folder) {
  if (-not (Test-Path $modules)) { 
    Write-Error "Invalid modules path: $modules"
    exit 1
  }

  if (-not (Test-Path $folder)) {
    Write-Error "Invalid folder path: $folder"
    exit 1
  }
}

# A function to check the git status of a folder
function Check-GitStatus ($folder) {
  # Change the current directory to the folder
  Set-Location $folder.FullName
  Write-Output "checking $folder"
  if ((Get-ChildItem -force | ?{ $_.name -eq ".git" } ))
  {
    # Run git status and capture the output
    $output = git status
    
    if(($output -like "fatal*"))
    { 
      Write-Output "fatal status for $folder"
      Repair-GitFolder $folder
    }
    else
    {
      Write-Output @($output)[0]
    }
  }
  else
  {
    Write-Output "$folder not yet initialized"
  }
}

# A function to repair a corrupted git folder
function Repair-GitFolder ($folder) {
  $folder | Get-ChildItem -force | ?{ $_.name -eq ".git" } | % {
    $toRepair = $_

    if( $toRepair -is [System.IO.FileInfo] )
    {
      Move-GitFile $toRepair
    }
    elseif( $toRepair -is [System.IO.DirectoryInfo] )
    {
      Fix-GitConfig $toRepair
    }
    else
    {
      Write-Error "not a .git file or folder: $toRepair"
    }
  }
}

# A function to move a .git file to the corresponding module folder
function Move-GitFile ($file) {
  global:$modules | Get-ChildItem -Directory | ?{ $_.name -eq $file.Directory.Name } | select -First 1 | % {
    # Move the folder to the target folder
    rm $file -force ; Move-Item -Path $_.fullname -Destination $file -force 
  }
}

# A function to fix the worktree setting in a .git config file
function Fix-GitConfig ($folder) {
  # Get the path to the git config file
  $configFile = Join-Path -Path $folder -ChildPath "\config"

  if (-not (Test-Path $configFile)) {
    Write-Error "Invalid folder path: $folder"  
  }
  else
  {
    # Read the config file content as an array of lines
    $configLines = Get-Content -Path $configFile

    # Filter out the lines that contain worktree
    $newConfigLines = $configLines | Where-Object { $_ -notmatch "worktree" }

    if (($configLines | Where-Object { $_ -match "worktree" }))
    {
      # Write the new config file content
      Set-Content -Path $configFile -Value $newConfigLines -Force
    }
  }
}

# The main function that calls the other functions
function fix-CorruptedGitModules ($folder = "C:\ProgramData\scoop\persist", global:$modules = "C:\ProgramData\scoop\persist\.git\modules")
{
  begin {
    Push-Location

    # Validate the arguments
    Validate-Arguments $modules $folder

    # Set the environment variable for git error redirection
    $env:GIT_REDIRECT_STDERR = '2>&1'
  }
  
  process {  
    # Get the list of folders in $folder
    $folders = Get-ChildItem -Path $folder -Directory

    # Loop through each folder and check the git status
    foreach ($f in $folders) {
      Check-GitStatus $f      
    }
  }

  end {
   Pop-Location
  }

}
