
function cherryPick-byPattern ($pattern)
{
    $latest = Invoke-Expression "git rev-parse HEAD"

    $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"
    $last = ( $hashesThatToutches | select -last 1 )
    if ($last -eq $latest)
    {
          # Write an error message to the standard error stream
          Write-Error "$last -eq $latest"
          # Exit with a non-zero exit code
          exit 1
    }

    $last 
    git checkout -b $pattern $last
    
}