# Import the script that contains the Get-TridChunks function
. .\Get-TridChunks.ps1

# Define a test suite for the Get-TridChunks function
Describe "Get-TridChunks" {

  # Define a test case for a valid input with two chunks
  It "should return two chunks of paths for trid for a valid input with two chunks" {

    # Arrange: Define the input parameters and the expected output
    $Paths = @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")
    $ChunkSize = 2
    $ExpectedOutput = @("C:\foo\bar*", "C:\foo\baz*")

    # Act: Call the Get-TridChunks function with the input parameters
    $ActualOutput = Get-TridChunks -Paths $Paths -ChunkSize $ChunkSize

    # Assert: Compare the actual output with the expected output using Should
    $ActualOutput | Should -Be $ExpectedOutput
  }

  # Define a test case for an invalid input with a chunk size greater than 100
  It "should throw an exception for an invalid input with a chunk size greater than 100" {

    # Arrange: Define the input parameters
    $Paths = @("C:\foo\bar1.txt", "C:\foo\bar2.txt", "C:\foo\baz1.txt", "C:\foo\baz2.txt")
    $ChunkSize = 101

    # Act and Assert: Call the Get-TridChunks function with the input parameters and expect an exception using Should -Throw
    {Get-TridChunks -Paths $Paths -ChunkSize $ChunkSize} | Should -Throw
  }

  # You can add more test cases as needed
}
