function ActOnError  {     
    <#todo
fallback solutions
* if everything fails,
    set git dir path to abbsolute value and edit work tree in place
* if comsumption fails,
    due to modulefolder exsisting, revert move and trye to use exsisting folder instead,
    if this ressults in error, re revert to initial
    move inplace module to x prefixed
    atempt to consume again
* if no module is provided, utelyse everything to find possible folders
    use hamming distance like priorit order
    where
    1. exact parrentmatch        rekative to root
        order resukts by total exact
    take first precedance
    2. predefined patterns taken
    and finaly sort rest by hamming
#>

# This script converts a git folder into a submodule and absorbs its git directory

    [CmdletBinding()]
    param (          # Validate the arguments
        $folder = "C:\ProgramData\scoop\persist", 
        $repairAlternatives = "C:\ProgramData\scoop\persist\.git\modules")
    begin {
        
Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % { . $_.FullName }        

    Validate-Path $repairAlternatives
    Validate-Path $folder
    Push-Location
    $pastE = $error    #past error saved for later
    $error.Clear()
    
    # Save the previous error action preference
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
    # Set the environment variable for git error redirection
    $env:GIT_REDIRECT_STDERR = '2>&1'
}

process {
    # Get the list of folders in $folder # Loop through each folder and run git status
    foreach ($f in (git-GetSubmodulePathsUrls)) {
        # Change the current directory to the folder
        Set-Location $f.FullName
        Write-Verbos "checking $f"

        if (!(Get-ChildItem -force | ?{ $_.name -eq ".git" } )) { Write-Verbos "$f not yet initialized" }
        else {
            # Run git status and capture the output
            $output = Check-GitStatus $f.FullName
            
            if(!($output -like "fatal*")) {Write-Output @($output)[0] }
            else { 
                Write-Output "fatal status for $f"
                $f | Get-ChildItem -force | ?{ $_.name -eq ".git" } | % {
                    $toRepair = $_
        
                    if( $toRepair -is [System.IO.FileInfo] )
                    {
                        $repairAlternatives | Get-ChildItem -Directory | ?{ $_.name -eq $toRepair.Directory.Name } | select -First 1 |
                        % {
                            # Move the folder to the target folder Move-Folder -Source $GitFolder -Destination (Join-Path $targetFolder 'x.git')

                            rm $toRepair -force ;   
                            # Move the submodule folder to replace the git folder
                            Move-Item -Path $_.fullname -Destination $toRepair -force 
                        }
                    }
                    else-if( $toRepair -is [System.IO.DirectoryInfo] )
                    {  
                    # Remove the worktree line from the config file              (Get-Content -Path $configFile | Where-Object { ! ($_ -match 'worktree') }) | Set-Content -Path $configFile
                        Remove-Worktree "$toRepair/config"
                    }
                    else
                    {
                        Write-Error "not a .git folder: $toRepair"
                        Write-Error "not a .git file: $toRepair"                        
                    }
                    removeAtPathReadToIndex
                }
            }
        }
    }
} end { Pop-Location }

}