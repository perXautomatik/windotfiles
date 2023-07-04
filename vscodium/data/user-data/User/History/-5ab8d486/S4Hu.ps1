<# Synopsis: Recursively identify nested git repositories and remove them if not already added as submodules to parent

# Example usage: Remove nested repositories in C:\Users\user\Documents\MyProject that are not submodules

Remove-NestedRepos -Path "C:\Users\user\Documents\MyProject"

#>
function Remove-NestedRepos {
    param(
        # The path to the parent directory that contains the git repository
        [string]$Path
    )

    # Check if the path is a valid git repository
    if (-not (Test-Path "$Path\.git")) {
        Write-Error "No git repository found in $Path"
        return
    }

    # Get all the subdirectories in the path
    $subdirs = Get-ChildItem -Directory -Recurse -Path $Path

    # Filter out the subdirectories that are not git repositories
    $subrepos = $subdirs | Where-Object { Test-Path "$_\.git" }

    # Return 0 if no nested git repositories are found
    if ($subrepos.Count -eq 0) {
        Write-Output 0
        return
    }

    # For each nested git repository, check if it is a submodule of the parent repository
    foreach ($subrepo in $subrepos) {
        # Get the relative path of the subrepository from the parent repository
        $relativePath = $subrepo.FullName.Replace($Path, "").Trim("\\")

        # Check if the subrepository is listed as a submodule in the parent repository's config file
        $isSubmodule = git config --file "$Path\.gitmodules" --get-regexp "path" | Where-Object { $_ -match $relativePath }

        # If the subrepository is not a submodule, remove it from the file system
        if (-not $isSubmodule) {
            Remove-Item -Recurse -Force -Path $subrepo.FullName
            Write-Output "Removed nested repository at $relativePath"
        }
    }
}
