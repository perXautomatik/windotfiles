<# Synopsis: Permanently rewrite history to only include what's dictated in filter

# Example usage: Permanently rewrite history in C:\Users\user\Documents\MyProject to only include files in Organized\SolVision and exclude files that match SolVision

Rewrite-History -Path "C:\Users\user\Documents\MyProject" -IndexFilter 'git ls-files | grep -v "^SolVision" | xargs --no-run-if-empty git rm --cached' -SubdirectoryFilter 'Organized/SolVision'
#>
function Rewrite-History {
    param(
        # The path to the git repository
        [string]$Path,

        # The index filter to apply
        [string]$IndexFilter,

        # The subdirectory filter to apply
        [string]$SubdirectoryFilter
    )

    # Change directory to the git repository
    Push-Location $Path

    # Rewrite history with the index filter and the subdirectory filter
    git filter-branch --index-filter $IndexFilter --subdirectory-filter $SubdirectoryFilter

    # Change directory back to the original location
    Pop-Location
}
