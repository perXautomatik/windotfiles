<# 
pseudo. 
example history file, 
due to each feature might have different relevance, 
and chaning order does not maintain history, 
and to recherrypcik is probably the best way to maintain blame

# Synopsis: Reorder the history of a git repository by cherry-picking commits

# Example usage: Reorder the history of a git repository in C:\Users\user\Documents\MyProject by cherry-picking commits with hashes 123456, 789abc, 456def, and 9abcef

Reorder-History -Path "C:\Users\user\Documents\MyProject" -Commits "123456", "789abc", "456def", "9abcef"
#>
function Reorder-History {
    param(
        # The path to the git repository
        [string]$Path,

        # The list of commit hashes to cherry-pick in the desired order
        [string[]]$Commits
    )

    # Change directory to the git repository
    Push-Location $Path

    # Create a new branch with the first commit in the list
    git checkout -b reordered ${Commits[0]}

    # Cherry-pick the rest of the commits in the list
    foreach ($commit in $Commits[1..($Commits.Length - 1)]) {
        git cherry-pick $commit
    }

    # Change directory back to the original location
    Pop-Location
}
