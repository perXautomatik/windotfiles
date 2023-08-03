# Import the module or script that contains the function to test
Import-Module -Name Pester
. $PSScriptRoot\Invoke-Git.ps1

# Use the Describe block to group your tests
Describe 'Invoke-Git' {

    # Use the It block to write individual tests
    It 'Runs git commands and returns the output' {
        # Use the Mock keyword to replace any command with a custom implementation
        Mock Invoke-Expression { "git status" } -Verifiable

        # Call the function and store the output
        $output = Invoke-Git -Command "status"

        # Use the Should keyword to verify the expected behavior
        $output | Should -Be "git status"
        Assert-VerifiableMocks # Check that the mock was called
    }

    It 'Throws an exception if the git command fails' {
        # Use the Mock keyword to replace any command with a custom implementation
        Mock Invoke-Expression { throw "git error" } -Verifiable

        # Call the function and catch the exception
        try {
            Invoke-Git -Command "error"
            #$error = $null
        }
        catch {
            #$error = $_
        }

        # Use the Should keyword to verify the expected behavior
        $error | Should -Not -BeNullOrEmpty
        $error | Should -Match "Git command failed: git error"
        Assert-VerifiableMocks # Check that the mock was called
    }
}