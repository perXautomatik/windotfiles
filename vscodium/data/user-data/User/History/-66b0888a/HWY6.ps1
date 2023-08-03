# Import the module or script that contains the function to test
Import-Module -Name Pester
. $PSScriptRoot\Split-TextByRegex.ps1

# Use the Describe block to group your tests
Describe 'Split-TextByRegex' {

    # Use the BeforeAll block to set up some variables and files for testing
    BeforeAll {
        # Define a sample text file with some content
        $sampleFile = ".\sample.txt"
        $sampleContent = @"
This is a sample text file.
It contains some words and numbers.
1234567890
abcde fghij klmno pqrst uvwxy z
"@        
        # Write the content to the file
        Set-Content -Path $sampleFile -Value $sampleContent

        # Define some regular expressions to test
        $regex1 = "\d+" # Matches one or more digits
        $regex2 = "\w{5}" # Matches five consecutive word characters
        $regex3 = "\s+" # Matches one or more whitespace characters
    }

    # Use the AfterAll block to clean up any files or variables created for testing
    AfterAll {
        # Remove the sample file
        Remove-Item -Path $sampleFile -Force
    }

    # Use the It block to write individual tests
    It 'Splits the text by digits and returns the matches' {
        # Call the function and store the output
        $output = Split-TextByRegex -Path $sampleFile -Regx $regex1

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 1 # Check that the output has one element
        $output[0].StartIndex | Should -Be 66 # Check that the first match starts at index 50
        $output[0].EndIndex | Should -Be 75 # Check that the first match ends at index 59
        $output[0].Value | Should -Be "1234567890" # Check that the first match value is "1234567890"
    }

    It 'Splits the text by five-letter words and returns the matches' {
        # Call the function and store the output
        $output = Split-TextByRegex -Path $sampleFile -Regx $regex2

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 11 # Check that the output has six elements
        $output[0].StartIndex | Should -Be 10 # Check that the first match starts at index 26
        $output[0].EndIndex | Should -Be 14 # Check that the first match ends at index 30
        $output[0].Value | Should -Be "sampl" # Check that the first match value is "abcde"
        $output[5].StartIndex | Should -Be 71 # Check that the last match starts at index 57
        $output[5].EndIndex | Should -Be 75 # Check that the last match ends at index 61
        $output[5].Value | Should -Be "67890" # Check that the last match value is "uvwxy"
    }

    It 'Splits the text by whitespace and returns the matches' {
        # Call the function and store the output
        $output = Split-TextByRegex -Path $sampleFile -Regx $regex3

        # Use the Should keyword to verify the expected behavior
        $output | Should -Not -BeNullOrEmpty # Check that the output is not null or empty
        $output | Should -HaveCount 19 # Check that the output has eleven elements
        $output[0].StartIndex | Should -Be 4 # Check that the first match starts at index 4
        $output[0].EndIndex | Should -Be 4 # Check that the first match ends at index 4
        $output[0].Value | Should -Be " " # Check that the first match value is " "
        $output[10].StartIndex | Should -Be 62 # Check that the last match starts at index 62
        $output[10].EndIndex | Should -Be 62 # Check that the last match ends at index 62
        $output[10].Value | Should -Be " " # Check that the last match value is " "
    }

    It 'Throws an error if the path is invalid' {
        # Call the function with an invalid path and catch the error
        try {
            Split-TextByRegex -Path ".\invalid.txt" -Regx $regex1
            $error = $null
        }
        catch {
            $error = $_
        }

        # Use the Should keyword to verify the expected behavior
        $error | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $error | Should -Match "Invalid path: .\\invalid.txt" # Check that the error message matches the expected one
    }

    It 'Throws an error if the regular expression is invalid' {
        # Call the function with an invalid regular expression and catch the error
        try {
            Split-TextByRegex -Path $sampleFile -Regx ""
            $error = $null
        }
        catch {
            $error = $_
        }

        # Use the Should keyword to verify the expected behavior
        $error | Should -Not -BeNullOrEmpty # Check that the error is not null or empty
        $error | Should -Match "Could not split the content by \" # Check that the error message matches the expected one
    }
}