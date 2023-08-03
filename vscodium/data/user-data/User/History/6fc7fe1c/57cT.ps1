Sync-FilesByRelativePath -ToModify 'B:\PF\PowerShell' -Reference 'B:\PF\PowershellProjectFolder'
# Synopsis: Get a list of files in a given path, relative to that path
function Get-RelativeFileList {
    param (
	[Parameter(Mandatory=$true)]
	[string]$Path
    )
    # Get all the files in the path recursively
    $files = Get-ChildItem -Path $Path -File -Recurse
    # For each file, get its relative path by removing the base path
    $relativeFiles = $files | ForEach-Object {
	$_.FullName.Replace($Path,'').ToString()
    }
    # Return the relative file list
    return $relativeFiles
}
  
    # Synopsis: Get the relative path of a file by removing a base path
    function Get-RelativePath {
        param (
            [Parameter(Mandatory=$true)]
            [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
            [string]$FilePath,
            [Parameter(Mandatory=$true)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string]$BasePath
        )

        # Remove the base path from the file path and return the result
        return $FilePath.Replace($BasePath,'')
    }

    # Synopsis: Create a directory if it does not exist
    function Ensure-Directory {
        param (
            [Parameter(Mandatory=$true)]
            [ValidateScript({Test-Path -Path $_ -PathType Container})]
            [string]$DirectoryPath
        )

        # Check if the directory exists and create it if not
        if (-not (Test-Path -Path $DirectoryPath)) {
            New-Item -ItemType Directory -Path $DirectoryPath | Out-Null
        }
    }
    # Synopsis: Move a file using git mv and commit with a message
function Move-FileWithGit {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$SourceFile,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$DestinationFile,
        [Parameter(Mandatory=$true)]
        [string]$CommitMessage
    )

    # Use git mv to move the file and commit with the message
    try {
        # Use -f to force overwrite existing files
        git mv -f $SourceFile $DestinationFile -ErrorAction Stop
        git commit -m "$CommitMessage" -ErrorAction Stop
        Write-Output "Successfully moved and committed $SourceFile to $DestinationFile"
    }
    catch {
        # Catch any errors and display them
        Write-Error "Failed to move and commit $SourceFile to $DestinationFile"
        Write-Error $_.Exception.Message
    }
}

 
# Synopsis: Move a file in one path to match the relative path of another file in a different path, using git mv and commit if a git repo is involved
function Move-FileToMatchRelativePath {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$SourceFile,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$TargetFile,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$BaseFolderToChange,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Container})]
        [string]$ReferenceFolder
    )

    # Get the relative paths of the source and target files by using the Get-RelativePath function
    try {
        $sourceRelativePath = Get-RelativePath -FilePath $SourceFile -BasePath $BaseFolderToChange
        $relativeTargetPath = Get-RelativePath -FilePath $TargetFile -BasePath $ReferenceFolder
    }
    catch {
        Write-Error "Failed to get the relative paths of the files. Check the input parameters and try again."
        return
    }

    # Get the destination path by joining the base folder and the relative target path
    try {
        $destinationPath = Join-Path -Path $BaseFolderToChange -ChildPath $relativeTargetPath
    }
    catch {
        Write-Error "Failed to get the destination path of the file. Check the input parameters and try again."
        return
    }

    # Create the destination directory if it does not exist by using the Ensure-Directory function
    try {
        $destinationDirectory = Split-Path -Path $destinationPath -Parent
        Ensure-Directory -DirectoryPath $destinationDirectory
    }
    catch {
        Write-Error "Failed to create the destination directory. Check the permissions and try again."
        return
    }

    # Check if the base folder or the destination folder are part of a git repo
    try {
        Set-Location -Path $BaseFolderToChange
        $baseRepo = (git rev-parse --show-toplevel 2>$null)
        Set-Location -Path $destinationDirectory
        $destinationRepo = (git rev-parse --show-toplevel 2>$null)
    }
    catch {
        Write-Error "Failed to check if the folders are part of a git repo. Check the git installation and try again."
        return
    }

    # If both folders are in the same repo, use Move-FileWithGit function with the original relative path as the message
    if ($baseRepo -and ($baseRepo -eq $destinationRepo)) {
	try {
            Move-FileWithGit -SourceFile $SourceFile -DestinationFile $destinationFile -CommitMessage "$sourceRelativepath"
        }
	catch {
            Write-Error "Failed to move the file with git. Check the git status and try again."
            return
        }
    }
    # Otherwise, use regular move-item
    else {
	try {
            Move-Item -path $SourceFile -Destination $destinationFile -Force -Verbose
        }
	catch {
            Write-Error "Failed to move the file with move-item. Check the permissions and try again."
            return
        }
    }
}

# Synopsis: Given two paths, A and B, move files in B to match the relative paths of files in A with the same name, using git mv and commit if a git repo is involved
function Sync-FilesByRelativePath {
    param (
	[Parameter(Mandatory=$true)]
	[string]$Reference,
	[Parameter(Mandatory=$true)]
	[string]$ToModify
    )
    # Get the relative file lists for both paths
    $ReferenceFileList = Get-RelativeFileList -Path $Reference| %{  
        New-Object -TypeName PSObject -Property @{
            relative = $_;
            Name = Split-Path -Path $_ -Leaf                             
        }}
    $ToModifyFileList = Get-RelativeFileList -Path $ToModify | %{  
                                                                    New-Object -TypeName PSObject -Property @{
                                                                        relative = $_;
                                                                        Name = Split-Path -Path $_ -Leaf                             
                                                                    }}

    $OutputArray = $ToModifyFileList | Select-Object *, @{Name='refTable'; Expression={ $d = $_; $ReferenceFileList | ?{($_.name -eq $d.name ) -and ( $_.relative -ne $d.relative)}}}
    $q = ($OutputArray | ?{ $_.refTable.count -gt 0 })
    
    foreach ($ToModifyFile in $q) 
    {
        
	    # Get the file name by splitting the relative path
        $referencefile = $ToModifyFile.refTable | select -First 1
            
        $StaticToMove = (Join-Path -Path $Reference -ChildPath $ReferenceFile.relative)
        $StaticReference = (Join-Path -Path $ToModify -ChildPath $ReferenceFile.refTable.relative)
        
        # If there is a matching file in A, and its relative path is different from B, move the file in B to match A's relative path, using git mv and commit if a git repo is involved
        if ($ReferenceFile -and ($ReferenceFile.relative -ne $ReferenceFile.refTable.relative)) {
            try {
                # Use -Verbose to display more output from the function
                Move-FileToMatchRelativePath -SourceFile $StaticToMove `
                                -TargetFile $StaticReference `
                                -BaseFolderToChange $ToModify `
                                -ReferenceFolder $Reference `
                                -Verbose
            }
            catch {
                # Catch any errors and display them with Write-Error
                Write-Error "Failed to move file with relative path matching"
                Write-Error "-SourceFile $StaticToMove `
                                -TargetFile $StaticReference `
                                -BaseFolderToChange $ToModify `
                                -ReferenceFolder $Reference"                                                                
                Write-Error $_.Exception.Message
            }
        }
    }
}


Sync-FilesByRelativePath -ToModify 'B:\PF\PowerShell' -Reference 'B:\PF\PowershellProjectFolder'