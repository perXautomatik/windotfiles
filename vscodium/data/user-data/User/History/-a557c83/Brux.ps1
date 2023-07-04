
function filterByFilePath ($pattern)
{
    $env:FILTER_BRANCH_SQUELCH_WARNING = 1

    $filter = "";
    $filter = "git ls-files -x " +""""+ "$pattern" +""""+ " | xargs -r git rm --ignore-unmatch"
    Write-Output ("|||" + $pattern)
    $exec = "";
    #Write-Output "--exec--"
    $exec = "git filter-branch --index-filter " +"'"+ "$filter" +"'"+ "--prune-empty --tag-name-filter cat -- --all"
    #Write-Output ("||" + $exec)
    #$exec = $filter
    $u = Invoke-Expression $exec 

    
    $q = $u | ?{ $_ -match "fatal:" }
    if($q)
    {
        Write-Error "failed Filtering: $q"
    }
    else
    {
        $u  | ?{ $_ -match "was rewritten" } 
        $q = ( $u  | ?{ $_ -match "was rewritten" } | % { ($_ -split "'")[1] } | select -first 1 ).toString()
        $ua = Invoke-Expression ("git checkout " + $q)
        $ua | ?{$_ -match "HEAD is now at"}
    }

}

function filterByName ($pattern)
{
    $env:FILTER_BRANCH_SQUELCH_WARNING = 1
    
    $pattern = [System.IO.Path]::GetFileName($pattern)


    $filter = "";
    $filter = "git ls-files -x " +""""+ "$pattern" +""""+ " | xargs -r git rm --ignore-unmatch"
    Write-Output ("|||" + $pattern)
    $exec = "";
    #Write-Output "--exec--"
    $exec = "git filter-branch --index-filter " +"'"+ "$filter" +"'"+ "--prune-empty --tag-name-filter cat -- --all"
    #Write-Output ("||" + $exec)
    #$exec = $filter
    $u = Invoke-Expression $exec 

    
    $q = $u | ?{ $_ -match "fatal:" }
    if($q)
    {
        Write-Error "failed Filtering: $q"
    }
    else
    {
        $u  | ?{ $_ -match "was rewritten" } 
        $q = ( $u  | ?{ $_ -match "was rewritten" } | % { ($_ -split "'")[1] } | select -first 1 ).toString()
        $ua = Invoke-Expression ("git checkout " + $q)
        $ua | ?{$_ -match "HEAD is now at"}
    }

}