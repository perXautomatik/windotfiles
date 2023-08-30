# Synopsis: Sets the execution policy for the current process to bypass
function Set-ProcessExecutionPolicy {
    [CmdletBinding()]
    param()
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
}

# Synopsis: Imports the Split-TextByRegex and keyPairTo-PsCustom functions from the specified paths
function Import-Functions {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Paths
    )
    foreach ($Path in $Paths) {
        . $Path
    }
}

# Synopsis: Splits the text from a file by a regular expression and returns an array of custom objects with key-value pairs
function Get-TextRanges {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Mandatory=$true)]
        [string]$Regex
    )
    $Text = Get-Content -Path $FilePath -Raw
    $Matches = [regex]::Matches($Text, $Regex, 'Multiline')
    $TextRanges = @()
    foreach ($Match in $Matches) {
        $Start = $Match.Index
        $End = $Match.NextMatch().Index
        if ($End -eq 0) {
            $End = $Text.Length
        }
        $Length = $End - $Start
        $Value = $Text.Substring($Start, $Length)
        $TextRanges += [PSCustomObject]@{
            Start = $Start
            End = $End
            Value = $Value
        }
    }
    return $TextRanges
}

# Synopsis: Adds a git submodule to the current repository with the specified URL and path
function Add-GitSubmodule {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Url,
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    git submodule add -f $Url $Path
}

# Main script

# Set the execution policy to bypass for the current process
Set-ProcessExecutionPolicy

# Import the required functions from the specified paths
$FunctionPaths = "Z:\Project Shelf\Archive\ps1\Split-TextByRegex.ps1", "Z:\Project Shelf\Archive\ps1\keyPairTo-PsCustom.ps1"
Import-Functions -Paths $FunctionPaths

# Define the regex and the working path
$Regex = "submodule"
$WorkingPath = 'B:\ToGit\scoopbucket-presist'

# Change the current directory to the working path
Set-Location -Path $WorkingPath

# Get the path of the .gitmodules file
$GitModulesPath = Join-Path -Path $WorkingPath -ChildPath '.gitmodules'

# Split the text from the .gitmodules file by the regex and get an array of custom objects with key-value pairs
$TextRanges = Get-TextRanges -FilePath $GitModulesPath -Regex $Regex

# Convert each text range to a custom object with key-value pairs and add a git submodule for each one
$TextRanges | ForEach-Object {
    $CustomObject = keyPairTo-PsCustom -keyPairStrings $_.Value
    Add-GitSubmodule -Url $CustomObject.url -Path $CustomObject.path
}
