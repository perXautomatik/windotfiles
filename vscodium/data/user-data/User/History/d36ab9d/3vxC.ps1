function Invoke-Git {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Command # The git command to run
    )
    # Run the command and capture the output
    $output = Invoke-Expression -Command "git $Command 2>&1" -ErrorAction Stop 
    # return the output to the host
    $output
    # Check the exit code and throw an exception if not zero
   if ($LASTEXITCODE -ne 0) {
        trow "Git command failed: git $Command"
    }
}