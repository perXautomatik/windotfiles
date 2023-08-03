# Import the module or script that contains the function to test
Import-Module -Name Pester
. $PSScriptRoot\keyPairTo-PsCustom.ps1

# Use the Describe block to group your tests
Describe 'keyPairTo-PsCustom' {

    # Use the It block to write individual tests
    It 'Converts key-value pairs to custom objects with properties' {
        # Define some sample key-value pairs
        $keyPairStrings = @(("name=John", "age=25", "gender=male"))

        # Call the function and store the output
        $output = keyPairTo-PsCustom -KeyPairStrings $keyPairStrings

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 3 # Check that the output has three elements
        $output[0].name | Should -Be "John" # Check that the first element has a name property with value "John"
        $output[0].age | Should -Be 25 # Check that the first element has an age property with value 25
        $output[0].gender | Should -Be "male" # Check that the first element has a gender property with value "male"
        $output[1].name | Should -Be "Jane" # Check that the second element has a name property with value "Jane"
        $output[1].age | Should -Be 23 # Check that the second element has an age property with value 23
        $output[1].gender | Should -Be "female" # Check that the second element has a gender property with value "female"
        $output[2].name | Should -Be "Bob" # Check that the third element has a name property with value "Bob"
        $output[2].age | Should -Be 27 # Check that the third element has an age property with value 27
        $output[2].gender | Should -Be "male" # Check that the third element has a gender property with value "male"
    }

    It 'Throws an error if the string is not a valid key-value pair' {
        # Define some invalid key-value pairs
        $keyPairStrings = @("name:John", "age=25", "gender")

        # Call the function and catch the error
        try {
            keyPairTo-PsCustom -KeyPairStrings $keyPairStrings
            $error = $null
        }
        catch {
            $error = $_
        }

        # Use the Should keyword to verify the expected behavior
        $error | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $error | Should -Match "Could not parse the string: name:John" # Check that the error message matches the expected one
    }
}