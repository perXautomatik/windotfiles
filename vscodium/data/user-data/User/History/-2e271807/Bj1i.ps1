# Synopsis: This function copies a diff from git to move a file
# Parameters: 
#   -LocalRelative: The relative path of the local file
#   -RemoteRelative: The relative path of the remote file
#   -Root: The root path of the project
function Copy-DiffToMove {
    param(
        [Parameter(Mandatory=$true)]
        [string]$LocalRelative,
        [Parameter(Mandatory=$true)]
        [string]$RemoteRelative,
        [Parameter(Mandatory=$true)]
        [string]$Root
    )
    # Clear the screen
    cls

    # Change the current directory to the root path
    cd $Root

    # Get the absolute paths of the local and remote files
    $Local = (Join-Path -Path $Root -ChildPath $LocalRelative)
    $Remote = Join-Path -Path $Root -ChildPath $RemoteRelative

    # Replace backslashes with forward slashes for Linux compatibility
    $LocalLinux = $Local.Replace('\','/') 
    $RemoteLinux = $Remote.Replace('\','/')

    # Check if the local and remote files are in the git index
    $InIndexLocal = (git ls-files --error-unmatch $LocalRelative) 
    $InIndexRemote = (git ls-files --error-unmatch $RemoteRelative)

    # If the local file is not in the index, add it and commit it
    if (-not $InIndexLocal)
    { 
        if(Test-Path ($Local))
        {
            git add $LocalRelative --force 
            git commit -m "Add local file"
        }
    }

    # If the remote file is not in the index, add it and commit it
    if (-not $InIndexRemote)
    {
        if(Test-Path ($Remote))
        {
            git add $RemoteRelative --force 
            git commit -m "Add remote file"
        }
    }

    # Check if the remote file exists
    $DestinationExists = Test-Path $Remote

    # If the remote file exists, remove the local file from git
    if($DestinationExists)
    {    
        git rm $LocalRelative  
    }
    # Otherwise, move the local file to the remote location in git
    else
    {
        git mv $LocalRelative $RemoteRelative
    }
}
