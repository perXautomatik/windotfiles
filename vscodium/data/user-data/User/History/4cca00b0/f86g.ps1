Import-Module (join-path -path $PSScriptRoot -child "ExtractFunctionsIntoPsm1.psm1")

<#
    .SYNOPSIS
    This script takes a powershell ps1 file as argument
    It extracts function blocks and their synopsis into a separate psm1 file
    It also removes the functions extracted from the ps1 file
    .PARAMETER Ps1File
    The path of the ps1 file to process
    .EXAMPLE
    .\Extract-Functions.ps1 .\MyScript.ps1
#>
function Extract-Functions {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ Test-Path $_ -PathType Leaf })]
		[string]$Ps1File
	)

	# Call the Tokenize-Script function to get the function tokens and lines to remove
	try {
		$tokenized = Tokenize-Script -Ps1File $Ps1File -ErrorAction Stop
	}
	catch {
		Write-Error "Failed to tokenize script $Ps1File : $_"
		return
	}

	# Check if there are any function tokens, otherwise return an error
	if ($tokenized.FunctionTokens.Count -eq 0) {
		Write-Error "No functions detected in $Ps1File"
		return
	}
	else {
		$d = $tokenized.FunctionTokens.count
		$y = $tokenized.LinesToRemove.count
		Write-Host "$d _ $y"
		Write-Verbose $tokenized.FunctionTokens
		Foreach ( $a in $tokenized.FunctionTokens ) {                
			Write-Verbose ([System.Management.Automation.PSToken] $a).StartLine
			Write-Verbose ([System.Management.Automation.PSToken] $a).EndLine
		}
	}

	# Call the Write-Files function to write the extracted functions to the psm1 file and remove them from the ps1 file
	try {
		Write-Files -Ps1File $Ps1File -FunctionTokens $tokenized.FunctionTokens -LinesToRemove $tokenized.LinesToRemove -ErrorAction Stop
	}
	catch {
		Write-Error "Failed to write files from $Ps1File to $Psm1File : $_"
		return
	}
}


<# 
.SYNOPSIS
 This function writes the extracted functions to a psm1 file and removes them from a ps1 file. 
 .PARAMETER Ps1File 
 The path of the ps1 file to process. 
  .PARAMETER FunctionTokens 
  The array of function tokens to extract. 
  .PARAMETER LinesToRemove
The array of lines to remove from the ps1 file. #>
function Write-Files {
	[CmdletBinding()] param (
		[Parameter(Mandatory = $true)]
		[ValidateScript({ Test-Path $_ -PathType Leaf })] [string]$Ps1File,
		[Parameter(Mandatory = $true)] [ValidateScript({ $_.count -gt 0 })] [array]$FunctionTokens,
		[Parameter(Mandatory = $true)] [ValidateScript({ $_.count -gt 0 })] [array]$LinesToRemove)
		$cf = $functionTokens.count 
	# Call the Validate-Psm1File function to verify that a psm1 file with the same base name and directory as the ps1 file can be deployed
	try {
		$Psm1File = Validate-Psm1File -Ps1File $Ps1File -ErrorAction Stop
	}
	catch {
		Write-Error "Failed to Validate-Psm1File file: $_"
		return
	}

	# Call the Remove-Lines function to remove the lines from the script content
	try {
		$withoutFunctions = Remove-Lines -Ps1File $Ps1File -LinesToRemove $LinesToRemove -ErrorAction Stop
	}
	catch {
		Write-Error "Failed to Remove-Lines: $_"
		return
	}

	# Call the WriteToPsm1 function to write the extracted functions to the psm1 file
	try {
		WriteToPsm1 -Psm1File $Psm1File -FunctionTokens $FunctionTokens -ErrorAction Stop
	}
	catch {
		Write-Error "Failed to WriteToPsm1: $_"
		return
	}

	# Call the Set-Content function to remove the extracted functions from the ps1 file
	try {
		Set-Content -Path $Ps1File -Value $withoutFunctions -ErrorAction Stop
	}
	catch {
		Write-Error "Failed to Set-Content: $_"
		return
	}

	# Output a message indicating success
	Write-Host "Extracted $cf functions from $Ps1File to $Psm1File"
}