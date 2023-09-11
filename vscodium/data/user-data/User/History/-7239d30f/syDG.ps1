
function Find-Git-Roots {
    <#
.SYNOPSIS
Finds the git roots of the subdirectories under a given path and joins them with the subdirectory names.

.DESCRIPTION
This function finds the git roots of the subdirectories under a given path and joins them with the subdirectory names, using the git rev-parse command and the Linq.Enumerable.Join method. The function exports the results to a csv file and returns an array of joined names.

.PARAMETER BasePath
The path where the subdirectories are located.

.PARAMETER CsvPath
The path of the csv file where the results will be exported.
#>
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[string]
	$BasePath,

	[Parameter(Mandatory = $true)]
	[string]
	$CsvPath
    )

    # Redirect the standard error output to standard output for git commands
    [Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

    # Get all the subdirectories under the base path recursively
    $subdirs = Get-ChildItem -Path $BasePath -Recurse -Directory

    # Loop through each subdirectory and find its git root
    $results = foreach ($subdir in $subdirs) {
	# Change the current location to the subdirectory
	Set-Location -Path $subdir.FullName

	# Create a custom object with the subdirectory name, path and git root
	[PSCustomObject]@{
	    FolderName = $subdir.Name
	    path       = $subdir.FullName
	    gitRoot    = (git rev-parse --show-toplevel)
	}
    }

    # Export the results to a csv file
    Export-Git-Roots -Results $results -CsvPath $CsvPath

    # Read the csv file and convert it to an array of objects
    $z = Import-Git-Roots -CsvPath $CsvPath

    # Filter out the objects that have a valid git root and create an array of paths
    [Path[]]$Paths = Filter-Git-Paths -Objects $z

    # Filter out the objects that have a git root equal to their path and create an array of roots
    [Root[]]$Roots = Filter-Git-Roots -Objects $z

    # Define a function to get the name property of an object
    [System.Func[System.Object, string]]$getName = {
	param ($x)
	$x.Name
    }

    # Join the roots and paths by their names and return an array of joined names
    Join-Git-Names -Roots $Roots -Paths $Paths -GetName $getName
}

function Export-Git-Roots {
    
<#
.SYNOPSIS
Exports an array of custom objects with folder name, path and git root to a csv file.

.DESCRIPTION
This function exports an array of custom objects with folder name, path and git root to a csv file, using the ConvertTo-Csv and Out-File cmdlets.

.PARAMETER Results
The array of custom objects to export.

.PARAMETER CsvPath
The path of the csv file where the results will be exported.
#>
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[PSCustomObject[]]
	$Results,

	[Parameter(Mandatory = $true)]
	[string]
	$CsvPath
    )

    # Export the results to a csv file
    $Results | ConvertTo-Csv | Out-File -Path $CsvPath
}

function Import-Git-Roots {
    
<#
.SYNOPSIS
Imports an array of custom objects with folder name, path and git root from a csv file.

.DESCRIPTION
This function imports an array of custom objects with folder name, path and git root from a csv file, using the Get-Content and ConvertFrom-Csv cmdlets.

.PARAMETER CsvPath
The path of the csv file where the results are stored.
#>
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[string]
	$CsvPath
    )

    # Read the csv file and convert it to an array of objects
    Get-Content -Path $CsvPath | ConvertFrom-Csv
}

function Filter-Git-Paths {
    
<#
.SYNOPSIS
Filters out the objects that have a valid git root and creates an array of paths.

.DESCRIPTION
This function filters out the objects that have a valid git root and creates an array of paths, using a custom class for paths and a Where-Object filter.

.PARAMETER Objects
The array of custom objects to filter.
#>
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[PSCustomObject[]]
	$Objects
    )

    # Define a class for paths
    class Path {
	[string] $Name;
	[string] $path;

	Path($name, $path) {
	    $this.path = $path
	    $this.Name = $name
	}
    }

    # Filter out the objects that have a valid git root and create an array of paths
    [Path[]]$Paths = @($Objects | Where-Object { $_.gitRoot -ne "fatal: this operation must be run in a work tree" } | ForEach-Object { [Path]::new($_.FolderName, $_.path) })
}

function Filter-Git-Roots {
    
<#
.SYNOPSIS
Filters out the objects that have a git root equal to their path and creates an array of roots.

.DESCRIPTION
This function filters out the objects that have a git root equal to their path and creates an array of roots, using a custom class for roots and a Where-Object filter.

.PARAMETER Objects
The array of custom objects to filter.
#>
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[PSCustomObject[]]
	$Objects
    )

    # Define a class for roots
    class Root {
	[string] $Name;
	[string] $gitRoot;
	Root($name, $gitRoot) {
	    $this.name = $name
	    $this.gitRoot = $gitRoot
	}
    }

    # Filter out the objects that have a git root equal to their path and create an array of roots
[Path[]]$Paths = @($z | ? { $_.gitRoot -ne "fatal: this operation must be run in a work tree" } | % {[Path]::new($_.FolderName, $_.path) })
    [Root[]]$Roots = @($Objects | Where-Object { ($_.gitRoot -replace('/', '\')) -eq $_.path } | ForEach-Object { [Root]::new($_.FolderName, $_.GitRoot) })

$outerKeyDelegate = [Func[Path,String]] { $args[0].Name }
$innerKeyDelegate = [Func[Root,String]] { $args[0].Name }

#In this instance both joins will be using the same property name so only one function is needed
[System.Func[System.Object, string]]$JoinFunction = {
    param ($x)
    $x.Name
}

#This is the delegate needed in GroupJoin() method invocations
[System.Func[System.Object, [Collections.Generic.IEnumerable[System.Object]], System.Object]]$query = {
    param(
	$LeftJoin,
	$RightJoinEnum
    )
    $RightJoin = [System.Linq.Enumerable]::SingleOrDefault($RightJoinEnum)

    New-Object -TypeName PSObject -Property @{
	Name = $RightJoin.Name;
	GitRoot = $RightJoin.GitRoot;
	Path = $LeftJoin.Path
    }
}

#And lastly we call GroupJoin() and enumerate with ToArray()
$q = [System.Linq.Enumerable]::ToArray(
    [System.Linq.Enumerable]::GroupJoin($Paths, $Roots, $JoinFunction, $JoinFunction, $query)
)  | ? { ($_.name -ne "") -and ($null -ne $_.name) }

    $q | Out-GridView
}


function Join-Git-Names {
    <#
.SYNOPSIS
Joins the roots and paths by their names and returns an array of joined names.

.DESCRIPTION
This function joins the roots and paths by their names and returns an array of joined names, using the Linq.Enumerable.Join method and a function to get the name property of an object.

.PARAMETER Roots
The array of roots to join.

.PARAMETER Paths
The array of paths to join.

.PARAMETER GetName
The function to get the name property of an object.
#>
    [CmdletBinding()]
    param (
	[Parameter(Mandatory = $true)]
	[Root[]]
	$Roots,

	[Parameter(Mandatory = $true)]
	[Path[]]
	$Paths,

	[Parameter(Mandatory = $true)]
	[System.Func[System.Object, string]]
	$GetName
    )

    # Join the roots and paths by their names and return an array of joined names
    [Linq.Enumerable]::Join($Roots, $Paths, $GetName, $GetName, $GetName)
}