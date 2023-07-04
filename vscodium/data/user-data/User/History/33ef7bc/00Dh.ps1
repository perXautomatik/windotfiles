# Synopsis: Splits a text file by a regular expression and returns an array of objects with the start, end and value of each match and non-match.
# Parameters:
# -path: The path of the text file to split.
# -regx: The regular expression to use for splitting.
function Split-TextByRegex {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$path,
        [Parameter(Mandatory=$true)]
        [string]$regx
    )
    # Your code here
}
. "Z:\Project Shelf\Archive\ps1\Split-TextByRegex.ps1"

# Synopsis: Converts a string of key-value pairs separated by commas into a custom PowerShell object.
# Parameters:
# -keyPairStrings: The string of key-value pairs to convert.
function keyPairTo-PsCustom {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$keyPairStrings
    )
    # Your code here
}
. "Z:\Project Shelf\Archive\ps1\keyPairTo-PsCustom.ps1"

# Synopsis: Adds submodules to a git repository from a .gitmodules file.
# Parameters:
# -workpath: The path of the git repository.
function Add-Submodules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$workpath
    )
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

    $rgx = "submodule";

    cd $workpath

    $p = $workpath+'\.gitmodules'

    $TextRanges = Split-TextByRegex -path $p -regx $rgx

    #$TextRanges # | %{ keyPairTo-PsCustom -keyPairStrings $_.values }

    $zz = $TextRanges | 
        % { 
            try { 
                    $q = $_.value.trim()  -join "," 
                } 

            catch { 
                    $q = $_.value  -join "," 
                    };

                $t = try {
                    @{ path = $q.Split(',')[0].Split('=')[1].trim();
                        url = $q.Split(',')[1].Split('=')[1].trim()

                    } 
                } catch {$q } ;

                $t | ConvertTo-Json | ConvertFrom-Json
        }


    $zz |
        ? {($_.path)} | 
        % { 
            git submodule add -f $_.url $_.path 
        }
}

# Example usage:
Add-Submodules -workpath 'B:\ToGit\Projectfolder\NewWindows\scoopbucket-1'
