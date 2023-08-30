# Synopsis: Changes the current directory to the specified path
function Set-CurrentDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    Set-Location -Path $Path
}

# Synopsis: Applies a git patch file and commits it if it is applied cleanly, otherwise prompts the user to continue
function Apply-GitPatch {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FileName
    )
    # Apply the patch file with the specified options and redirect the error output to a text file
    git apply --3way --ignore-space-change --ignore-whitespace -check $FileName 2>er.txt
    # Get the last line of the error output
    $LastLine = Get-Content .\er.txt | Select-Object -Last 1
    # Check if the patch was applied cleanly
    if ($LastLine -eq "Applied patch PSReadline/ConsoleHost_history.txt cleanly.") {
        # Move the patch file to a folder named cleanly
        Move-Item -Path $FileName -Destination cleanly
        # Commit the changes with an empty message
        git commit -m ''
    }
    else {
        # Prompt the user to continue
        Read-Host "Press enter to continue..."
    }
}

# Main script

# Change the current directory to the specified path
$CurrentDirectory = 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell'
Set-CurrentDirectory -Path $CurrentDirectory

# Get the first patch file in the current directory and apply it
Get-ChildItem -Filter *.patch | Select-Object -First 1 | ForEach-Object {
    Apply-GitPatch -FileName $_.Name
}
