Describe "Create-FolderFromFile" {
    # Test suite for Create-FolderFromFile function
    BeforeAll {
        # Import the function from the script file
        . $PSScriptRoot\Create-FolderFromFile.ps1
    }
    AfterEach {
        # Remove any files and folders created by the tests
        Remove-Item -Path .\* -Recurse -Force -ErrorAction SilentlyContinue
    }
    Context "When FileName parameter is specified" {
        # Group of tests for this scenario
        It "Creates a folder with the same name as the file, excluding any numbers in parentheses at the end" {
            # Test case for this expectation
            # Create a test file
            New-Item -Path .\Test (1).txt -ItemType File | Out-Null
            # Invoke the function with the test file as input
            Create-FolderFromFile -FileName .\Test (1).txt
            # Assert that a folder named Test is created
            Test-Path -Path .\Test | Should -BeTrue
            # Assert that the test file is moved into the folder
            Test-Path -Path .\Test\Test (1).txt | Should -BeTrue
        }
        It "Creates a folder with the same name as the file, if the file name does not have any numbers in parentheses" {
            # Test case for this expectation
            # Create a test file
            New-Item -Path .\Test.txt -ItemType File | Out-Null
            # Invoke the function with the test file as input
            Create-FolderFromFile -FileName .\Test.txt
            # Assert that a folder named Test is created
            Test-Path -Path .\Test | Should -BeTrue
            # Assert that the test file is moved into the folder
            Test-Path -Path .\Test\Test.txt | Should -BeTrue
        }
        It "Creates a folder with a unique name, if a folder with the same name already exists" {
            # Test case for this expectation
            # Create a test file and a test folder with the same name
            New-Item -Path .\Test (1).txt -ItemType File | Out-Null
            New-Item -Path .\Test -ItemType Directory | Out-Null
            # Invoke the function with the test file as input
            Create-FolderFromFile -FileName .\Test (1).txt
            # Assert that a folder named Test (1) is created
            Test-Path -Path .\Test (1) | Should -BeTrue
            # Assert that the test file is moved into the folder
            Test-Path -Path .\Test (1)\Test (1).txt | Should -BeTrue
        }
    }
    Context "When FileName parameter is not specified or invalid" {
        # Group of tests for this scenario
        It "Throws an error" {
            # Test case for this expectation
            # Invoke the function without any input or with an invalid input
            { Create-FolderFromFile } | Should -Throw 
            { Create-FolderFromFile -FileName NonExistingFile.txt } | Should -Throw 
        }
    }
}
