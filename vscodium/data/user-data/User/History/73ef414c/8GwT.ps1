
function cherryPick-byPattern ($pattern)
{
    $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"

    $last = ( $hashesThatToutches | select -last 1 )

     git checkout -b $pattern
    
}