function config-to-gitmodules {
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

    $configPath = (Join-Path -Path $GitDirPath -ChildPath "config")

    # Get the config file content and select the submodule section
    $rootKnowledge = Get-IniContent -Path $configPath | Select-Object -Property submodule

    # Change the current location to the git root directory
    Set-Location -Path $GitRootPath

    # Loop through each submodule in the config file
    foreach ($rootx in $rootKnowledge) {
        try {
            # Change the current location to the submodule path
            Set-Location -Path $rootx.path

            # Get submodule name and path from ini object properties $submoduleName = $submodule.submodule.Name
            if(Import-Module PsIni)
            {
                # Import the PsIni module
                $submodules = Get-IniContent -Path ".gitmodules" | Select-Object -Property submodule
            }
            
            if(Import-Module PsIni)
            {
                # Import the PsIni module
                $submodulePath = Join-Path -Path (Split-Path -Path ".gitmodules") -ChildPath ($submodule.submodule.path)
            }


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
                    $rootx | Add-IniElement -Path $configPath
                }
                elseif ($isConfigPath) {
                    # Append the remote URL to the submodule and replace it in the config file
                   # ($rootx + AppendProperty($q)) | Set-IniElement -Path $configPath -OldElement $rootx
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