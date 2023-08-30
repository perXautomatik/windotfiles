<#I can try to write a powershell script that does what you want, but I may not be able to test it or guarantee its correctness. Here is what I came up with:

```powershell#>
<#
.SYNOPSIS
Lists the files that only have commits adding them and no actual history in the local git repo.

.DESCRIPTION
This function lists the files that only have commits adding them and no actual history in the local git repo, using the git commands. The function expects to be run in the root directory of the repo and outputs the file names that match the criteria.

.PARAMETER Branch
The name of the branch to check. If not specified, the current branch will be used.
#>
function List-Files-With-No-History {
    param(
        # Validate that the Branch parameter is not null or empty and is a valid branch name
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({git show-ref --verify --quiet refs/heads/$_})]
        [string]
        $Branch
    )

    # If no branch is specified, use the current branch
    if (!$Branch) {
        $Branch = git rev-parse --abbrev-ref HEAD
    }

    # Get all the files that were added in the specified branch and store them as an array of strings
    $addedFiles = git log --pretty=format: --name-only --diff-filter=A $Branch | Sort-Object -Unique

    # Loop through each file in the array
    foreach ($file in $addedFiles) {
        
		# Get the number of commits that modified the file in the specified branch
		
		$modifiedCommits = git log --pretty=format: --name-only --diff-filter=M $Branch -- $file | Measure-Object -Line
		
		# Check if the number of commits is zero
		
		if ($modifiedCommits.Lines -eq 0) {
			
			# Write the file name to the host
			
			Write-Host $file
			
		}
		
	}

}
<#
```
I used some of the answers from these web pages as references:

- https://stackoverflow.com/questions/23311187/git-list-all-files-modified-not-added-since-a-specific-commit-including-ones-t
- https://stackoverflow.com/questions/543346/list-all-the-files-that-ever-existed-in-a-git-repository
- https://superuser.com/questions/429693/git-list-all-files-currently-under-source-control

Source: Conversation with Bing, 2023-07-03
(1) powershell - Git list all files modified (not added) since a specific .... https://stackoverflow.com/questions/23311187/git-list-all-files-modified-not-added-since-a-specific-commit-including-ones-t.
(2) List all the files that ever existed in a Git repository. https://stackoverflow.com/questions/543346/list-all-the-files-that-ever-existed-in-a-git-repository.
(3) Git - List all files currently under source control? - Super User. https://superuser.com/questions/429693/git-list-all-files-currently-under-source-control.
#>