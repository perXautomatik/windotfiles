function FilterBySubdirectory($baseRepo = 'C:\Users\chris\AppData', $targetRepo = 'D:\ToGit\AppData',$toFilterRepo = 'D:\ToGit\Vortex', $toFilterBy = 'Roaming/Vortex/', $branchName = 'LargeINcluding' )
{
    Push-Location

    # Check if the path is valid
    if (Test-Path $baseRepo) {
      # Move to the path
      Set-Location $baseRepo

        git push --all $targetRepo

        cd $toFilterRepo

        git filter-branch -f --subdirectory-filter $toFilterBy -- --all 

        #If you want to pull in any new commits to the subtree from the remote:

        git subtree pull --prefix $toFilterBy $baseRepo $branchName
    
      # Do something else here
    }
    else {
      # Write an error message to the standard error stream
      Write-Error "The path $path does not exist."
      # Exit with a non-zero exit code
      exit 1
    }

    Pop-Location
}