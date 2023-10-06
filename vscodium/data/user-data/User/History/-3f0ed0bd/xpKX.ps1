<#
can you write me a powershell script; given a number of relative paths to asingle local git repo,;
 using a function taking a single relative path as parameter, 
 that uses git log --follow to get a list of all commits toutching a path including renames, 
 returning a list of ps custom objects with properties "commit date" and sha1
 #>


. .\Get-CommitsByPath.ps1


. .\Get-CommitInfoByPath.ps1

. .\Get-PathsByFile.ps1

function chain-RenameForced ($paths, $newname) {

    <# Define a function that takes an array of paths and a new filename as parameters
     with a callback function to change any commit with a path contained in the parameter array, moving any file in the commit that has a path 
    contained in the array parameter to the path by the relative path parameter.
    position, then use a function that eather uses git filter-branch or git filter-repo to move each of the other paths into the "oldest paths" 
    head location, except in case of the repository at the commit already have a file occypying that path at the time, then it overwrites that 
    path with the content of the newer path,#>
    
        # Initialize an empty string to store the Python callback code
        $callback = ""
    
        # Loop through each path and add a rename-path option to the callback code
        foreach ($path in $paths) {
            # Add a line of Python code that checks if the file already exists at the new filename
            $callback += "if os.path.exists(os.path.join(repopath, b'$newname')): "
            # If it does, remove the file
            $callback += "os.remove(os.path.join(repopath, b'$newname')); "
            # Then rename the path to the new filename
            $callback += "if filepath == b'$path': filepath = b'$newname'; "
        }
    
        # Invoke git filter-repo with the --filename-callback option and the callback code
        git filter-repo --filename-callback $callback
    }

# Given a number of relative paths to a single local git repo
$paths = @("src/main.c", "src/helper.c", "README.md")

<#can you write me a script that, given a list of paths ; sort each path in order of oldest to youngest by there oldest "commit date", identifying the oldest commit as $oldest, #>

# Loop through each path and call the function
$sorted = $paths| % { Get-CommitInfoByPath $_ } | sort -property date 

$oldest = $sorted | select -first 1
$toMove = $sorted | select -skip 1

<#then uses a function that lists the relative paths $oldest have had through out the repo into an array $oldPaths, #>
$oldPaths = get-pathsByFile $oldest

. .\chain-renamePaths.ps1


chain-renamePaths $oldPaths $oldest.path

$toMove | ? { $_.path -notin $oldPaths } | 
%{ 
    $tm = $_ 
    $op = ( get-pathsByFile $tm ) | ? { $_.path -notin $oldPaths } 

    if($op)
    {
        chain-RenameForced $op $tm
    }
}
    



