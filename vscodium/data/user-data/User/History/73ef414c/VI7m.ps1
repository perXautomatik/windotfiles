
  
function cherryPick-byPattern
{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $pattern,
        [string]
        $path
        [mandatory = false]
    )
    process{
        $latest = Invoke-Expression "git rev-parse HEAD"

        $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"
        $last = @($hashesThatToutches)[-1]
        if ($last -eq $latest)
        {
            # Write an error message to the standard error stream                        
            throw "$last -eq $latest"
        }

        $last 
        git checkout -b $pattern $last


    }
}