# Synopsis: Creates one or more new branches in a git repository.
# Parameters:
#   -Branches: A dictionary of branch names and refs.
#   -RemotePath: The path to the remote repository.
function Create-MultipleBranches {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateScriptOfProperty(Name, 'BranchNameIsUnique', $Branches)]
        [ValidateScriptOfProperty(BranchName, 'BranchNameIsNotInRepo', $Branches)]
        [Dictionary[string, string]] $Branches,
        [Parameter(Mandatory=$true)]
        [string] $RemotePath
    )

    $successful = @()
    foreach ($branch in $Branches) {
        $branchName = $branch.Key
        $branchRef = $branch.Value

        # Create the branch.
        $result = Try-Invoke { git checkout -b $branchName }
        if ($result.Exception) {
            throw "Failed to create branch '$branchName': $result.Exception.Message"
        }

        # Set the branch head to the ref.
        $result = Try-Invoke { git branch --set-upstream-to=$branchRef $branchName }
        if ($result.Exception) {
            throw "Failed to set upstream for branch '$branchName': $result.Exception.Message"
        }

        $successful += $branchName
    }

    # Set the remote for all of the branches.
    Set-Remote -RemoteUrl $RemotePath -Branches $successful
}

# Synopsis: Validates that a branch name is unique among the branches in the dictionary.
# Parameters:
#   -BranchName: The branch name to validate.
#   -Branches: The dictionary of branches to check against.
function BranchNameIsUnique {
    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [Parameter(Mandatory=$true)]
        [Dictionary[string, string]] $Branches
    )

    if ($Branches.ContainsKey($BranchName)) {
        throw "The branch name '$BranchName' is already in use."
    }

    return $true
}

# Synopsis: Validates that a branch name is not already in the repository.
# Parameters:
#   -BranchName: The branch name to validate.
#   -Branches: The dictionary of branches in the repository.
function BranchNameIsNotInRepo {
    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [Parameter(Mandatory=$true)]
        [Dictionary[string, string]] $Branches
    )

    $repoBranches = Get-RepoBranchNames
    if ($repoBranches.ContainsKey($BranchName)) {
        throw "The branch name '$BranchName' is already in use in the repository."
    }

    return $true
}

# Synopsis: Gets the relative paths of the branches in the repository.
# Returns: A dictionary of branch names and relative paths.
function Get-RepoBranchNames {
    $branches = @()
    $branchNames = git branch | Out-String -Stream | Select-String -Pattern '^[*]\s+(.+)' | Where-Object { $_.Matches.Count -eq 1 } | Select-Object -ExpandProperty Matches
    foreach ($branchName in $branchNames) {
        $branchRef = git rev-parse $branchName
        $branches += New-Object PSObject -Property @{
            BranchName = $branchName
            Ref = $branchRef
        }
    }

    return $branches
}

# Synopsis: Sets the remote for the given branches.
# Parameters:
#   -RemoteUrl: The URL of the remote repository.
#   -Branches: The branches to set the remote for.
function Set-Remote {
    param(
        [Parameter(Mandatory=$true)]
        [string] $RemoteUrl,
        [Parameter(Mandatory=$true)]
        [string[]] $Branches
    )

    foreach ($branch
