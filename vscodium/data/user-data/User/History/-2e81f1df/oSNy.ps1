<#
can you write me a powershell script that takes a path to a git repo as input, for each untracked or staged file as addition not modification ; delete n discard this file if exsisting in worktree currently.  for each untracked or staged file as addition not modification ; delete one of the files if more than one file is has same content as another of the staged files or untracked files, prioritise deleting untracked files always, do check and search recursivly to make sure we don't rely on already deleted files
#>

# Define a function to get the hash of a file content
function Get-FileHash() {
param(
[Parameter(Mandatory=$true)]
[ValidateNotNullOrEmpty()]
$path
)

$stream = [System.IO.MemoryStream]::new([System.Text.Encoding]::UTF8.GetBytes("Hello"))

Get-FileHash -InputStream $stream -Algorithm MD5

        $b = Get-Content $path -Raw -ErrorAction SilentlyContinue
        $a = $b | Out-String
        $h = ($a).GetHashCode()
        return $h
}

# Define a function to delete a file and discard the changes
function Delete-File() {
    param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    $path
    )

    Remove-Item $path -Force -ErrorAction Ignore -WhatIf
    #git restore --staged $path
}

# Get the path to the git repo as a parameter
$repo = 'C:\Users\Användaren\Documents\Obsidian Vault'


# Change the current directory to the repo
Set-Location $repo

# Get the list of untracked or staged files as additions, not modifications
$regex = "[\s]{2,}"
$files = git status --porcelain | ForEach-Object { ($_ -split $regex)[1] } | Where-Object { $_ -inotmatch "^[\s\t][DM]\s+(.+)" } 
# Initialize a hashtable to store the file hashes and paths
$hashes = @{}

# Loop through the files
foreach ($file in $files) {
    # Get the hash of the file content
    if($file)
    {   
        $hash = Get-FileHash $file
        
        Write-Host $file
        Write-Host $hash

        if($hash)
        {   
            $q = $hashes.ContainsKey($hash)
            
            # Check if the hash already exists in the hashtable
            if ($q) {
                wirte-verbos ($file + "------------" + $hashes[$hash])
                # If yes, delete one of the files with the same content
                # Prioritize deleting untracked files
                if ($file -match "^\?\?") {
                    Delete-File $file
                }
                else {
                    Delete-File $hashes[$hash]
                    # Update the hashtable with the new file path
                    $hashes[$hash] = $file
                }
            }
            else {
                # If no, add the hash and the file path to the hashtable
                $hashes[$hash] = $file

                # Check if the file exists in the worktree currently
                if (Test-Path $file) {
                    # If yes, delete and discard the file
                    Delete-File $file
                }
            }
        }
    }
}
