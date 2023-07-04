<#
.SYNOPSIS
Synchronizes the submodules with the config file.

.DESCRIPTION
This function synchronizes the submodules with the config file, using the Git-helper and ini-helper modules. The function checks the remote URLs of the submodules and updates them if they are empty or local paths. The function also handles conflicts and errors.

.PARAMETER GitDirPath
The path of the git directory where the config file is located.

.PARAMETER GitRootPath
The path of the git root directory where the submodules are located.

.PARAMETER FlagConfigDecides
A switch parameter that indicates whether to use the config file as the source of truth in case of conflicting URLs.
#>
function Sync-Git-Submodules {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $GitDirPath,

        [Parameter(Mandatory = $true)]
        [string]
        $GitRootPath,

        [Parameter(Mandatory = $false)]
        [switch]
        $FlagConfigDecides
    )

    # Import the helper modules
    Import-Module Git-helper
    Import-Module ini-helper

    # Get the config file content and select the submodule section
    $rootKnowledge = Get-IniContent -Path (Join-Path -Path $GitDirPath -ChildPath "config") | Select-Object -Property submodule

    # Change the current location to the git root directory
    Set-Location -Path $GitRootPath

    # Loop through each submodule in the config file
    foreach ($rootx in $rootKnowledge) {
        try {
            # Change the current location to the submodule path
            Set-Location -Path $rootx.path

            # Get the remote URL of the submodule
            $q = Get-GitRemoteUrl

            # Check if the remote URL is a local path or empty
            $isPath = Test-Path -Path $q -IsValid
            $isEmpty = [string]::IsNullOrEmpty($q)

            if ($isPath -or $isEmpty) {
                # Set the remote URL to the one in the config file and overwrite it
                Set-GitRemote -Url $rootx.url -Overwrite
            }
            else {
                # Check if the URL in the config file is a local path or empty
                $isConfigPath = Test-Path -Path $rootx.url -IsValid
                $isConfigEmpty = [string]::IsNullOrEmpty($rootx.url)

                if ($isConfigEmpty) {
                    # Append the submodule to the config file
                    $rootx | Add-IniElement -Path (Join-Path -Path $GitDirPath -ChildPath "config")
                }
                elseif ($isConfigPath) {
                    # Append the remote URL to the submodule and replace it in the config file
                    ($rootx + AppendProperty($q)) | Set-IniElement -Path (Join-Path -Path $GitDirPath -ChildPath "config") -OldElement $rootx
                }
                elseif ($rootx.url -notin $q.url) {
                    # Handle conflicting URLs
                    if ($FlagConfigDecides) {
                        # Use the config file as the source of truth and replace it in the submodule path
                        $rootx | Set-IniElement -Path (Join-Path -Path $rootx.path -ChildPath ".gitmodules") -OldElement $q
                    }
                    else {
                        # Throw an error for conflicting URLs
                        throw "Conflicting URLs: $($rootx.url) and $($q.url)"
                    }
                }
            }
        }
        catch {
            # Handle errors based on their messages
            switch ($_.Exception.Message) {
                "path not existing" {
                    return "uninitialized"
                }
                "path existing but no subroot present" {
                    return "already in index"
                }
                "path existing, git root existing, but git not recognized" {
                    return "corrupted"
                }
                default {
                    return $_.Exception.Message
                }
            }
        }
    }
}
