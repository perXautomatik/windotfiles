# Import the module or script that contains the function to test
Import-Module .\ActOnError.ps1

# Use the Describe block to group your tests
Describe 'ActOnError' {

    # Use the BeforeAll block to define some variables and mocks that are common for all tests
    BeforeAll {
        # Define a valid folder path that contains a git folder
        $validFolderPath = "C:\t\Planets"

        # Define a valid repair alternatives path that contains a .git\modules folder
        $validRepairPath = "C:\t\Planets\.git\modules"

        # Define an invalid folder path that does not contain a git folder
        $invalidFolderPath = "C:\t\Invalid"

        # Define an invalid repair alternatives path that does not contain a .git\modules folder
        $invalidRepairPath = "C:\t\Invalid\.git\modules"

        # Mock the Git-helper module to return a predefined output for the valid folder path and throw an exception for any other path
        Mock Git-helper {
            param($folder)
            if ($folder -eq $validFolderPath) {
                return @(
                    [pscustomobject]@{
                        Name = 'Mercury'
                        FullName = 'C:\t\Planets\Mercury'
                    },
                    [pscustomobject]@{
                        Name = 'Venus'
                        FullName = 'C:\t\Planets\Venus'
                    },
                    [pscustomobject]@{
                        Name = 'Earth'
                        FullName = 'C:\t\Planets\Earth'
                    }
                )
            } else {
                throw "path not existing"
            }
        }

        # Mock the ini-helper module to return a predefined output for the valid folder path and throw an exception for any other path
        Mock ini-helper {
            param($folder)
            if ($folder -eq $validFolderPath) {
                return @(
                    [pscustomobject]@{
                        Name = 'Mercury'
                        FullName = 'C:\t\Planets\Mercury'
                    },
                    [pscustomobject]@{
                        Name = 'Venus'
                        FullName = 'C:\t\Planets\Venus'
                    },
                    [pscustomobject]@{
                        Name = 'Earth'
                        FullName = 'C:\t\Planets\Earth'
                    }
                )
            } else {
                throw "path not existing"
            }
        }

        # Mock the Check-GitStatus function to return a predefined output for the valid folder path and throw an exception for any other path
        Mock Check-GitStatus {
            param($folder)
            if ($folder -eq $validFolderPath) {
                return @(
                    [pscustomobject]@{
                        Name = 'Mercury'
                        Status = 'On branch master'
                    },
                    [pscustomobject]@{
                        Name = 'Venus'
                        Status = 'On branch master'
                    },
                    [pscustomobject]@{
                        Name = 'Earth'
                        Status = 'On branch master'
                    }
                )
            } else {
                throw "fatal: not in a git directory"
            }
        }

        # Mock the Remove-Worktree function to do nothing
        Mock Remove-Worktree {}
    }

    # Use the It block to write individual tests
    It 'Given valid folder and repair paths, it converts the git folder into a submodule and absorbs its git directory' {
        # Call the function and store the output
        $output = ActOnError -folder $validFolderPath -repairAlternatives $validRepairPath

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 3 # Check that the output has three elements
        $output | Should -BeExactly @('On branch master', 'On branch master', 'On branch master') # Check that the output matches the expected output
    }

    It 'Given invalid folder or repair paths, it throws an error' {
        # Call the function and catch the error
        try {
            ActOnError -folder $invalidFolderPath -repairAlternatives $invalidRepairPath
            $errord = $null
        }
        catch {
            $errord = $_
        }

        # Use the Should keyword to verify the expected behavior
        $errord | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $errord | Should -Match "path not existing" # Check that the error message matches the expected one
    }
}
