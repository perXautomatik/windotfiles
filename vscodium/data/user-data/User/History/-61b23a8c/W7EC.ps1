# Import the module that contains the functions to be tested
Import-Module .\project\split-branches-byfiles.ps1

Update-TypeData -TypeName "System.Collections.HashTable"   `
-MemberType ScriptMethod `
-MemberName "ToString" -Value { $hashstr = "@{"; $keys = $this.keys; foreach ($key in $keys) { $v = $this[$key];
       if ($key -match "\s") { $hashstr += "`"$key`"" + "=" + "`"$v`"" + ";" }
       else { $hashstr += $key + "=" + "`"$v`"" + ";" } }; $hashstr += "}";
       return $hashstr } -Force

# Define a test suite for the module
Describe "PSSomethingModule" {

    # Define a test case for the createValidBranchName function
    Context "createValidBranchName" {

        # Define a test for creating a valid branch name from an array and a string embedding
        It "creates a valid branch name from an array and a string embedding" {
            # Arrange: define the input parameters and the expected output
            $array = @("foo","bar","baz")
            $stringEmbedding = "{1}_{0}-{2}"
            $expected = "bar_foo-baz"

            # Act: invoke the function with the input parameters and assign the output to a variable
            $actual = createValidBranchName -array $array -stringEmbedding $stringEmbedding

            # Assert: compare the actual output with the expected output using Should -Be
            $actual | Should -Be $expected
        }

        # Define a test for creating a valid branch name and checking it against an existing branch in a repository
        It "creates a valid branch name and checks it against an existing branch in a repository" {
            # Arrange: define the input parameters and the expected error message
            $array = @("foo","master","baz")
            $stringEmbedding = "{0}_{1}-{2}"
            $repoPath = ".\"
            $expected = "The branch name 'master_foo-baz' already exists in the repository."

            # Act: invoke the function with the input parameters and checkAgainstRepo switch and assign the error message to a variable
            $actual = {createValidBranchName -array $array -stringEmbedding $stringEmbedding -repoPath $repoPath -checkAgainstRepo} | Should -Throw -PassThru

            # Assert: compare the actual error message with the expected error message using Should -Be
            $actual.Exception.Message | Should -Be $expected
        }
    }

    # Define a test case for the setRemote function
    Context "setRemote" {

        # Define a test for setting remote for a tracking branch
        It "sets remote for a tracking branch" {
            # Arrange: define the input parameters and mock the git command to return a dummy output
            $remoteUrl = "https://github.com/user/repo.git"
            $trackingBranch = "master"
            Mock git {return "remote origin added"}

            # Act: invoke the function with the input parameters and assign the output to a variable
            $actual = setRemote -remoteUrl $remoteUrl -trackingBranch $trackingBranch

            # Assert: compare the actual output with the mocked output using Should -Be
            $actual | Should -Be "remote origin added"
        }
    }

    # Define a test case for the getBranchHeadPaths function
    Context "getBranchHeadPaths" {

        # Define a test for getting relative paths of files in a branch head
        It "gets relative paths of files in a branch head" {
            # Arrange: define the input parameter and mock the git command to return an array of paths
            $branchName = "master"
            Mock git {return @("file1.txt","file2.ps1","folder/file3.csv")}

            # Act: invoke the function with the input parameter and assign the output to a variable
            $actual = getBranchHeadPaths -branchName $branchName

            # Assert: compare the actual output with the mocked output using Should -BeExactly
            $actual.toString() | Should -BeExactly @("file1.txt","file2.ps1","folder/file3.csv").ToString()
        }
    }

    # Define a test case for the getRepoBranchNames function
    Context "getRepoBranchNames" {

        # Define a test for getting repository branch names and references
        It "gets repository branch names and references" {
            # Arrange: mock the git command to return an array of strings with references and names
            Mock git {return @("refs/heads/master 1234567890abcdef","refs/heads/dev fedcba0987654321")}

            # Act: invoke the function and assign the output to a variable
            $actual = getRepoBranchNames

            # Assert: compare the actual output with an expected hashtable using Should -BeExactly
            $actual.ToString() | Should -BeExactly @{"refs/heads/master"="1234567890abcdef";"refs/heads/dev"="fedcba0987654321"}.ToString()
        }
    }

    # Define a test case for the createMultipleBranches function
    Context "createMultipleBranches" {

        # Define a test for creating multiple branches from a dictionary of names and references
        It "creates multiple branches from a dictionary of names and references" {
            # Arrange: define the input parameter and mock the git commands to return dummy outputs
            $dictionary = @{"foo"="refs/heads/master";"bar"="refs/heads/dev"}
            Mock git {return "branch created"}
            Mock git {return "branch updated"}

            # Act: invoke the function with the input parameter and assign the output to a variable
            $actual = createMultipleBranches -dictionary $dictionary

            # Assert: compare the actual output with an expected array using Should -BeExactly
            $actual | Should -BeExactly @("foo","bar")
        }

        # Define a test for creating multiple branches with duplicate names
        It "creates multiple branches with duplicate names" {
            # Arrange: define the input parameter and the expected error message
            $dictionary = @{"foo"="refs/heads/dev"}
            $dictionary + @{"foo"="refs/heads/dev"}
            $expected = "The dictionary contains duplicate keys."

            # Act: invoke the function with the input parameter and check the error message
            $actual = {createMultipleBranches -dictionary $dictionary} | Should -Throw -PassThru

            # Assert: compare the actual error message with the expected error message using Should -Be
            $actual.Exception.Message | Should -Be $expected
        }

        # Define a test for creating multiple branches with names that are same as repo's branch names
        It "creates multiple branches with names that are same as repo's branch names" {
            # Arrange: define the input parameter and the expected error message
            $dictionary = @{"master"="refs/heads/master";"dev"="refs/heads/dev"}
            $expected = "The dictionary contains keys that are same as repo's branch names."

            # Act: invoke the function with the input parameter and check the error message
            $actual = {createMultipleBranches -dictionary $dictionary} | Should -Throw -PassThru

            # Assert: compare the actual error message with the expected error message using Should -Be
            $actual.Exception.Message | Should -Be $expected
        }
    }
}
