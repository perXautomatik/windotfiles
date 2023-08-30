
function cherryPick-byPattern ($pattern)
{
    $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"

    git log --follow --format=%H -- $pattern | git checkout -b $pattern --stdin 
    
}