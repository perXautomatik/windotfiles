function git-status ($path)
{

    begin
    {

        # Validate the arguments
        if (-not (Test-Path $path)) { 
        Write-Error "Invalid path: $path"
        exit 1
        }
        Push-Location

        # Redirect the standard error output of git commands to the standard output stream
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

    }
    process {

    
            # Change the current directory to the path
            Set-Location $path;
                # Define a function to run git commands and check the exit code    
            # Run git status and capture the output
            $output = invoke-git 'status'

            # Check if the output is fatal
            if($output -like "fatal*")
            {
                # Print a message indicating fatal status
                Write-Output "fatal status for $path"
            }
            else
            {
                $path | Add-Member -MemberType NoteProperty -Name GitStatus -Value $output -PassThru
            }
    }
    end {
        # Restore the original location
        Pop-Location
    }
}