<# 


Source: Conversation with Bing, 2023-06-26
(1) Recursive file search using PowerShell - Stack Overflow. https://stackoverflow.com/questions/8677628/recursive-file-search-using-powershell.
(2) powershell - Get List Of Functions From Script - Stack Overflow. https://stackoverflow.com/questions/40967449/get-list-of-functions-from-script.
(3) function - Powershell Recursion with Return - Stack Overflow. https://stackoverflow.com/questions/4989021/powershell-recursion-with-return.
(4) Recursion in PowerShell - DEV Community. https://dev.to/omiossec/recursion-in-powershell-2b85.
(5) Is there a way to retrieve a PowerShell function name from within a .... https://stackoverflow.com/questions/3689543/is-there-a-way-to-retrieve-a-powershell-function-name-from-within-a-function.
(6) Functions - PowerShell | Microsoft Learn. https://learn.microsoft.com/en-us/powershell/scripting/learn/ps101/09-functions?view=powershell-7.3.
#>

# Define a pattern to match function names
$pattern = 'function\s+([_\-\w]+)'

# Search recursively for PowerShell script and module files
$files = Get-ChildItem -Path 'B:\GitPs1Module' -Filter *.ps*1 -Recurse -ErrorAction SilentlyContinue -Force

# Create an empty list to store the results
$results = @()

# Loop through each file
foreach ($file in $files) {
      # Read the file content as a single string
    $content = Get-Content -Path $file.FullName -Raw

    # Parse the content into tokens and errors
    $tokens = [System.Management.Automation.PSParser]::Tokenize($content, [ref]$null)

    # Filter the tokens by type Function
    $functionTokens = $tokens | Where-Object { $_.Type -eq 'CommandArgument' }





      # Create a custom object with the file location, function name and function body
      $result = [PSCustomObject]@{
        FileLocation = $file.FullName
        FunctionName = $functionName
        FunctionBody = $functionBody
      }

      # Add the result to the list
      $results += $result
      }
}

# Sort the results by function name and file location
$results = $results | Sort-Object FunctionName, FileLocation

# Display the results as a table
$results | Format-Table -AutoSize
