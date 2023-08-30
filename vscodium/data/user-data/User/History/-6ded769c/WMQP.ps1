

function Git-FindObject {
  param ([string]$grepThis)
  
 git log -t --find-object=$grepThis | ?{ $zxc = $_ ;$null -ne ('commit' | ? { $zxc -match $_ })  }

 }
 
 cls

git log --pretty=format:"%H" | select -First 1  | %{ Git-LsTree $_ }  | select -First 1 | % { Git-FindObject -grepThis $_.objectId }

