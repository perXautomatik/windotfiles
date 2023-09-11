. .\Validate-Path.ps1


. .\Repair-Git.ps1


. .\Process-Files.ps1

# Synopsis: A script to process files with git status and repair them if needed
# Parameter: Start - The start path to process
# Parameter: Modules - The path to the modules folder
param (
    [Parameter(Mandatory=$true)]
    [string]$Start,
    [Parameter(Mandatory=$true)]
    [string]$Modules
)

# Call the main function
Process-Files -Start $Start -Modules $Modules
