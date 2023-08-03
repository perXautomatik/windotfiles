# Import the module or script that contains the function to test
Import-Module .\RepairWithQue-N-RepairFolder.ps1

# Use the Describe block to group your tests
Describe 'RepairWithQue-N-RepairFolder' {

    # Use the BeforeAll block to define some variables and mocks that are common for all tests
    BeforeAll {
        # Define a valid start path that contains a git folder
        $validStartPath = "C:\t\Planets"

        # Define a valid modules path that contains a .git\modules folder
        $validModulesPath = "C:\t\Planets\.git\modules"

        # Define an invalid start path that does not contain a git folder
        $invalidStartPath = "C:\t\Invalid"

        # Define an invalid modules path that does not contain a .git\modules folder
        $invalidModulesPath = "C:\t\Invalid\.git\modules"

        # Mock the Git-helper module to return a predefined output for the valid start path and throw an exception for any other path
        Mock Git-helper {
            param($Start)
            if ($Start -eq $validStartPath) {
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

        # Mock the ini-helper module to return a predefined output for the valid start path and throw an exception for any other path
        Mock ini-helper {
            param($Start)
            if ($Start -eq $validStartPath) {
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

        # Mock the Check-GitStatus function to return a predefined output for the valid start path and throw an exception for any other path
        Mock Check-GitStatus {
            param($Start)
            if ($Start -eq $validStartPath) {
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

        # Mock the ActOnError function to do nothing
        Mock ActOnError {}
    }

    # Use the It block to write individual tests
    It 'Given valid start and modules paths, it processes files with git status and repairs them if needed' {
        # Call the function and store the output
        $output = RepairWithQue-N-RepairFolder -Start $validStartPath -Modules $validModulesPath

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 3 # Check that the output has three elements
        $output | Should -BeExactly @('On branch master', 'On branch master', 'On branch master') # Check that the output matches the expected output
    }

    It 'Given invalid start or modules paths, it throws an error' {
        # Call the function and catch the error
        try {
            RepairWithQue-N-RepairFolder -Start $invalidStartPath -Modules $invalidModulesPath
            $error = $null
        }
        catch {
            $error = $_
        }

        # Use the Should keyword to verify the expected behavior
        $error | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $error | Should -Match "path not existing" # Check that the error message matches the expected one
    }
}
