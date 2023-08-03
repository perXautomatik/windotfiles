# Import the script that contains the GetCommonPrefix function
. "$PSScriptRoot\Get-commonPrefix.ps1"

# Define a test suite for the GetCommonPrefix function
Describe "GetCommonPrefix" {

  # Define a test case for an empty input
  It "should return an empty string for an empty input" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @()
    $ExpectedOutput = ""

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -Be $ExpectedOutput
  }

  # Define a test case for a single input
  It "should return the same string for a single input" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\bar.txt")
    $ExpectedOutput = "C:\foo\bar.txt"

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -Be $ExpectedOutput
  }

  # Define a test case for a valid input with a common prefix
  It "should return the common prefix for a valid input with a common prefix" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")
    $ExpectedOutput = "C:\foo\"

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -Be $ExpectedOutput
  }

  # Define a test case for a valid input with no common prefix
  It "should return an empty string for a valid input with no common prefix" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\bar.txt", "D:\baz\qux.txt", "E:\quux\corge.txt")
    $ExpectedOutput = ""

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -Be $ExpectedOutput
  }

  # You can add more test cases as needed
}
