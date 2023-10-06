# Define the path of the PS1 file
 function SplitOutFunctions ($PS1File)
{
    # Load the PS1 file as an AST
    $AST = [System.Management.Automation.Language.Parser]::ParseFile($PS1File, [ref]$null, [ref]$null)

    # Get all the function definitions in the AST
    $Functions = $AST.FindAll({$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]}, $true)

    # Loop through each function definition
    foreach ($Function in $Functions) {
        # Get the function name
        $FunctionName = $Function.Name

        # Get the function body as a string
        $FunctionBody = $Function.Extent.Text

        # Define the path of the new file with the function name
        $NewFile = Join-Path (Split-Path $PS1File) ($FunctionName + ".ps1")

        # Write the function body to the new file
        Set-Content -Path $NewFile -Value $FunctionBody
    }
}