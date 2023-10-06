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
        $arrayB
    )
    


}


taken a dictionary data structure <relativepath, alias>

taken an array of filenames #( file location of relevant )
for each branch
    for each relative paths matched with input array
        createa a new branch : name = (base name_ branchname - relative path ) 
        valid branch name


