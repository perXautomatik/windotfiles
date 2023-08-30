given two repo paths $repo1, $repo2

$repo1Trees = each tree in $repo1
$repo2Trees = each tree in $repo2

cross join $repo1Trees, $repo2Trees into $treePairs as path1,path2,sha1,sha2

for each pair in $treepairs
    $summary = git dif sha1,sha2 
    