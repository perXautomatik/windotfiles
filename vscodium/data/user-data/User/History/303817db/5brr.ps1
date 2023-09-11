
<#
.SYNOPSIS
Write a file as a blob object and get its hash.

.DESCRIPTION
This function uses the Git hash-object command to write a file as a blob object in the object database and return its hash.

.PARAMETER Path
The path of the file to write as a blob object.

.EXAMPLE
Write-Blob -Path x

Output:
83baae6184e365e25a200e895a98342b9f9a0e7a
#>
. ./Write-Blob.ps1

<#
.SYNOPSIS
Create a tree object from a dummy file content and get its hash.

.DESCRIPTION
This function uses the Git hash-object and mktree commands to create a blob object from a dummy file content, and then create a tree object that contains the blob object and return its hash.

.PARAMETER DummyContent
The dummy file content that contains the file information.

.EXAMPLE
Create-Tree -DummyContent "100644 blob 83baae6184e365e25a200e895a98342b9f9a0e7a x"

Output:
3c4e9cd789d88d8d89c1073707c3585e41b0e614
#>
. ./Create-Tree.ps1

<#
.SYNOPSIS
Create a commit object from a tree object and a commit message file and get its hash.

.DESCRIPTION
This function uses the Git commit-tree command to create a commit object from a tree object and a commit message file and return its hash.

.PARAMETER TreeHash
The hash of the tree object that represents the root directory of the commit.

.PARAMETER CommitFile
The path of the commit message file that contains the commit message and other metadata.

.EXAMPLE
Create-Commit -TreeHash 3c4e9cd789d88d8d89c1073707c3585e41b0e614 -CommitFile commit.txt

Output:
fdf4fc3344e67ab068f836878b6c4951e3b15f3d
#>
. ./Create-Commit.ps1

<#
.SYNOPSIS
Create a commit message file from a tree hash and other optional parameters and return the path to the temporary file.

.DESCRIPTION
This function creates a commit message file that contains the tree hash, the author, the committer, the date, and the message of the commit. It writes the commit message to a temporary file and returns the path to the file.

.PARAMETER TreeHash
The hash of the tree object that represents the root directory of the commit.

.PARAMETER Author
The name and email of the author of the commit. The default value is "John Doe <johndoe@example.com>".

.PARAMETER Committer
The name and email of the committer of the commit. The default value is "John Doe <johndoe@example.com>".

.PARAMETER Date
The date and time of the commit in Unix timestamp format. The default value is the current date and time.

.PARAMETER Message
The message of the commit. The default value is "Add file x".

.EXAMPLE
Create-CommitMessage -TreeHash 3c4e9cd789d88d8d89c1073707c3585e41b0e614

Output:
C:\Users\John\AppData\Local\Temp\tmpA1B2C3.txt
#>
. ./Create-CommitMessage.ps1

<#
.SYNOPSIS
Create a new branch that points to a commit object.

.DESCRIPTION
This function uses the Git update-ref command to create a new branch that points to a commit object.

.PARAMETER BranchName
The name of the new branch to create.

.PARAMETER CommitHash
The hash of the commit object that the new branch should point to.

.EXAMPLE
Create-Branch -BranchName new_branch -CommitHash fdf4fc3344e67ab068f836878b6c4951e3b15f3d

Output:
None (the function does not produce any output)
#>
. ./Create-Branch.ps1


<#
.SYNOPSIS
Link a commit SHA on top of the current head.

.DESCRIPTION
This function uses the Git cherry-pick command to apply the changes introduced by a commit SHA on top of the current head, creating a new commit.

.PARAMETER CommitSHA
The hash of the commit to link on top of the current head.

.EXAMPLE
Link-Commit -CommitSHA f4b5c6d7

Output:
None (the function does not produce any output)
#>
. ./Link-Commit.ps1
    

. ./branch-fromFile.ps1


. ./branch-HeadFromFile.ps1
