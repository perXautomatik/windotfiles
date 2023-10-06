# This script is a git commit hook that splits the commit message into multiple messages, one for each function changed in the commit content.

# Define the input parameters
param(
    # The commit message as a string
    [Parameter(Mandatory=$true)]
    [string]$commitMessage,

    # The commit content as a string
    [Parameter(Mandatory=$true)]
    [string]$commitContent
)

# Validate the input parameters
if ($commitMessage -eq "" -or $commitContent -eq "") {
    # Throw an error if either parameter is empty
    throw "The commit message and the commit content cannot be empty."
}

if ($commitMessage -notmatch "^[a-zA-Z0-9\s]+$" -or $commitContent -notmatch "^[a-zA-Z0-9\s\{\}\(\)\[\]\+\-\=\*\;\<\>\:\,\.\!\?\$]+$") {
    # Throw an error if either parameter is not valid powershell code
    throw "The commit message and the commit content must be valid powershell code."
}

# Use AST to identify all function definitions in the commit content.
$tree = $ast.Parse($commitContent)
$functions = @()
foreach ($node in $tree.Body) {
    if ($node.GetType() -eq $ast.FunctionDef) {
        # Add the function name to the functions array
        $functions += $node.Name
    }
}

# Split the commit message into multiple messages, one per function changed.
$commitMessages = @()
foreach ($function in $functions) {
    # Append the function name in parentheses to the original message
    $commitMessages += "$commitMessage ($function)"
}

# Return the list of commit messages.
return $commitMessages
