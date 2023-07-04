
  
function Revert-byPattern
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]#mandatory
        [String]
        $pattern,
        [Parameter (Mandatory=$false)] 
       # [ValidateScript({$_ | Resolve-Path})]
        [String]$branch
    )

    process{
        if ($branch) { git checkout $branch }

        $hashesThatToutches = Invoke-Expression "git log --follow --format=%H -- $pattern"
        $hashesOfbranch = Invoke-Expression "git rev-list $branch"
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
        
        $notInMatch = $hashesOfbranch | ? { $_ -cnotin $hashesThatToutches  }
        "-----rewerting------"
        $notInMatch | % { invoke-expression "git revert $_" ; invoke-expression "git branch --show-current" ; invoke-expression ("git commit -m " + """" + "revert $_" + """")}
        "-----done rewerting------"


    }
}