
  
function cherryPick-byPattern
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]#mandatory
        [String]
        $pattern,
        [Parameter (Mandatory=$false)] 
        [String]$path
    )

    process{
        if ($path) { cd $path }
        
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