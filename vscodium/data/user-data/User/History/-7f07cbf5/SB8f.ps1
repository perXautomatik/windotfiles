function CloneWithReference() {
    [CmdletBinding()]
    PARAM( $repo, $objectRepo, $path )
    begin{
        # Validate the arguments
        if (-not (Test-Path $path)) { 
            Write-Error "Invalid path: $path"
            exit 1
        }

        $env:GIT_REDIRECT_STDERR = '2>&1'

        function Invoke-Git {
            param(
            [string]$Command # The git command to run
            )
                # Run the command and capture the output
                $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop
                # return the output to the host
                $output
                # Check the exit code and throw an exception if not zero
                if ($LASTEXITCODE -ne 0) {
                throw "Git command failed: git $Command"
            }
        }
        Push-Location
    }
    process{

        cd $path
        #To clone a repository into a folder without creating a subdirectory, you can use the git clone command with the .
        $outputx = invoke-git "clone --reference $objectRepo $repo ."
        
    }
    end {
        Pop-Location
        return ([System.IO.Path]::GetFileName($path) | Add-Member -MemberType NoteProperty -Name GitStatus -Value $outputx)
    }        
}

 