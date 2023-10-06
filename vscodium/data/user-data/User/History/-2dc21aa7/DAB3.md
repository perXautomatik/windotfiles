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

function CreateMultpleBranches
{
    param(
        $dictionary<$branchName,$ref> 
        [verifyscript] $branchName no duplicates
        [verifyScript] no $branchName is same as repo's branches
    )

    for each in $dictionary<$branchName,$ref>
        git create a new branch by $branchName (without checking out to it)
        if successful
            set $branchname head to $ref
            return $branchName
        else
            throw error "failed to create $branchName"
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
    git get relative path of $branchName head
}

function getRepoBranchNames()
{
    git branches
    return  <BranchName, branch head ref>
}


param(
dictionary $rp<relativepath, alias>
)

$branches = getRepoBranchNames

for each $BranchName in $branches
    $relPath = getBranchHeadPaths($branch)

    $relPath = $relPath ? { $_.match $rp.relativepath }
    
    for each relative paths $rp matched with input array

        $nameArray = ("baseName","branchname","relative path")
        createa a new branch : name = createValidBranchName $nameArray, @"{1}_{2}-{3}" -checkAgainstRepo
        valid branch name


