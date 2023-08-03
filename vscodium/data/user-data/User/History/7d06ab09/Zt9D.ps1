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
    $ActualOutput | Should -BeExactly $ExpectedOutput
  }

  # Define a test case for a single element input
  It "should return the same string for a single element input" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\bar.txt")
    $ExpectedOutput = "C:\foo\bar.txt"

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -BeExactly $ExpectedOutput
  }

  # Define a test case for a valid input with a common prefix
  It "should return the common prefix for a valid input with a common prefix" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")
    $ExpectedOutput = "C:\foo\ba"

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -BeExactly $ExpectedOutput
  }

  # Define a test case for a valid input with no common prefix
  It "should return an empty string for a valid input with no common prefix" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\bar.txt", "D:\baz\qux.txt", "E:\quux\corge.txt")
    $ExpectedOutput = ""

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -BeExactly $ExpectedOutput
  }

  # Define a test case for an invalid input with square brackets
  It "should return an empty string for an invalid input with square brackets" {

    # Arrange: Define the input parameter and the expected output
    $Strings = @("C:\foo\[bar].txt", "C:\foo\[baz].txt")
    $ExpectedOutput = ""

    # Act: Call the GetCommonPrefix function with the input parameter
    $ActualOutput = GetCommonPrefix -Strings $Strings

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -BeExactly $ExpectedOutput
  }

  # Define a test context for using the OnlyFolders flag
  Context "Using OnlyFolders flag" {

    # Define a test case for a valid input with a common prefix that includes a file name
    It "should return only the folder part of the common prefix for a valid input with a common prefix that includes a file name" {

      # Arrange: Define the input parameter and the expected output
      $Strings = @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")
      $ExpectedOutput = "C:\foo\"

      # Act: Call the GetCommonPrefix function with the input parameter and the flag
      $ActualOutput = GetCommonPrefix -Strings $Strings -OnlyFolders

      # Assert: Compare the actual output with the expected output using Should
      $ActualOutput | Should -BeExactly $ExpectedOutput
    }

    # Define a test case for a valid input with a common prefix that is only a folder path
    It "should return the same folder path for a valid input with a common prefix that is only a folder path" {

      # Arrange: Define the input parameter and the expected output
      $Strings = @("C:\foo\bar\", "C:\foo\baz\", "C:\foo\qux\")
      $ExpectedOutput = "C:\foo\"

      # Act: Call the GetCommonPrefix function with the input parameter and the flag
      $ActualOutput = GetCommonPrefix -Strings $Strings -OnlyFolders

      # Assert: Compare the actual output with the expected output using Should
      $ActualOutput | Should -BeExactly $ExpectedOutput
    }

    # Define a test case for a valid input with no common prefix
    It "should return an empty string for a valid input with no common prefix" {

      # Arrange: Define the input parameter and the expected output
      $Strings = @("C:\foo\bar.txt", "D:\baz\qux.txt", "E:\quux\corge.txt")
      $ExpectedOutput = ""

      # Act: Call the GetCommonPrefix function with the input parameter and the flag
      $ActualOutput = GetCommonPrefix -Strings $Strings -OnlyFolders

      # Assert: Compare the actual output with the expected output using Should
      $ActualOutput | Should -BeExactly $ExpectedOutput
    }
  }

  # Define a test context for using the ValidatePaths flag
  Context "Using ValidatePaths flag" {

    # Define a test case for a valid input with valid paths
    It "should return the common prefix for a valid input with valid paths" {

      # Arrange: Define the input parameter and the expected output
      $Strings = @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")
      $ExpectedOutput = "C:\foo"

      # Act: Call the GetCommonPrefix function with the input parameter and the flag
      $ActualOutput = GetCommonPrefix -Strings $Strings -ValidatePaths

      # Assert: Compare the actual output with the expected output using Should
      $ActualOutput | Should -BeExactly $ExpectedOutput
    }

    # Define a test case for an invalid input with invalid paths
    It "should throw an error or return an empty string for an invalid input with invalid paths" {

      # Arrange: Define the input parameter and the expected output
      $Strings = @("C:\foo\[bar].txt", "C:\foo\[baz].txt")
      $ExpectedOutput = ""

      # Act: Call the GetCommonPrefix function with the input parameter and the flag
      { GetCommonPrefix -Strings $Strings -ValidatePaths } | Should -Throw

      # Alternatively, you can check if it returns an empty string instead of throwing an error
      #$ActualOutput = GetCommonPrefix -Strings $Strings -ValidatePaths
      #$ActualOutput | Should -BeExactly $ExpectedOutput
    }
  }
}
