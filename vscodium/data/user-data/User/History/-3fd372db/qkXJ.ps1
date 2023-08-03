# Import the module or script that contains the function to test
Import-Module .\git-GetSubmodulePathsUrls.ps1

# Use the Describe block to group your tests
Describe 'git-GetSubmodulePathsUrls' {

    # Use the BeforeAll block to define some variables and mocks that are common for all tests
    BeforeAll {
        # Define a valid repository path that contains a .gitmodules file
        $validRepoPath = "C:\t\Planets"

        # Define an invalid repository path that does not contain a .gitmodules file
        $invalidRepoPath = "C:\t\Invalid"

        # Define an expected output for the valid repository path
        $expectedOutput = @(
            [pscustomobject]@{
                Path = "Mercury"
                Url = "https://github.com/planets/Mercury.git"
                NonRelative = "C:\t\Planets\Mercury"
            },
            [pscustomobject]@{
                Path = "Venus"
                Url = "https://github.com/planets/Venus.git"
                NonRelative = "C:\t\Planets\Venus"
            },
            [pscustomobject]@{
                Path = "Earth"
                Url = "https://github.com/planets/Earth.git"
                NonRelative = "C:\t\Planets\Earth"
            }
        )

        # Mock the validGitRepo function to return true for the valid repository path and false for any other path
        Mock validGitRepo {
            param($RepoPath)
            if ($RepoPath -eq $validRepoPath) {
                return $true
            } else {
                return $false
            }
        }

        # Mock the git config command to return a predefined output for the valid repository path and throw an exception for any other path
        Mock git {
            param($config, $f, $getRegexp)
            if ($f -eq "$validRepoPath\.gitmodules") {
                return @(
                    "submodule.Mercury.path Mercury",
                    "submodule.Venus.path Venus",
                    "submodule.Earth.path Earth",
                    "submodule.Mercury.url https://github.com/planets/Mercury.git",
                    "submodule.Venus.url https://github.com/planets/Venus.git",
                    "submodule.Earth.url https://github.com/planets/Earth.git"
                )
            } else {
                throw "fatal: not in a git directory"
            }
        }
    }

    # Use the It block to write individual tests
    It 'Given a valid repository path, it returns an array of custom objects with submodule information' {
        # Call the function and store the output
        $output = git-GetSubmodulePathsUrls -RepoPath $validRepoPath

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 3 # Check that the output has three elements
        $output | Should -BeExactly $expectedOutput # Check that the output matches the expected output
    }

    It 'Given an invalid repository path, it throws an error' {
        # Call the function and catch the error
        try {
            git-GetSubmodulePathsUrls -RepoPath $invalidRepoPath
            $errorc = $null
        }
        catch {
            $errorc = $_
        }

        # Use the Should keyword to verify the expected behavior
        $errorc | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $errorc | Should -Match "Could not parse" # Check that the error message matches the expected one
    }
}
