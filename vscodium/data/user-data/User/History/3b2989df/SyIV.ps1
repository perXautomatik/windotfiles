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
function get-AstExtent { $extent = (Get-ChildItem Function:$args).ScriptBlock.Ast.Extent ; $extent.StartLineNumber;$extent.EndLineNumber }
function get-Functions($path) {
    . \$path
    
    $extent = (Get-ChildItem Function:$args).ScriptBlock.Ast.Extent ;
    $extent.StartLineNumber;
    $extent.EndLineNumber 
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
