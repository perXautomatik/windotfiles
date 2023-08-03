[Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')
    
    # A function to run git commands and check the exit code
    function Invoke-Git {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Command # The git command to run
        )
        # Run the command and capture the output
        $output = Invoke-Expression -Command "git $Command" -ErrorAction Stop 
        # return the output to the host
        $output
        # Check the exit code and throw an exception if not zero
       if ($LASTEXITCODE -ne 0) {
            trow "Git command failed: git $Command"
        }
    }

function Check-Value { [CmdletBinding()] param (

    # Validate that the ref name is not null or empty
    [ValidateNotNullOrEmpty()]
    [string]$refName
)

    # Define a regex pattern to match the bad ref output
    $regex = 'bad ref (.*) [\(]'

    # Invoke the git show-ref command and redirect the error output to the standard output
    $srefs= (Invoke-git 'show-ref')

    # Check if the output matches the regex pattern
    if ($srefs -match $regex) {
        # Get the matched group value
        try {
            $matchedRef = $Matches[1]
        }
        catch {
            Write-Output $output
        }
        if ($matchedRef)
        {

            # Check if the matched ref is the same as the ref name parameter
            if ($matchedRef -eq $refName) {
                # Write an error message to indicate that the ref name does match the bad ref output
                Write-Error "The ref name $refName does match the bad ref output: $output"
            }
            else {
            # Construct a message to update the ref to HEAD
                $message = "Updating reference $matchedRef to HEAD"

                # Write the message to the output
                Write-Output $message

                # Invoke the git update-ref command to update the ref to HEAD
                git update-ref $matchedRef HEAD

                # Recursively call the function with the new last value
                Check-Value -refName $matchedRef
            }
        }
    }
    else {
        # Write an error message to indicate that the git show-ref command did not produce a bad ref output
        Write-Error "The git show-ref command did not produce a bad ref output: $output"
    }
}