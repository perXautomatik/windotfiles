<#
.SYNOPSIS
Extracts submodules from a git repository.

.DESCRIPTION
Extracts submodules from a git repository by moving the .git directories from the submodules to the parent repository and updating the configuration.

.PARAMETER Paths
The paths of the submodules to extract. If not specified, all submodules are extracted.

.EXAMPLE
Extract-Submodules

.EXAMPLE
Extract-Submodules "foo" "bar"
#>
function Extract-Submodules {
    param (
        [string[]]$Paths
    )

    # get the paths of all submodules if not specified
    if (-not $Paths) {
        $Paths = Get-SubmodulePaths
    }

    # loop through each submodule path
    foreach ($Path in $Paths) {
        # check if the submodule has a .git file
        if (Test-Path -Path "$Path/.git" -PathType Leaf) {
            # get the absolute path of the .git directory
            $GitDir = Get-GitDir -Path $Path

            # check if the .git directory exists
            if (Test-Path -Path $GitDir -PathType Container) {
                # display the .git directory and the .git file
                Write-Host "$GitDir`t$Path/.git"

                # move the .git directory to the submodule path
                Move-Item -Path $GitDir -Destination "$Path/.git" -Force -Backup

                # unset the core.worktree config for the submodule
                Unset-CoreWorktree -Path $Path

                # remove the backup file if any
                Remove-Item -Path "$Path/.git~" -Force -ErrorAction SilentlyContinue

                # hide the .git directory on Windows
                Hide-GitDir -Path $Path
            }
        }
    }
}
