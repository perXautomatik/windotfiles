
function Validate-Arguments ($modules, $folder) {
  
# A function to validate the arguments
  if (-not (Test-Path $modules)) { 
    Write-Error "Invalid modules path: $modules"
    exit 1
  }

  if (-not (Test-Path $folder)) {
    Write-Error "Invalid folder path: $folder"
    exit 1
  }
}

function Check-GitStatus ($folder) {
  
# A function to check the git status of a folder
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

function Repair-GitFolder ($folder) {
  
# A function to repair a corrupted git folder
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

function Move-GitFile {
  
# A function to move a .git file to the corresponding module folder
    param (
        [System.IO.FileInfo]$file,
    )
  global:$modules | 
  	Get-ChildItem -Directory | 
		?{ $_.name -eq $file.Directory.Name } | 
			select -First 1 | % {
    # Move the folder to the target folder
    rm $file -force ;
	 Move-Item -Path $_.fullname -Destination $file -force 
  }
}

function Fix-GitConfig {
  
# A function to fix the worktree setting in a .git config file
    param (
        [System.IO.DirectoryInfo]$folder
    )

    # Get the path to the git config file
                $configFile = Join-Path -Path $toRepair -ChildPath "\config"
        
    # Check if the config file exists
    if (-not (Test-Path $configFile)) {
                  Write-Error "Invalid folder path: $toRepair"  
    }
    else {
        # Read the config file content as an array of lines
        $configLines = Get-Content -Path $configFile

        # Filter out the lines that contain worktree, which is a setting that can cause problems with scoop
        $newConfigLines = $configLines | Where-Object { $_ -notmatch "worktree" }

        # Check if there are any lines that contain worktree
        if ($configLines | Where-Object { $_ -match "worktree" }) {
            # Write the new config file content, removing the worktree lines
            Set-Content -Path $configFile -Value $newConfigLines -Force
        }
    }
}

function check-gitstatus
 {
  
# Define a function that checks the status of a git repository and repairs it if needed
    param (
        [string]$RepositoryPath,
		[alias]$f
    )

    # Change the current directory to the repository path
      Set-Location $f.FullName
      Write-Output "checking $f"
      if ((Get-ChildItem -force | ?{ $_.name -eq ".git" } ))
      {
    # Run git status and capture the output
    $output = git status

    # Check if the output is fatal, meaning the repository is corrupted
    if ($output -like "fatal*") {
        Write-Output "fatal status for $RepositoryPath"

        # Get the .git file or folder in the repository path
        $f | Get-ChildItem -force |
		 ?{ $_.name -eq ".git" } | % {
        $toRepair = $_
    
        # Check if the .git item is a file
        if ($toRepair -is [System.IO.FileInfo]) {
               $modules | Get-ChildItem -Directory | ?{ $_.name -eq $toRepair.Directory.Name } | select -First 1 | % {
                # Move the folder to the target folder
                rm $toRepair -force ; Move-Item -Path $_.fullname -Destination $toRepair -force }
            }
            else
            {
                Write-Error "not a .git file: $toRepair"
            }

        # Check if the .git item is a folder
        if ($toRepair -is [System.IO.DirectoryInfo]) {
       			Fix-GitConfig -folder $toRepair    
        }
        else {
            Write-Error "not a .git folder: $toRepair"
        }

        }
    }
    else {
        Write-Output @($output)[0]
      }

       }
       else
       {
       Write-Output "$f not yet initialized"
       }

    }


function fix-CorruptedGitModules {
  <#
This code is a PowerShell script that checks the status of git repositories in a given folder and repairs 
them if they are corrupted. It does the following steps:

It defines a begin block that runs once before processing any input. In this block, it sets some variables
 for the modules and folder paths, validates them, and redirects the standard error output of git commands
  to the standard output stream.
It defines a process block that runs for each input object. In this block, it loops through each subfolder
 in the folder path and runs git status on it. If the output is fatal, it means the repository is corrupted 
 and needs to be repaired. To do that, it moves the corresponding module folder from the modules path to the
  subfolder, replacing the existing .git file or folder. Then, it reads the config file of the repository and
   removes any line that contains worktree, which is a setting that can cause problems with scoop. It prints 
   the output of each step to the console.
It defines an end block that runs once after processing all input. In this block, it restores the original
 location of the script.#>

# The main function that calls the other functions
    param 
	(
        [ValidateScript({Test-Path $_})]
		$folder = "C:\ProgramData\scoop\persist", 
        [ValidateScript({Test-Path $_})]
        $modules = "C:\ProgramData\scoop\persist\.git\modules"
	)

  begin {
    Push-Location

    # Validate the arguments
    Validate-Arguments $modules $folder

    # Redirect the standard error output of git commands to the standard output stream
    $env:GIT_REDIRECT_STDERR = '2>&1'
  }
  
  process {  
 
    # Get the list of subfolders in the folder path
    $folders = Get-ChildItem -Path $folder -Directory

    # Loop through each folder and run git status
    foreach ($f in $folders) {

      Check-GitStatus $f      
    }
}
    end
         {
 Pop-Location
    }

} 
