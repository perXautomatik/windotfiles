# This function parses a given folder for git repositories and outputs their names, paths, git roots and statuses.
# It also exports the results to a csv file and displays them in a grid view.
# It uses LINQ to join the paths and roots by their names.



function ParseFoldersForGit {
    param(
	# The folder to parse for git repositories
	[Parameter(Mandatory=$true)]
	[string]$folder
    )
	begin {
		    # Define a helper function to get all subfolders except those with .git
			function getFolders {
				Get-ChildItem -Recurse -Directory | ? { !($_.FullName -like '*.git*') }
				}
			
			function about-path ($p)
			{
					cd $p.FullName
					$properties = [ordered]@{
						FolderName = $_.Name
						path = $_.FullName
						gitRoot = (git rev-parse --show-toplevel)
						status = (git status)
					}
				New-Object –TypeName PSObject -Property $properties
			}
		
			# Define a class for paths with name and path properties
			class Path {
				[string] $Name;
				[string] $path;
			
				Path($name,$path) {
					$this.path = $path
					$this.Name = $name
				}
				}
			
				# Define a class for roots with name and gitRoot properties
				class Root {
				[string] $Name;
				[string] $gitRoot;
				Root($name,$gitRoot) {
					$this.name = $name
					$this.gitRoot = $gitRoot
				}
				}
			# Define a function to join the paths and roots by their names using LINQ GroupJoin method
			function Join-PathsAndRoots {
				param(
					[Path[]]$paths,
					[Root[]]$roots
				)

				# Define a function to get the name property of an object
				[System.Func[System.Object, string]]$GetName = {
					param ($x)
					$x.Name
			}					
		}
}
	process{
    # Set the environment variable for git redirection
    [Environment]::SetEnvironmentVariable('GIT_REDIRECT_STDERR', '2>&1', 'Process')

    # Change the current directory to the folder
    cd $folder

	# Loop through each subfolder and get its name, path, git root and status
	$results = getFolders | % {
		about-path $_
	}

    # Export the results to a csv file
    $csvFile = "$folder\GitRoots.csv"
    $results | ConvertTo-Csv | out-file $csvFile

    # Read the csv file and convert it to objects
    $z = get-content $csvFile | ConvertFrom-Csv

    # Filter the results by valid git roots and create Path and Root objects from them
    [Path[]]$Paths = @($z | ? { $_.gitRoot -ne "fatal: this operation must be run in a work tree" } | % {[Path]::new($_.FolderName, $_.path) })
    [Root[]]$Roots = @($z | ? { ($_.gitRoot -replace('/','\')) -eq $_.path } | % {[Root]::new($_.FolderName, $_.GitRoot) })


	# Define a function to create a new object from the joined paths and roots
	[System.Func[System.Object, [Collections.Generic.IEnumerable[System.Object]], System.Object]]$CreateObject = {
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

	# Call the GroupJoin method and return an array of joined objects
	return [System.Linq.Enumerable]::ToArray(
	    [System.Linq.Enumerable]::GroupJoin($paths, $roots, $GetName, $GetName, $CreateObject)
	)
    

    # Call the join function and filter out empty or null names
    $q = Join-PathsAndRoots -paths $Paths -roots $Roots | ? { ($_.name -ne "") -and ($null -ne $_.name) }

    # Output the results in a grid view
    $q | Out-GridView
	}
}

# Example usage: Parse the folder "B:\ToGit\" for git repositories
ParseFoldersForGit -folder "B:\ToGit\"
