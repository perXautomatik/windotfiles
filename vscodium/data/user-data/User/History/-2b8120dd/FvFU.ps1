
  
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
            $checkout = invoke-expression "git checkout $branch"
            if(!($checkout[-1] -match "switched to branch"))
            {
                throw $checkout
            }
        }

        $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"
        "If you want to see the log of the revision, you can use:"
        $hashesOfbranch = Invoke-Expression "git rev-list $branch --"
        $last = @($hashesThatToutches)[-1]

        if ($last -eq $latest)
        {
            # Write an error message to the standard error stream                        
            throw "$last -eq latest"
        }
        if ($last -in $first)
        {
            # Write an error message to the standard error stream                        
            throw "$last -eq first"
        }
    }
    process{

        
        $notInMatch = $hashesOfbranch | ? { $_ -cnotin $hashesThatToutches  }
        "-----rewerting------"
        $notInMatch | % { 
            $sha = $_
          $c =  invoke-expression "git clean -f" ; 
          $re =  invoke-expression "git reset --hard $branch --"
            $r = invoke-expression "git revert $sha" ; 
            $s =  invoke-expression "git branch --show-current" ; 
            $o = invoke-expression ("git commit -m " + """" + "revert $sha" + """")}
        "-----done rewerting------"


    }
}