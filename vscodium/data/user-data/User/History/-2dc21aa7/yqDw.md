# Synopsis
# Creates multiple branches from a dictionary of relative paths and aliases, and sets the remote for each branch.

# Parameters
# -rp: A dictionary of relative paths and aliases.
# -remotePath: The path to the remote repository.

param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateScript({
        if ($_ -eq $null) {
            throw new Exception("The 'rp' parameter is required.")
        }

        if (!$_.Keys.All({ $_ -is [String] })) {
            throw new Exception("The 'rp' parameter must be a dictionary of strings and strings.")
        }

        if (!$_.Values.All({ $_ -is [String] })) {
            throw new Exception("The 'rp' parameter must be a dictionary of strings and strings.")
        }
    })]
    [Dictionary[string, string]] $rp,

    [Parameter(Mandatory=$true)]
    [ValidateScript({
        if ($_ -eq $null) {
            throw new Exception("The 'remotePath' parameter is required.")
        }

        if (!Test-Path -Path $_) {
            throw new Exception("The 'remotePath' parameter must be a valid path to a remote repository.")
        }
    })]
    [string] $remotePath
)

# Get the branch names and refs from the remote repository.
$branches = Get-RepoBranchNames -RemotePath $remotePath

# Create an array of branch creation objects.
$creationArray = @()
foreach ($branch in $branches) {
    $relPath = Get-BranchHeadPaths($branch.BranchName)
    $relPath = $relPath.Where({ $_.match($rp.relativePath) })

    foreach ($rPath in $relPath) {
        $nameArray = @($rPath.BaseName, $branch.BranchName, $rPath.Parent)
        $name = Create-ValidBranchName $nameArray -StringEmbedding @"{1}_{2}-{3}" -CheckAgainstRepo

        $creationArray += New-Object PSScriptBlock {
            Param(
                [Parameter(Mandatory=$true)]
                [string] $BranchName,

                [Parameter(Mandatory=$true)]
                [string] $Ref,

                [Parameter(Mandatory=$true)]
                [string] $RelPath
            )

            Process {
                git branch --no-track $BranchName

                if (git checkout $BranchName) {
                    git filter-repo --ref $BranchName --path $RelPath
                    git push $remotePath $BranchName
                } else {
                    throw new Exception("Failed to checkout branch '$BranchName'.")
                }
            }
        }

        $creationArray.args += $name, $branch.Ref, $rPath
    }
}

# Create the branches and set the remotes.
Create-MultipleBranches -Dictionary $creationArray -RemotePath $remotePath

# Filter the branches and push them to the remote repository.
foreach ($successful in $successful) {
    try {
        git filter-repo --ref $successful.branchName --path $successful.relPath
        git push $remotePath $successful.branchName
        Write-Host "$remotePath : $successful.branchName"
    } catch {
        Write-Error "Failed to filter and push branch '$successful.branchName': $_"
    }
}
