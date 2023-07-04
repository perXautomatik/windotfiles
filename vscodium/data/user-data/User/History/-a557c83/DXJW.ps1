
function filterByName ($pattern)
{
    git config --local FILTER_BRANCH_SQUELCH_WARNING=1
    $env:FILTER_BRANCH_SQUELCH_WARNING = 1

    $filter = "";
    $filter = "git ls-files -x " +""""+ "$pattern" +""""+ " | xargs -r git rm --ignore-unmatch"
    Write-Output ("|||" + $filter)
    $exec = "";
    Write-Output "--exec--"
    $exec = "git filter-branch --index-filter " +"'"+ "$filter" +"'"+ "--prune-empty --tag-name-filter cat -- --all"
    Write-Output ("||" + $exec)
    #$exec = $filter
    $u = Invoke-Expression $exec 

    
    $q = $u | ?{ $_ -match "fatal:" }
    if($q)
    {
        Write-Error "failed Filtering: $q"
    }
    else
    {
        $u
    }



}