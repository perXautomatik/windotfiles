. $PSScriptRoot\splitJoin-File-ByExtension.ps1

Describe ‘Join-ScriptFiles’ {

# Set up some variables and files for testing
BeforeAll {
    # Create a temporary source path with some script files
    $SourcePath = Join-Path -Path $TestDrive -ChildPath 'Source'
    New-Item -Path $SourcePath -ItemType Directory | Out-Null
    New-Item -Path (Join-Path -Path $SourcePath -ChildPath 'Script1.ps1') -ItemType File -Value 'Write-Host "Hello from Script1"' | Out-Null
    New-Item -Path (Join-Path -Path $SourcePath -ChildPath 'Script2.ps1') -ItemType File -Value 'Write-Host "Hello from Script2"' | Out-Null
    New-Item -Path (Join-Path -Path $SourcePath -ChildPath 'Subfolder\Script3.ps1') -ItemType File -Value 'Write-Host "Hello from Script3"' | Out-Null

    # Define a delimiter for joining the script files
    $Delimiter = '# {0}'

    # Define a destination file for joining the script files
    $DestinationFile = Join-Path -Path $TestDrive -ChildPath 'JoinedScripts.ps1'
}

# Clean up the temporary files after testing
AfterAll {
    Remove-Item -Path $SourcePath -Recurse | Out-Null
    Remove-Item -Path $DestinationFile | Out-Null
}

# Define a test case for joining the script files
It 'Joins all script files in the source path with the delimiter and writes them to the destination file' {
    # Call the function with the parameters
    Join-ScriptFiles -SourcePath $SourcePath -DestinationFile $DestinationFile -Delimiter $Delimiter

    # Assert that the destination file exists
    $DestinationFile | Should -Exist

    # Assert that the destination file contains all script files content with the delimiter
    $ExpectedContent = @(
        "# \Script1.ps1"
        "Write-Host `"Hello from Script1`""
        "# \Script2.ps1"
        "Write-Host `"Hello from Script2`""
        "# \Subfolder\Script3.ps1"
        "Write-Host `"Hello from Script3`""
    )
    Get-Content -Path $DestinationFile | Should -BeExactly $ExpectedContent
}

}

Describe ‘Split-ScriptFiles’ {

# Set up some variables and files for testing
BeforeAll {
    # Create a temporary source file with some joined script files content
    $SourceFile = Join-Path -Path $TestDrive -ChildPath 'JoinedScripts.ps1'
    New-Item -Path $SourceFile -ItemType File | Out-Null
    Set-Content -Path $SourceFile @(
        "# \Script1.ps1"
        "Write-Host `"Hello from Script1`""
        "# \Script2.ps1"
        "Write-Host `"Hello from Script2`""
        "# \Subfolder\Script3.ps1"
        "Write-Host `"Hello from Script3`""
    )

    # Define a delimiter pattern for splitting the script files
    $DelimiterPattern = '# \(.+\)'

    # Define a destination path for splitting the script files
    $DestinationPath = Join-Path -Path $TestDrive -ChildPath 'Scripts'
}

# Clean up the temporary files after testing
AfterAll {
    Remove-Item -Path $SourceFile | Out-Null
    Remove-Item -Path $DestinationPath -Recurse | Out-Null
}

# Define a test case for splitting the script files
It 'Splits the source file by the delimiter pattern and writes the script files to the destination path' {
    # Call the function with the parameters
    Split-ScriptFiles -SourceFile $SourceFile -DestinationPath $DestinationPath -DelimiterPattern $DelimiterPattern

    # Assert that the destination path exists
    $DestinationPath | Should -Exist

    # Assert that the destination path contains all script files with the correct content
    $ExpectedFiles = @(
        (Join-Path -Path $DestinationPath -ChildPath 'Script1.ps1'),
        (Join-Path -Path $DestinationPath -ChildPath 'Script2.ps1'),
        (Join-Path -Path $DestinationPath -ChildPath 'Subfolder\Script3.ps1')
    )
    Get-ChildItem -Path $DestinationPath -Filter *.ps1 -Recurse | Select-Object -ExpandProperty FullName | Should -BeExactly $ExpectedFiles

    Get-Content -Path (Join-Path -Path $DestinationPath -ChildPath 'Script1.ps1') | Should -BeExactly 'Write-Host "Hello from Script1"'
    Get-Content -Path (Join-Path -Path $DestinationPath -ChildPath 'Script2.ps1') | Should -BeExactly 'Write-Host "Hello from Script2"'
    Get-Content -Path (Join-Path -Path $DestinationPath -ChildPath 'Subfolder\Script3.ps1') | Should -BeExactly 'Write-Host "Hello from Script3"'
}

}