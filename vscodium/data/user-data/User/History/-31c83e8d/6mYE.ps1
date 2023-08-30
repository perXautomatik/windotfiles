<#
.SYNOPSIS
Changes the name and email of a git committer and author.

.DESCRIPTION
This function changes the name and email of a git committer and author for all commits that match the old name, using the git filter-branch command. The function will rewrite the history of the current branch.

.PARAMETER OldName
The old name of the git committer and author.

.PARAMETER NewName
The new name of the git committer and author.

.PARAMETER NewEmail
The new email of the git committer and author.
#>
function Change-Git-Name-Email {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $OldName,

        [Parameter(Mandatory = $true)]
        [string]
        $NewName,

        [Parameter(Mandatory = $true)]
        [string]
        $NewEmail
    )

    # Define the commit filter script as a string
    $commitFilter = @"
if [ `"$GIT_COMMITTER_NAME`" = `"$OldName`" ]; then
    GIT_COMMITTER_NAME=`"$NewName`";
    GIT_AUTHOR_NAME=`"$NewName`";
    GIT_COMMITTER_EMAIL=`"$NewEmail`";
    GIT_AUTHOR_EMAIL=`"$NewEmail`";
    git commit-tree `"$@`";
else
    git commit-tree `"$@`";
fi
"@

    # Invoke the git filter-branch command with the commit filter script
    git filter-branch --commit-filter $commitFilter HEAD
}
