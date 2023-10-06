. 'B:\PF\Archive\ps1\workflow\Beyond compare interaction\HelperScript\csharp-sort.ps1' 

# Define some sample C# code for testing
$sampleCode = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sample
{
    public class Program
    {
        public static void Main(string[] args)
        {
            Console.WriteLine("Hello, world!");
        }

        private static void Foo()
        {
            Console.WriteLine("Foo");
        }

        public static void Bar()
        {
            Console.WriteLine("Bar");
        }
    }
}
"@

# Define some expected C# code for testing
$expectedCode = @"
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sample
{
    public class Program
    {
        public static void Bar()
        {
            Console.WriteLine("Bar");
        }

        public static void Main(string[] args)
        {
            Console.WriteLine("Hello, world!");
        }

        private static void Foo()
        {
            Console.WriteLine("Foo");
        }
    }
}
"@

# Define a Pester test script
Describe 'Sort-UsingDirectivesAndFunctions' {
    It 'Sorts using directives and functions in C# code' {
        # Call the Sort-UsingDirectivesAndFunctions function with the sample C# code
        $sortedCode = Sort-UsingDirectivesAndFunctions($sampleCode)

        # Assert that the sorted C# code is equal to the expected C# code
        $sortedCode | Should -Be $expectedCode
    }
}

# Run the Pester test script and output the results
