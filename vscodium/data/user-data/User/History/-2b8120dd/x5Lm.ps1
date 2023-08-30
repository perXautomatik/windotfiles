
  
function Revert-byPattern
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]#mandatory
        [String]
        $pattern,
        [Parameter (Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
       # [ValidateScript({$_ | Resolve-Path})]
        [String]$branch
    )
    begin{
        $pattern = $pattern.trim()
        if ($branch) {
            $branch = $branch.trim()    
            git checkout master
            $hashesThatToutches = @( Invoke-Expression "git log --follow --format=%H -- $pattern" )
            $checkout = invoke-expression "git checkout $branch"
            if(!(($checkout[-1] -match "Switched to ") -or ($checkout -match "Switched to ")))
            {
                throw $checkout
            }
        }


        #If you want to see the log of the revision, you can use:
        $hashesOfbranch = @( Invoke-Expression "git rev-list $branch --")
        $hashesOfbranch.Count / $hashesThatToutches.Count
        
    }
    process{

        
        $notInMatch = $hashesOfbranch | ? { $_ -cnotin $hashesThatToutches  }
        
        $notInMatch | % { 
            $sha = $_
            $c =  invoke-expression "git clean -f" ; 
            $re =  invoke-expression "git reset --hard $branch --"
            $s =  invoke-expression "git branch --show-current" ;   

            $r = invoke-expression "git revert $sha --" ;             
            $o = invoke-expression ("git commit -m " + """" + "revert $sha" + """")}
        ".... rewriting  .... "
            $r
        "-|rewrote: $branch"
        }
}