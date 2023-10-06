# Import the PSReadLine module
Import-Module PSReadLine

# Get the AST of the current PowerShell profile
$tokens = $errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($PROFILE, [ref]$tokens, [ref]$errors)

# Get the function definition ASTs from the profile AST
$functionDefinitions = $ast.FindAll({
    param([System.Management.Automation.Language.Ast] $Ast)
    $Ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
}, $true)

# Get the names of the functions from the function definition ASTs
$functionNames = $functionDefinitions | ForEach-Object { $_.Name }

# Define a custom tab completion function that shows the function names as menu suggestions
function Complete-FunctionName {
    param($wordToComplete, $commandAst, $cursorPosition)

    # Filter the function names that match the word to complete
    $matchingNames = $functionNames | Where-Object { $_ -like "$wordToComplete*" }

    # Create completion results for each matching name
    $completionResults = $matchingNames | ForEach-Object {
        # Get the function definition AST for the matching name
        $functionDefinition = $functionDefinitions | Where-Object { $_.Name -eq $_ }

        # Get the function body as a script block
        $functionBody = $functionDefinition.Body.GetScriptBlock()

        # Create a completion result with the function body as the completion text and the function name as the tooltip
        New-Object System.Management.Automation.CompletionResult -ArgumentList (
            "'$functionBody'",
            $_,
            'ParameterValue',
            $_
        )
    }

    # Return the completion results
    $completionResults
}

# Register the custom tab completion function for PSReadLine
Register-ArgumentCompleter -Native -CommandName Invoke-Expression -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $cursorPosition)
    Complete-FunctionName $wordToComplete $commandAst $cursorPosition
}

# Define a helper function to replace a function definition in a file
function Replace-FunctionDefinition {
    param($fileName, $oldFunctionDefinition, $newFunctionDefinition)

    # Get the content of the file as an array of lines
    $fileContent = Get-Content -Path $fileName

    # Find the index of the line where the old function definition starts
    $startIndex = $fileContent.IndexOf($oldFunctionDefinition.Extent.Text)

    # Find the index of the line where the old function definition ends
    $endIndex = ($startIndex + ($oldFunctionDefinition.Extent.EndLineNumber - $oldFunctionDefinition.Extent.StartLineNumber))

    # Replace the lines between the start and end indexes with the new function definition
    $fileContent[$startIndex..$endIndex] = "'$newFunctionDefinition'"

    # Set the content of the file with the modified array of lines
    Set-Content -Path $fileName -Value $fileContent
}

# Define a main function to update a function definition in the profile
function Update-FunctionDefinition {
    param($expression)

    # Evaluate the expression as a script block and get its AST
    $newFunctionBodyAst = [System.Management.Automation.Language.Parser]::ParseInput($expression, [ref]$null, [ref]$null).Find({
        param([System.Management.Automation.Language.Ast] $Ast)
        $Ast -is [System.Management.Automation.Language.ScriptBlockExpressionAst]
    }, $false).ScriptBlock

    # Check if the AST is a valid function body
    if ($newFunctionBodyAst) {
        # Get the name of the function from the first comment line in the function body
        $functionName = ($newFunctionBodyAst.BeginBlock.Statements[0] -as [System.Management.Automation.Language.CommentAst]).Text.TrimStart('#').Trim()

        # Check if the function name is valid and exists in the profile
        if ($functionName -and ($functionNames -contains $functionName)) {
            # Get the old function definition AST from the profile AST by name
            $oldFunctionDefinition = $functionDefinitions | Where-Object { $_.Name -eq $functionName }

            # Replace the old function definition with the new function body in the profile file
            Replace-FunctionDefinition -FileName $PROFILE -OldFunctionDefinition $oldFunctionDefinition -NewFunctionDefinition $newFunctionBodyAst

            # Write a success message to the output
            Write-Output "Successfully updated function '$functionName' definition"
        }
        else {
            # Write an error message to the output
            Write-Error "Invalid or non-existent function name: '$functionName'"
        }
    }
    else {
        # Write an error message to the output
        Write-Error "Invalid function body: '$expression'"
    }
}

# Invoke the main function with the user input
Update-FunctionDefinition -Expression (Read-Host "Enter a function body")
