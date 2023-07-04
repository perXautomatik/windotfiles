
function filterByName ($pattern)
{
    $filter = "";
    $filter = "git ls-files -x " +""""+ "$pattern" +""""+ " | xargs -r git rm"
    Write-Output ("|||" + $filter)
    $exec = "";
    Write-Output "--exec--"
    $exec = "git filter-branch --index-filter " +"'"+ "$filter" +"'"+ "--prune-empty --tag-name-filter cat -- --all"
    Write-Output ("||" + $exec)
    #$exec = $filter
    $u = Invoke-Expression $exec
    $u | ?{ $_ -match "index filter failed" }
}