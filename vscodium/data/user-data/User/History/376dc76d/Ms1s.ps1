# Import the script file that contains the functions to be tested
. .\script.ps1

# Define a Pester test file that tests the functions A, Get-GitRoot, and Remove-Memory
Describe "Script functions" {

    # Test the function Get-PathComponents with some sample paths
    Context "Function Get-PathComponents" {

        # Define some test cases with expected outputs
        $testCases = @(
            @{Path = "C:\Users\user\Documents\Q.txt"; Leaf = "Q.txt"; Parent = "Documents"; Subparent = "user"}
            @{Path = "D:\Projects\Demo\Main.cs"; Leaf = "Main.cs"; Parent = "Demo"; Subparent = "Projects"}
            @{Path = "\\Server\Share\Folder\File.docx"; Leaf = "File.docx"; Parent = "Folder"; Subparent = "Share"}
        )

        # Loop through each test case and assert the output of function Get-PathComponents
        It "Returns a custom object with the leaf, parent, and subparent of <Path>" -TestCases $testCases {
            param ($Path, $Leaf, $Parent, $Subparent)
            # Invoke function Get-PathComponents on the path and store the result
            $result = Get-PathComponents -path $Path
            # Assert that the result is a custom object with the expected properties and values
            $result | Should -BeOfType PSCustomObject
            $result.Leaf | Should -Be $Leaf
            $result.Parent | Should -Be $Parent
            $result.Subparent | Should -Be $Subparent
        }
    }

    # Test the function Get-GitRoot with some sample paths
    Context "Function Get-GitRoot" {

        # Define some test cases with expected outputs
        $testCases = @(
            @{Path = "C:\Users\user\Documents\Q.txt"; Root = $null}
            @{Path = "D:\Projects\Demo\Main.cs"; Root = "D:\Projects"}
            @{Path = "\\Server\Share\Folder\File.docx"; Root = "\\Server\Share"}
        )

        # Loop through each test case and assert the output of function Get-GitRoot
        It "Returns the root of the parent git repo of <Path>, or null if not found" -TestCases $testCases {
            param ($Path, $Root)
            # Invoke function Get-GitRoot on the path and store the result
            $result = Get-GitRoot -path $Path
            # Assert that the result is equal to the expected root or null
            $result | Should -Be $Root
        }
    }

    # Test the function Remove-Memory with some sample paths
    Context "Function Remove-Memory" {

        # Define some test cases with expected outputs
        $testCases = @(
            @{Path = "C:\Users\user\Documents\Q.txt"; Output = "Failed to remove memory of 'Documents' from git history"}
            @{Path = "D:\Projects\Demo\Main.cs"; Output = "Successfully removed memory of 'Demo' from git history"}
            @{Path = "\\Server\Share\Folder\File.docx"; Output = "Successfully removed memory of 'Folder' from git history"}
        )

        # Loop through each test case and assert the output of function Remove-Memory
        It "Removes the memory of the parent directory of <Path> in the parent git repo, if any" -TestCases $testCases {
            param ($Path, $Output)
            # Invoke function Remove-Memory on the path and capture the output
            $result = Remove-Memory -path $Path 2>&1 | Out-String | Trim 
            # Assert that the output is equal to the expected output or an error message
            $result | Should -Be $Output
        }
    }
}