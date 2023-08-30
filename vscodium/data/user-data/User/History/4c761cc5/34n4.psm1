

<# .SYNOPSIS This function tokenizes a powershell ps1 file and returns an object with the function tokens and the lines to remove.
.PARAMETER Ps1File The path of the ps1 file to tokenize.
.OUTPUTS A custom object with two properties: FunctionTokens and LinesToRemove. #>
function Tokenize-Script {
    [CmdletBinding()] param (
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType Leaf})]
    [string]$Ps1File )

         # The collection of tokens and errors
         $tokens = $null
         $errors = $null

         # The call to the Tokenize method
         $tokens = [System.Management.Automation.PsParser]::Tokenize((Get-Content $Ps1File -Raw), [ref]$errors)

         # The array of function tokens
         $functionTokens = $tokens | Where-Object { $_.Type -eq "Keyword" -and $_.Content -eq "function" }

         $functions = @()

         $tokens | %{ Write-Verbose ($_ | select Type, content) }
         
         # The loop through the function tokens

        foreach ($functionToken in $functionTokens) {

            # The index of the function token
            $index = $tokens.IndexOf($functionToken)

            # The name of the function
            $name = $tokens[$index + 1].Content

            # The start and end positions of the function body
            $start = $tokens[$index + 2].Start
            $end = $tokens[$index + 2].Length

            # The body of the function
            $body = (Get-Content $scriptPath)[$start..$end] -join "`n"

            # The custom object with the name and body properties
            $function = [PSCustomObject]@{
                Name = $name
                Body = $body
            }

            # The addition of the function object to the array
            $functions += $function
        }

         # The array of lines to remove
         $linesToRemove = @()

         # The loop through the function tokens
         foreach ($functionToken in $functionTokens) {
	         # The index of the function token
	         $index = $tokens.IndexOf($functionToken)

	         # The start and end positions of the function body
	         $start = $tokens[$index + 2].Start
	         $end = $tokens[$index + 2].Length

	         # The addition of the line numbers to the array
	         $linesToRemove += $start..$end
         }

         # Return a custom object with the function tokens and lines to remove properties
         return [PSCustomObject]@{
	         FunctionTokens = $functions
	         LinesToRemove = $linesToRemove
     }
}
<# .SYNOPSIS
 This function validates a psm1 file with the same base name and directory as a ps1 file.
.PARAMETER Ps1File 
The path of the ps1 file to process.
.OUTPUTS The path of the psm1 file to create or appended. #>
function Validate-Psm1File {
    [CmdletBinding()] param (
    [Parameter(Mandatory=$true)] [ValidateScript({Test-Path $_ -PathType Leaf})] [string]$Ps1File )

     # Get the full path of the ps1 file
     $Ps1File = Resolve-Path $Ps1File

     # Get the base name and directory of the ps1 file
     $g = ($Ps1File  | Split-Path -Leaf) -split "[.]"
     $BaseName = $g[0]
     $DirName = $Ps1File | Split-Path -Parent

     # Create a psm1 file with the same base name in the same directory
     try {
         $q = $BaseName + ".psm1"
         $Psm1File =
         Join-Path -Path $DirName -ChildPath $q -ErrorAction Stop
     }
     catch {
         Write-Error "Failed to join paths for $DirName and $q : $g"
         return
     }

     # Return the path of the psm1 file
     return $Psm1File
}

<# .SYNOPSIS
 This function removes the lines from a ps1 file content based on an array of line numbers.
.PARAMETER Ps1File
 The path of the ps1 file to process.
.PARAMETER LinesToRemove
 The array of line numbers to remove from the ps1 file content.
.OUTPUTS
 The modified script content without the lines to remove. #>
function Remove-Lines {
    [CmdletBinding()] param (
    [Parameter(Mandatory=$true)] [ValidateScript({Test-Path $_ -PathType Leaf})] [string]$Ps1File,
    [Parameter(Mandatory=$true)] [ValidateScript({$_.count -gt 0})] [array]$LinesToRemove )

     # The removal of the lines from the script content
     $scriptContent = Get-Content $Ps1File
     $scriptContent = $scriptContent | Where-Object { $_.ReadCount -notin $LinesToRemove }

     # Return the modified script content
     return $scriptContent
}

<# .SYNOPSIS 
This function writes the extracted functions to a psm1 file, appending if it already exists.
.PARAMETER Psm1File 
The path of the psm1 file to create or append.
.PARAMETER FunctionTokens 
The array of function tokens to extract. #>
function WriteToPsm1 {
    [CmdletBinding()] param (
    [Parameter(Mandatory=$true)] [string]$Psm1File,
    [Parameter(Mandatory=$true)] [ValidateScript({$_.count -gt 0})] [array]$FunctionTokens )

    # The output of the extracted functions
    $qq = ($FunctionTokens | Out-String)

    # The output of the modified script content
    # Write the extracted functions to the psm1 file, appending if it already exists

    try {
        if (Test-Path $Psm1File) {
	        Add-Content -Path $Psm1File -Value $qq -ErrorAction Stop
        }
        else {
    	    Out-File -FilePath $Psm1File -InputObject $qq -ErrorAction Stop
        }
	}
    catch {
	    Write-Error "Failed to write functions to $Psm1File : $error"
	    return
    }
}