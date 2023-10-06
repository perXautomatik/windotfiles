# Import the module that contains the functions to be tested
Import-Module .\mergeCommitObjects.ps1

# Define a test suite for the module
Describe "PSSomethingModule" {

    # Define a test case for the ResolveConflict function
    Context "ResolveConflict" {

        # Define a test for resolving conflicts among tree objects in git
        It "resolves conflicts among tree objects in git" {
            # Arrange: define the input parameter and mock the git commands to return dummy outputs
            $trees = @("4b825dc642cb6eb9a060e54bf8d69288fbee4904","1234567890abcdef","fedcba0987654321")
            Mock git {return "tree"}
            Mock git {return @("100644 blob 1234567890abcdef`tfile1.txt","100644 blob fedcba0987654321`tfile2.txt")}
            Mock git {return @("100644 blob 1234567890abcdef`tfile1.txt","100644 blob 0123456789abcdef`tfile2.txt")}
            Mock git {return @("100644 blob fedcba0987654321`tfile1.txt","100644 blob 0123456789abcdef`tfile2.txt")}
            Mock git {return "blob"}
            Mock git {return "merged blob"}
            Mock git {return "new tree"}

            # Act: invoke the function with the input parameter and assign the output to a variable
            $actual = ResolveConflict -trees $trees

            # Assert: compare the actual output with the expected output using Should -Be
            $actual | Should -Be "new tree"
        }
    }

    # Define a test case for the createNewBranch function
    Context "createNewBranch" {

        # Define a test for creating a new branch from a number of commit SHA's
        It "creates a new branch from a number of commit SHA's" {
            # Arrange: define the input parameters and mock the git commands and the ResolveConflict function to return dummy outputs
            $commits = @("123456","789abc","def012")
            $branchName = "new-branch"
            Mock git {return "commit"}
            Mock git {return @("tree 4b825dc642cb6eb9a060e54bf8d69288fbee4904","message 1")}
            Mock git {return @("tree 1234567890abcdef","message 2")}
            Mock git {return @("tree fedcba0987654321","message 3")}
            Mock ResolveConflict {return "resolved tree"}
            Mock git {return "new commit"}
            Mock git {return "branch created"}

            # Act: invoke the function with the input parameters and assign the output to a variable
            $actual = createNewBranch -commits $commits -branchName $branchName

            # Assert: compare the actual output with the expected output using Should -Be
            $actual | Should -Be $branchName
        }
    }
}

# Define some sample objects for testing
$sampleTrees = @("a1b2c3", "d4e5f6", "g7h8i9")
$sampleBlobs = @("j0k1l2", "m3n4o5", "p6q7r8")
$sampleMessages = @("First message", "Second message", "Third message")
$sampleMetadata = @(@{"author"="Alice"; "committer"="Bob"}, @{"author"="Charlie"; "committer"="David"}, @{"author"="Eve"; "committer"="Frank"})

# Define some expected objects for testing
$expectedTree = "s9t8u7"
$expectedBlob = "v6w5x4"
$expectedMessage = "Merge branch 'Alice' of https://example.com`n`nFirst message`n`nMerge branch 'Charlie' of https://example.com`n`nSecond message`n`nMerge branch 'Eve' of https://example.com`n`nThird message"
$expectedMetadata = @{"author"="Eve"; "committer"="Frank"}

# Define a Pester test script
Describe 'ResolveConflicts' {
    It 'Resolves tree conflicts and returns a new tree object' {
        # Call the ResolveConflicts function with -Tree flag and the sample tree objects
        $actualTree = ResolveConflicts -Tree $sampleTrees

        # Assert that the actual tree object is equal to the expected tree object
        $actualTree | Should -Be $expectedTree
    }

    It 'Resolves blob conflicts and returns a new blob object' {
        # Call the ResolveConflicts function with -Blob flag and the sample blob objects
        $actualBlob = ResolveConflicts -Blob $sampleBlobs

        # Assert that the actual blob object is equal to the expected blob object
        $actualBlob | Should -Be $expectedBlob
    }

    It 'Resolves message conflicts and returns a new message string' {
        # Call the ResolveConflicts function with -Message flag and the sample message strings
        $actualMessage = ResolveConflicts -Message $sampleMessages

        # Assert that the actual message string is equal to the expected message string
        $actualMessage | Should -Be $expectedMessage
    }

    It 'Resolves metadata conflicts and returns a new metadata hashtable' {
        # Call the ResolveConflicts function with -Metadata flag and the sample metadata hashtable
        $actualMetadata = ResolveConflicts -Metadata $sampleMetadata

        # Assert that the actual metadata hashtable is equal to the expected metadata hashtable
        $actualMetadata | Should -Be $expectedMetadata
    }
}

# Run the Pester test script and output the results
Invoke-Pester -ScriptBlock { . .\ResolveConflicts.Tests.ps1 } -Output Detailed
