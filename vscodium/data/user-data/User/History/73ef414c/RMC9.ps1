
function cherryPick-byPattern ($pattern)
{
    $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"

    $last = ( $hashesThatToutches | select -last 1 )
    $last 
    git checkout -b $pattern $last
    
}