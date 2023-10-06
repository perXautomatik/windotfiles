function createValidBranchName 
{
    param(
        mandator string[] $array,
        mandator string $stringEmbedding,
        notmandator $repoPath
        flagg $checkAgainstRepo
    )

    $returnName = taking the array and using the stringEmbedding to create a final string

    $returnName = trim to lenght suitable for a gitbranch name
    
    $returnName = remove unsuitable chars not supported for a gitbranch name, 

    if $checkAgainstRepo
        if $repoPath is provided
            cd to $repoPath
            check if $returnName already exsists among branch names in repo
                throw error
    else
        retun $returnName
}

function setRemote 
{
    param(
        [mandatory] string $remoteUrl 
        [accept value from pipeline] $trackingBranch 
        ) 
        git set remote $remoteUrl $trackingbranch
}

function getBranchHeadPaths($branchName)
{
    $paths = git get relative paths of $branchName head
    return $paths
}

function getRepoBranchNames()
{
    git branches
    return  <BranchName, branch head ref>
}


function CreateMultpleBranches
{
    param(
        $dictionary<$branchName,$ref> 
        [verifyscript] $branchName no duplicates in $dictionary
        [verifyScript] no $branchName in $dictionary is same as repo's branches
    )

    for each in $dictionary<$branchName,$ref>
        git create a new branch by $branchName (without checking out to it)
        if successful
            set $branchname head to $ref
            return $branchName
        else
            throw error "failed to create $branchName"
}


<# main script ------------------------------>

param(
dictionary $rp<relativepath, alias>
)

$branches<$branchName,$ref>  = getRepoBranchNames

$successful = @()
for each $BranchName<$branchName,$ref> in $branches
{
    $relPath = getBranchHeadPaths($BranchName.BranchName)
    $relPath = $relPath ? { $_.match $rp.relativepath }

    $creationArray = @()
    for each $rPath in $relPath {
        $nameArray = @($relPath.baseName,$BranchName.BranchName,$relPath.parent)
        $name = createValidBranchName $nameArray, @"{1}_{2}-{3}" -checkAgainstRepo
        $creationArray =+ <$name,$branchName.ref>
    }

    CreateMultpleBranches($creationArray) | % { $successful += $_ } 
}




