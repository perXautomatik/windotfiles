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
