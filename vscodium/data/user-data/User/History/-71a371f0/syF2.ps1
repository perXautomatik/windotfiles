# Define a custom class that implements the ICustomBinaryOperator interface
Add-Type -TypeDefinition @'
using System;
using System.Linq.Expressions;
using System.Management.Automation;

public class StartsWithOperator : ICustomBinaryOperator
{
    public string Name => "startswith";

    public ExpressionType ExpressionType => ExpressionType.Extension;

    public Type ReturnType => typeof(bool);

    public Expression Reduce(Expression left, Expression right)
    {
        // Convert both expressions to strings
        var leftString = Expression.Convert(left, typeof(string));
        var rightString = Expression.Convert(right, typeof(string));

        // Call the StartsWith method with case-insensitive comparison
        var comparison = Expression.Constant(StringComparison.CurrentCultureIgnoreCase);
        var method = typeof(string).GetMethod("StartsWith", new[] { typeof(string), typeof(StringComparison) });
        var call = Expression.Call(leftString, method, rightString, comparison);

        // Return the result of the method call
        return call;
    }
}
'@

# Register the custom operator with PowerShell
$operator = [StartsWithOperator]::new()
[PowerShell]::AddOperator($operator)

# Test the custom operator
"apple" -startswith "a" # True
"banana" -startswith "a" # False