# Import the module or script that contains the function to test
Import-Module .\config-to-gitmodules.ps1

# Use the Describe block to group your tests
Describe 'config-to-gitmodules' {

    # Use the BeforeAll block to define some variables and mocks that are common for all tests
    BeforeAll {
        # Define a valid git directory path that contains a config file
        $validGitDirPath = "C:\t\Planets\.git"

        # Define a valid git root directory path that contains a .gitmodules file
        $validGitRootPath = "C:\t\Planets"

        # Define an invalid git directory path that does not contain a config file
        $invalidGitDirPath = "C:\t\Invalid\.git"

        # Define an invalid git root directory path that does not contain a .gitmodules file
        $invalidGitRootPath = "C:\t\Invalid"

        # Define an expected output for the valid git directory and root paths
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

        # Mock the Git-helper module to return a predefined output for the valid git directory and root paths and throw an exception for any other paths
        Mock Git-helper {
            param($GitDirPath, $GitRootPath)
            if ($GitDirPath -eq $validGitDirPath -and $GitRootPath -eq $validGitRootPath) {
                return @(
                    [pscustomobject]@{
                        submodule.Mercury.path = "Mercury"
                        submodule.Mercury.url = "https://github.com/planets/Mercury.git"
                    },
                    [pscustomobject]@{
                        submodule.Venus.path = "Venus"
                        submodule.Venus.url = "https://github.com/planets/Venus.git"
                    },
                    [pscustomobject]@{
                        submodule.Earth.path = "Earth"
                        submodule.Earth.url = "https://github.com/planets/Earth.git"
                    }
                )
            } else {
                throw "Invalid git directory or root path"
            }
        }

        # Mock the ini-helper module to return a predefined output for the valid git directory and root paths and throw an exception for any other paths
        Mock ini-helper {
            param($GitDirPath, $GitRootPath)
            if ($GitDirPath -eq $validGitDirPath -and $GitRootPath -eq $validGitRootPath) {
                return @(
                    [pscustomobject]@{
                        submodule.Mercury.path = "Mercury"
                        submodule.Mercury.url = "https://github.com/planets/Mercury.git"
                    },
                    [pscustomobject]@{
                        submodule.Venus.path = "Venus"
                        submodule.Venus.url = "https://github.com/planets/Venus.git"
                    },
                    [pscustomobject]@{
                        submodule.Earth.path = "Earth"
                        submodule.Earth.url = "https://github.com/planets/Earth.git"
                    }
                )
            } else {
                throw "Invalid git directory or root path"
            }
        }

        # Mock the PsIni module to return a predefined output for the valid git directory and root paths and throw an exception for any other paths
        Mock PsIni {
            param($GitDirPath, $GitRootPath)
            if ($GitDirPath -eq $validGitDirPath -and $GitRootPath -eq $validGitRootPath) {
                return @(
                    [pscustomobject]@{
                        submodule.Mercury.path = "Mercury"
                        submodule.Mercury.url = "https://github.com/planets/Mercury.git"
                    },
                    [pscustomobject]@{
                        submodule.Venus.path = "Venus"
                        submodule.Venus.url = "https://github.com/planets/Venus.git"
                    },
                    [pscustomobject]@{
                        submodule.Earth.path = "Earth"
                        submodule.Earth.url = "https://github.com/planets/Earth.git"
                    }
                )
            } else {
                throw "Invalid git directory or root path"
            }
        }
    }

    # Use the It block to write individual tests
    It 'Given valid git directory and root paths, it updates the .gitmodules file and the config file with the submodule information' {
        # Call the function and store the output
        $output = config-to-gitmodules -GitDirPath $validGitDirPath -GitRootPath $validGitRootPath

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 3 # Check that the output has three elements
        $output | Should -BeExactly $expectedOutput # Check that the output matches the expected output
    }

    It 'Given invalid git directory or root paths, it throws an error' {
        # Call the function and catch the error
        try {
            config-to-gitmodules -GitDirPath $invalidGitDirPath -GitRootPath $invalidGitRootPath
            $errorq = $null
        }
        catch {
            $errorq = $_
        }

        # Use the Should keyword to verify the expected behavior
        $errorq | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $errorq | Should -Match "Invalid git directory or root path" # Check that the error message matches the expected one
    }
}
