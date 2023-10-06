$TAType = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators") ; $TAType::Add('accelerators',$TAType)
if (test-path alias:\cd)              { remove-item -force alias:\cd }                 # We override with cd.ps1
if (test-path alias:\chdir)           { remove-item -force alias:\chdir }              # We override with an alias to cd.ps1
if (test-path function:\prompt)       { remove-item -force function:\prompt }          # We override with prompt.ps1
                Set-Alias history           	Get-History                           	-Option AllScope
                Set-Alias kill              	killx                          			-Option AllScope
                Set-Alias mv                	Move-Item                             	-Option AllScope
                Set-Alias pwd               	Get-Location                          	-Option AllScope
                Set-Alias rm                	Remove-Item                           	-Option AllScope
                Set-Alias echo              	Write-Output                          	-Option AllScope
                Set-Alias cls               	Clear-Host                            	-Option AllScope
                Set-Alias copy              	Copy-Item                             	-Option AllScope
                Set-Alias del               	Remove-Item                           	-Option AllScope
                Set-Alias dir               	Get-Childitem                         	-Option AllScope
                Set-Alias type              	Get-Content                           	-Option AllScope
                Set-Alias sudo                  Elevate-Process           	            -Option AllScope
                set-alias pastDoEdit        	find-historyAppendClipboard           	-Option AllScope
                set-alias pastDo            	find-historyInvoke                    	-Option AllScope
                set-alias everything        	invoke-Everything                     	-Option AllScope
                set-alias executeThis       	invoke-FuzzyWithEverything            	-Option AllScope
                set-alias exp-pro           	open-ProfileFolder                    	-Option AllScope
                set-alias MyAliases         	read-aliases                          	-Option AllScope                
                set-alias printpaths        	read-EnvPaths                         	-Option AllScope
                set-alias uptime            	read-uptime                           	-Option AllScope
                set-alias parameters        	get-parameters                        	-Option AllScope
                set-alias accelerators      	([accelerators]::Get)                 	-Option AllScope
                set-alias reboot            	exit-Nrenter                          	-Option AllScope
                set-alias reload            	initialize-profile                    	-Option AllScope
$profileFolder = (split-path $profile -Parent)
Update-TypeData (join-path $profileFolder "My.Types.ps1xml")
function sanitize-clipboard { $regex = "[^a-zA-Z0-9"+ "\$\#^\\|&.~<>@:+*_\(\)\[\]\{\}?!\t\s\['" + '=åäöÅÄÖ"-]'  ; $original = Get-clipboard ; $sanitized = $original -replace $regex,'' ; $sanitized | set-clipboard }
function get-Function { (Get-ChildItem Function:$args).ScriptBlock.Ast.Body.Parent.Extent.text }
function get-AstExtent { (Get-ChildItem Function:$args).ScriptBlock.Ast.Extent }
function get-Functions($path) {
    Import-Module $path
    return  get-AstExtent "*" | ?{ $_.File -eq $path } | % {
      [PSCustomObject]@{
          StartRow = $_.StartLineNumber
          EndRow = $_.EndLineNumber 
          ExtentText = $_.text
      }
    }    
   
  }
function addTo-Profile($name) { $func = get-function $name ; Add-Content -Path $PROFILE -Value $func }

function Copy-Function {
  param(
    [string]$Name # The name of the function to copy
  )
  addTo-Profile $Name
}
function Translate-Path {
  [CmdletBinding()]
  param (
    # The relative path
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [string]
    $RelativePath,

    # The base directory`
    [Parameter(Mandatory = $true)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]
    $BaseDirectory
  )

  # Split the relative path by the "/" character`
  $PathSegments = $RelativePath.Split("/")

  # Set the current directory to the base directory`
  $CurrentDirectory = $BaseDirectory

  # Loop through each path segment`
  foreach ($Segment in $PathSegments) {
    # If the segment is "..", go up one level in the directory hierarchy`
    if ($Segment -eq "..") {
      $CurrentDirectory = Split-Path -Path $CurrentDirectory -Parent
    }
    # If the segment is ".git", stop the loop and append the rest of the path`
    elseif ($Segment -eq ".git") {
      break
    }
    # Otherwise, ignore the segment`
    else {
      continue
    }
  }

  # Get the index of the ".git" segment in the path segments`
  $GitIndex = [array]::IndexOf($PathSegments, ".git")

  # Get the rest of the path segments after the ".git" segment`
  $RestOfPath = $PathSegments[($GitIndex)..$PathSegments.Length]

  # Join the rest of the path segments by the "/" character`
  $RestOfPath = $RestOfPath -join "/"

  # Append the rest of the path to the current directory`
  $AbsolutePath = Join-Path -Path $CurrentDirectory -ChildPath $RestOfPath

  # Return the absolute path as a string`
  return "$AbsolutePath"
}
# Define a function that takes a path, a line number, and a switch parameter as parameters
function Get-RowNumber {
  param (
    [string]$Path,
    [int]$StartColumnNumber,
    [switch]$EndLine
)

# Check if the path is valid and the file exists
if (-not (Test-Path -Path $Path -PathType Leaf)) {
    Write-Error "Invalid path or file not found: $Path"
    return
}


# Get the length of each line in the file
$LineLengths = Get-Content -Path $Path | Measure-Object -Property Length

# Initialize the row number and the character count
$RowNumber = 0
$CharCount = 0

# Loop through the line lengths until the character count exceeds the start column number of the extent
foreach ($LineLength in $LineLengths) {
    # Increment the row number
    $RowNumber++

    # Add the line length and one (for the newline character) to the character count
    
    $CharCount += $LineLength.Length + 1

    # Check if the character count is greater than or equal to the start column number of the extent
    if ($CharCount -ge $StartColumnNumber) {
        # Return the row number
        return $RowNumber
    }
}

# If the loop ends without finding a match, return an error message
Write-Error "The extent value does not match any row in the file"

}


function Get-ExtentInfo {
    param (
        [System.Management.Automation.Language.IScriptExtent]$Extent
    )

    # Check if the extent is valid
    if (-not $Extent) {
        Write-Error "Invalid extent value"
        return
    }

    # Get the path from the File property of the extent object
    $Path = $Extent.File

    # Check if the path is valid and the file exists
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        Write-Error "Invalid path or file not found: $Path"
        return
    }

    # Get the start row and the end row of the extent using the Get-RowNumber function or its variants defined earlier
    $StartRow = Get-RowNumber -Path $Path -StartLineNumber $Extent.StartLineNumber 
    $EndRow = Get-RowNumber -Path $Path -EndLineNumber $Extent.EndLineNumber -EndLine 

    # Get the start index and the end index of the extent in the content string using a loop
    $StartIndex = 0
    $EndIndex = 0
    $CurrentLine = 1
    $CurrentColumn = 1

    for ($i = 0; $i -lt $Content.Length; $i++) {
        # Check if the current character is a newline character
        if ($Content[$i] -eq "`n") {
            # Increment the current line and reset the current column
            $CurrentLine++
            $CurrentColumn = 1
        }
        else {
            # Increment the current column
            $CurrentColumn++
        }

        # Check if the current line and column match the start line and column of the extent
        if ($CurrentLine -eq $StartLineNumber -and $CurrentColumn -eq $StartColumnNumber) {
            # Set the start index to the current index
            $StartIndex = $i
        }

        # Check if the current line and column match the end line and column of the extent
        if ($CurrentLine -eq $EndLineNumber -and $CurrentColumn -eq $EndColumnNumber) {
            # Set the end index to the current index
            $EndIndex = $i

            # Break out of the loop
            break
        }
    }

    # Get the text of the extent by slicing the content string
    $ExtentText = $Content.Substring($StartIndex, $EndIndex - $StartIndex + 1)

    # Create a custom object with the properties: StartRow, EndRow, and ExtentText
    $Object = [PSCustomObject]@{
        StartRow = $StartRow
        EndRow = $EndRow
        ExtentText = $ExtentText
    }

    # Return the custom object
    return $Object
}
