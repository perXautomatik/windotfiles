# This function gets the files from the current directory
function Get-Files {
  [CmdletBinding()]
  param()

  Get-ChildItem -File
}

# This function groups the files by the part before the first underscore or optional parentheses
function Group-Files {
  [CmdletBinding()]
  param(
    # The files to group
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [System.IO.FileInfo[]]$Files
  )

  begin {
    # Create a regex pattern to match the part before the first underscore or optional parentheses
    $pattern = '^(.*?)[_][(]?\d*[)]?$'
  }

  process {
    # Group the files by the pattern
    $Files | Group-Object { $_.Name -match $pattern; $Matches[1] }
  }
}

# This function creates a folder from a file name and moves the file there
function Move-FileToFolder {
  [CmdletBinding()]
  param(
    # The file to move
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [System.IO.FileInfo]$File,

    # The folder name to create
    [Parameter(Mandatory=$true)]
    [string]$FolderName
  )

  begin {
    # Validate the folder name parameter
    if (-not $FolderName) {
      throw "Folder name cannot be empty"
    }
  }

  process {
    # Create the folder if it does not exist
    $folder = New-Item -Type Directory -Name $FolderName -ErrorAction SilentlyContinue

    # Move the file to the folder
    Move-Item -Path $File.FullName -Destination $folder.FullName
  }
}

# This is the main script that calls the functions
Get-Files | Group-Files | ForEach-Object {
  # For each group of files, get the folder name and move the files there
  $folderName = $_.Name
  $_.Group | Move-FileToFolder -FolderName $folderName
}
