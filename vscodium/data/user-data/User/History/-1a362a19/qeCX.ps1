I can try to rewrite the pseudocode into powershell script. Here is my attempt:

# Import the submodule scripts for Git-helper and ini-helper
Import-Module Git-helper
Import-Module ini-helper

# Get the path of the git directory as a parameter
param (
    [Parameter(Mandatory=$true)]
    [string]$gitDirPath
)

# Get the git directory path using Get-GitDirPath function from Git-helper module
$root = Get-GitDirPath -Path $gitDirPath

# Get the content of the config file in the git directory as an ini object using Get-IniContent function from ini-helper module
# Select only the submodule section of the ini object
$rootKnowledge = Get-IniContent -Path ($root + '\config') | Select-Object -ExpandProperty submodule

# Change the current directory to the root directory of the git repository using Get-GitRootDir function from Git-helper module
cd (Get-GitRootDir -Path $gitDirPath)

# Loop through each submodule in the root knowledge
foreach ($rootx in $rootKnowledge) {
    # Try to execute the script block
    try {
        # Change the current directory to the submodule path
        cd $rootx.path
        # Get the remote url of the submodule using Get-GitRemoteUrl function from Git-helper module
        $q = Get-GitRemoteUrl
        # Check if the remote url is a path or not using PathNotUrl function from Git-helper module
        $isPath = PathNotUrl -Url $q
        # Check if the remote url is empty or not using IsEmpty function from ini-helper module
        $isEmpty = IsEmpty -Value $q
        # If the remote url is a path or empty, set the remote url to the submodule url using Set-GitRemote function from Git-helper module with Overwrite switch
        if ($isPath -or $isEmpty) {
            Set-GitRemote -Url $rootx.url -Overwrite
        }
        else {
            # If the remote url is not empty, check if the submodule url is a path or not using PathNotUrl function from Git-helper module
            if (PathNotUrl -Url $rootx.url) {
                # If the submodule url is a path, append the remote url as a property to the submodule object using AppendProperty function from ini-helper module
                # Replace the submodule element in the config file with the updated submodule object using Replace-IniElement function from ini-helper module
                ($rootx | AppendProperty -Name "remote" -Value $q) | Replace-IniElement -Path ($root + '\config') -Element $rootx
            }
            # If the submodule url is not a path, check if it is in the remote url using In operator
            if ($rootx.url -in $q.url) {
                # If it is in the remote url, check if there is a flag for config decides or not using Test-Flag function from ini-helper module
                if (Test-Flag -Name "configDecides") {
                    # If there is a flag for config decides, replace the submodule element in the submodule path with the submodule object using Replace-IniElement function from ini-helper module
                    Replace-IniElement -Path $rootx.path -Element $rootx
                }
                else {
                    # If there is no flag for config decides, throw an error for conflicting url
                    throw "conflicting url"
                }
            }
        }
    }
    catch {
        # Catch any errors and write them to the error stream using Write-Error cmdlet
        Write-Error $_.Exception.Message

        # Check if error is due to path not existing using Test-Path cmdlet with ErrorAction parameter set to SilentlyContinue
        if (-not (Test-Path -Path $rootx.path -ErrorAction SilentlyContinue)) {
            # Return "uninitialized" as output using Write-Output cmdlet
            Write-Output "uninitialized"
        }

        # Check if error is due to path existing but no subroot present using Test-SubRoot function from Git-helper module with ErrorAction parameter set to SilentlyContinue
        if (Test-Path -Path $rootx.path -ErrorAction SilentlyContinue -and -not (Test-SubRoot -Path $rootx.path -ErrorAction SilentlyContinue)) {
            # Return "already in index" as output using Write-Output cmdlet
            Write-Output "already in index"
        }

        # Check if error is due to path existing, git root existing, but git not recognized using Test-GitRoot and Test-Git functions from Git-helper module with ErrorAction parameter set to SilentlyContinue
        if (Test-Path -Path $rootx.path -ErrorAction SilentlyContinue -and Test-GitRoot -Path $rootx.path -ErrorAction SilentlyContinue -and -not (Test-Git -Path $rootx.path -ErrorAction SilentlyContinue)) {
            # Return "corrupted" as output using Write-Output cmdlet
            Write-Output "corrupted"
        }
    }
}