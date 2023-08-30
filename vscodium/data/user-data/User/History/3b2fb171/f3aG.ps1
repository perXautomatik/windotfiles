<#
.SYNOPSIS
This script clones a source folder as a git repository and filters it by a file name.

.DESCRIPTION
This script takes four parameters: SourceParent, SourceParentName, ToFilterBy and parentName. It uses git commands to clone the source folder as a bare repository in a temporary folder and then configures it as a normal repository. It then commits all the files in the source folder and filters them by the file name using git filter-branch command. It also removes the original references and adds the source folder as a remote.

.PARAMETER SourceParent
The path of the source folder to clone.

.PARAMETER SourceParentName
The name of the source folder to use as a remote.

.PARAMETER ToFilterBy
The name of the file to filter by.

.PARAMETER parentName
The name of the parent folder to use as a repository.

.EXAMPLE
Clone-And-Filter -SourceParent 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell' -SourceParentName 'appdata' -ToFilterBy 'ConsoleHost_history.txt' -parentName 'CmdHistory'

This example clones the 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell' folder as a git repository named 'CmdHistory' and filters it by the 'ConsoleHost_history.txt' file. It also adds the source folder as a remote named 'appdata'.
#>
function Clone-And-Filter {
    # Define the parameters for the function
    param (
        # The SourceParent parameter specifies the path of the source folder to clone
        [Parameter(Mandatory=$true)]
        [string]$SourceParent,
        # The SourceParentName parameter specifies the name of the source folder to use as a remote
        [Parameter(Mandatory=$true)]
        [string]$SourceParentName,
        # The ToFilterBy parameter specifies the name of the file to filter by
        [Parameter(Mandatory=$true)]
        [string]$ToFilterBy,
        # The parentName parameter specifies the name of the parent folder to use as a repository
        [Parameter(Mandatory=$true)]
        [string]$parentName
    )

    # Define a variable for the temporary folder path
    $tempFolder = 'B:\ToGit\'

    # Change the current directory to the temporary folder
    cd $tempFolder

    # Clone the source folder as a bare repository using git clone command with mirror switch
    git clone --mirror $SourceParent "$parentName/.git"

    # Change the current directory to the parent folder
    cd ($tempFolder + "\$parentName")

    # Configure the repository as a normal repository using git config command with bool and bare parameters
    git config --bool core.bare false 

    # Add all files in the source folder to the staging area using git add command with dot parameter
    git add .

    # Commit all files in the staging area using git commit command with message parameter
    git commit -m 'etc' 

    # Define a variable for the filter command using git rm and git reset commands with index-filter parameter
    $filter = 'git rm --cached -qr --ignore-unmatch -- . && git reset -q $GIT_COMMIT -- '+$ToFilterBy

    # Filter the repository by the file name using git filter-branch command with index-filter, prune-empty and all parameters
    git filter-branch --index-filter $filter --prune-empty -- --all

    # Remove the original references using git for-each-ref and git update-ref commands with format, refname and delete parameters
    git for-each-ref --format="%(refname)" refs/original/ | xargs -n 1 git update-ref -d

    # Add the source folder as a remote using git remote add command with SourceParentName and SourceParent parameters
    git remote add $SourceParentName $SourceParent

}