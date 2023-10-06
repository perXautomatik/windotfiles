function Sort-UsingDirectivesAndFunctions($text) {
  # Parse the text as a C# syntax tree using Roslyn API
  Add-Type -Path "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\Roslyn\Microsoft.CodeAnalysis.CSharp.dll"
  $tree = [Microsoft.CodeAnalysis.CSharp.CSharpSyntaxTree]::ParseText($text)

  # Get the root node of the tree
  $root = $tree.GetRoot()

  # Get the using directives and functions nodes from the root node
  $directives = $root.DescendantNodes() | Where-Object { $_ -is [Microsoft.CodeAnalysis.CSharp.Syntax.UsingDirectiveSyntax] }
  $functions = $root.DescendantNodes() | Where-Object { $_ -is [Microsoft.CodeAnalysis.CSharp.Syntax.MethodDeclarationSyntax] }

  # Sort the using directives alphabetically by their name
  $sortedDirectives = $directives | Sort-Object -Property { $_.Name.ToString() }

  # Sort the functions by their name, ignoring the parameters and return type, and by their accessibility (public before private)
  $sortedFunctions = $functions | Sort-Object -Property { $_.Identifier.ToString() }, { if ($_.Modifiers.ToString() -eq "public") { 0 } else { 1 } }

  # Create a new root node with the sorted using directives and functions nodes replacing the original ones
  $newRoot = $root.ReplaceNodes($directives, { param($oldNode, $newNode) $sortedDirectives[$directives.IndexOf($oldNode)] })
  $newRoot = $newRoot.ReplaceNodes($functions, { param($oldNode, $newNode) $sortedFunctions[$functions.IndexOf($oldNode)] })

  # Return the new root node as a formatted text
  return $newRoot.ToFullString()
}
