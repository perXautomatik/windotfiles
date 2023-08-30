# Get the parameters from the user
param (
    [string]$GitDir, # The path to the .git directory
    [string]$X # The path to the destination folder
)

# Check if the parameters are valid
if (-not (Test-Path $GitDir -PathType Container)) {
    Write-Error "Invalid .git directory: $GitDir"
    exit
}

if (-not (Test-Path $X -PathType Container)) {
    Write-Error "Invalid destination folder: $X"
    exit
}

# Get the path to the modules folder inside the .git directory
$ModulesDir = Join-Path $GitDir "modules"

# Check if the modules folder exists
if (-not (Test-Path $ModulesDir -PathType Container)) {
    Write-Error "No modules folder found in $GitDir"
    exit
}

# Get the list of module names from the modules folder
$ModuleNames = Get-ChildItem $ModulesDir -Name

# Loop through each module name
foreach ($ModuleName in $ModuleNames) {
    # Create a new subfolder at X with the module name
    $NewSubfolder = Join-Path $X $ModuleName
    New-Item -ItemType Directory -Path $NewSubfolder -Force

    # Create a new git file with the gitdir line pointing to the module directory
    $NewGitFile = Join-Path $NewSubfolder ".git"
    $ModuleDir = Join-Path $ModulesDir $ModuleName
    "gitdir: $ModuleDir" | Out-File -FilePath $NewGitFile -Encoding ASCII

    # Write a message to indicate the progress
    Write-Host "Created subfolder and git file for module: $ModuleName"
}

# Write a message to indicate the completion
Write-Host "Done!"
