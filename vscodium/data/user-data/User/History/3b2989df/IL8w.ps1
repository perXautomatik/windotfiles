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
function addTo-Profile($name) { $func = get-function $name ; Add-Content -Path $PROFILE -Value $func }

function Copy-Function {
  param(
    [string]$Name # The name of the function to copy
  )

  # Get the CommandInfo object for the function to copy
  $original = get-Function $name

  # Check if the command is a function
  if ($original.CommandType -eq 'Function') {

    # Get the name, parameters, and code of the original function
    
    $name = $original.Name #includes parameters
    $regex ='\s{2,}'; 
    $code = (Get-command all).ScriptBlock.toString() -replace($regex,"`t")
     
   $declaration = ("function $name {`n" + $code )
    
    $declaration += "`n}"
    
    # Append the function declaration and the code to the profile script
    Add-Content -Path $PROFILE -Value $declaration

    # Write a message to indicate success
    Write-Output "The function $name has been copied to your profile."
  }
  else {
    # Write an error message if the command is not a function
    Write-Error "The command $Name is not a function."
  }
}
