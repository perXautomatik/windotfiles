<#
    First, PowerShell will load the profile.ps1 file, which is the “Current User, All Hosts” profile.
    This profile applies to all PowerShell hosts for the current user, such as the console host or the ISE host. 
    You can use this file to define settings and commands that you want to use in any PowerShell session, regardless of the host.

    Next, PowerShell will load the Microsoft.PowerShellISE_profile.ps1 file, which is the “Current User, Current Host” 
    profile for the ISE host. This profile applies only to the PowerShell ISE host for the current user. 
    You can use this file to define settings and commands that are specific to the ISE host, 
    such as customizing the ISE editor or adding ISE-specific functions.
#>

<#
 * FileName: Microsoft.PowerShell_profile.ps1
 * Author: perXautomatik
 * Email: christoffer.broback@gmail.com
 * Date: 08/03/2022
 * Copyright: No copyright. You can use this code for anything with no warranty.
#>

#------------------------------- # Type overrides (starters compliments of Scott Hanselman)-------------------------------



# Runs all .ps1 files in this module's directory
$d = Get-ChildItem -Path $PSScriptRoot\*.ps1 | Where-Object { $_.Name -notlike '*profile*' }
$d | Foreach-Object {
     . $_.FullName 
     Write-Host "loaded:" + $_.FullName 
    }
#------------------------------- prompt beguin -------------------------------

function Get-DefaultAliases                     { Get-Alias | Where-Object                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        { $_.Options -match "ReadOnly" }}
function get-envVar                             { Get-Childitem -Path Env:*}
function get-parameters                         { Get-Member -Parameter *}
function invoke-powershellAsAdmin 		    { Start-Process powershell -Verb runAs } #new ps OpenAsADmin
function man                                    { Get-Help $args[0] | out-host -paging }
function measure-ExtOccurenseRecursivly         { param( $path = "D:\Project Shelf\MapBasic" ) if (!$path -or !(Test-Path $path))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             { throw "file not found: '$path'" } Get-ChildItem -Path $path -Recurse -File | group Extension -NoElement  | sort Count -Descending | select -Property name }
function measure-words                          { param( $inputStream = (Get -ChildItem | %                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      { Get -Content $_.name }), $regex="[^a-z0-9_-]") $hash = @{} ; $a="" ; $inputStream | %                                                                                                                                                                                                                                                                                                                                                                                                                                                           {$a+=$_} ; $a -split $regex | %                                                                                                                                                                                                                                  { $_.tolower()} | %                                                                                                                           {$hash[$_]++} ; $sorted= % {$hash.GetEnumerator() | sort -object {[int]$_.value}} ; return $sorted} ; $sorted | where{$_.name -notmatch "^\d+$"} | where{$_.name.length -gt 4 }
function My-Scripts                             { Get-Command -CommandType externalscript }
function open-ProfileFolder                     { explorer (split-path -path $profile -parent)}
function read-aliases 				            { Get-Alias | Where-Object { $_.Options -notmatch "ReadOnly" }}
function read-childrenAsStream 			        { get-childitem | out-string -stream }
function read-EnvPaths	 			            { ($Env:Path).Split(";") }
function read-headOfFile                        { param( $linr = 10, $path ) if (!$path -or !(Test-Path $path))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             { throw "file not found: '$path'" }  gc -Path $path  -TotalCount $linr }
function read-json 				                { param( [Parameter(Mandatory=$true,ValueFromPipeline=$true)][PSCustomObject] $input ) $json = [ordered]@{}; ($input).PSObject.Properties | % { $json[$_.Name] = $_.Value } $json.SyncRoot }
function read-paramNaliases ($command) 	    	{ (Get-Command $command).parameters.values | select name, @{n='aliases';e={$_.aliases}} }
function read-pathsAsStream 			        { get-childitem | out-string -stream } # filesInFolAsStream ;
function read-uptime 				            { Get-WmiObject win32_operatingsystem | select csname, @{LABEL='LastBootUpTime'; EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}} } #doesn't psreadline module implement this already?
function Remove-CustomAliases                   { Get-Alias | Where-Object                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       { ! $_.Options -match "ReadOnly" } | %                                                                                                                                                                                                                                                                               { Remove-Item alias:$_ }} # https://stackoverflow.com/a/2816523
function Sanatize-path                          { param( $path='G:\mhk',$replaceChar='_') if (!$path -or !(Test-Path $path)) { throw "file not found: '$path'" } $regex= "[\W]" ; Get -ChildItem $path -Recurse | Where -Object {$_.name -match $regex} | rename -item -newName {$_.name -replace $regex,$replaceChar}}
function sed($file, $find, $replace) 		    { if (!$file -or !(Test-Path $file)) { throw "file not found: '$file'" }  (Get-Content $file).replace("$find", $replace) | Set-Content $file }
function set+x                                  { Set-PSDebug -trace 0}
function set-FileEncodingUtf8 ( [string]$file ) { if (!$file -or !(Test-Path $file)) { throw "file not found: '$file'" } sc $file -encoding utf8 -value(gc $file) }
function set-x 					                { Set-PSDebug -trace 2}
function sort-PathByLvl                         { param( $inputList) $inputList                                                                                                                                                                                                                                          | Sort                                                                                                                                                                                                                                                                                                                                                                                   {($_ -split '\\').Count},                                                                                                                                                                                                                                                                                            {$_} -Descending                                       | select -object -first 2                                          | %                                                                                                                                                                                                                                                                                                                                                           { $error.clear()                                            ; try                                                                                                                                                                                                { out -null -input (test -ModuleManifest $_ > '&2>&1' ) } catch                                                                               { "Error" } ; if (!$error) { $_ } }}
function split-fileByLineNr                     { param( $pathName = '.\gron.csv',$OutputFilenamePattern = 'output_done_' , $LineLimit = 60)                                                                                                                                                                         ; $input = Get-Content                                                                  ; $line = 0                                                        ; $i = 0                                                       ; $path = 0                                                                       ; $start = 0                                   ; while ($line -le $input.Length) { if ($i -eq $LineLimit -Or $line -eq $input.Length)                                                                                                                                                                                                                                                                 { ; $path++                     ; $pathname = "$OutputFilenamePattern$path.csv"             ; $input[$start..($line - 1)]   | Out -File $pathname -Force   ; $start = $line ;                                  ; $i = 0                       ; Write -Host "$pathname"     ; }                         ; $i++                        ;            ; $line++                     ; }                                                                 ;                                ;}
function start-BrowserFlags 			        { vivaldi "vivaldi://flags" } #todo: use standard browser instead of hardcoded
function start-powershellAsAdmin                { Start-Process powershell -Verb runAs}
function string 				                { process { $_ | Out-String -Stream } }
function touch($file) 				            { "" | Out-File $file -Encoding ASCII }
function which($name) 				            { Get-Command $name | Select-Object -ExpandProperty Definition } #should use more
function killx($name) { $filter = "name = '"+$name+".exe'" ; (Get-WmiObject Win32_Process -Filter $filter).Terminate()}

#-------------------------------    Functions END     -------------------------------

#-------------------------------   Set alias BEGIN    -------------------------------
$TAType = [psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators") ; $TAType::Add('accelerators',$TAType)
# Remove default things we don't want

if (test-path alias:\clear)           { remove-item -force alias:\clear }              # We override with clear.ps1
if (test-path alias:\ri)              { remove-item -force alias:\ri }                 # ri conflicts with Ruby
if (test-path alias:\cd)              { remove-item -force alias:\cd }                 # We override with cd.ps1
if (test-path alias:\chdir)           { remove-item -force alias:\chdir }              # We override with an alias to cd.ps1
if (test-path alias:\md)              { remove-item -force alias:\md }                 # We override with md.ps1
if (test-path alias:\sc)              { remove-item -force alias:\sc }                 # Conflicts with \Windows\System32\sc.exe
if (test-path function:\md)           { remove-item -force function:\md }              # We override with md.ps1
if (test-path function:\mkdir)        { remove-item -force function:\mkdir }           # We override with an alias to md.ps1
if (test-path function:\prompt)       { remove-item -force function:\prompt }          # We override with prompt.ps1

# Aliases/functions

# bash-like
                Set-Alias cat               	Get-Content                           	-Option AllScope
                Set-Alias cd                	Set-Location                          	-Option AllScope
                Set-Alias clear             	Clear-Host                            	-Option AllScope
                Set-Alias cp                	Copy-Item                             	-Option AllScope
                Set-Alias history           	Get-History                           	-Option AllScope
                Set-Alias kill              	killx                          			-Option AllScope
                Set-Alias lp                	Out-Printer                           	-Option AllScope
#Set-Alias ls	Get-Childitem               	-Option AllScope
                Set-Alias ll                	Get-Childitem                         	-Option AllScope
                Set-Alias mv                	Move-Item                             	-Option AllScope
                Set-Alias ps                	Get-Process                           	-Option AllScope
                Set-Alias pwd               	Get-Location                          	-Option AllScope
                Set-Alias which             	Get-Command                           	-Option AllScope
                Set-Alias open              	Invoke-Item                           	-Option AllScope
                Set-Alias basename          	Split-Path                            	-Option AllScope
                Set-Alias realpath          	Resolve-Path                          	-Option AllScope
                Set-Alias touch             	Set-FileTime                          	-Option AllScope
                set-alias grep              	select-string                         	-Option AllScope
                set-alias df                	get-volume                            	-Option AllScope
                set-alias version           	$PSVersionTable                       	-Option AllScope
# cmd-like
                Set-Alias rm                	Remove-Item                           	-Option AllScope
                Set-Alias rmdir             	Remove-Item                           	-Option AllScope
                Set-Alias echo              	Write-Output                          	-Option AllScope
                Set-Alias cls               	Clear-Host                            	-Option AllScope
                Set-Alias chdir             	Set-Location                          	-Option AllScope
                Set-Alias copy              	Copy-Item                             	-Option AllScope
                Set-Alias del               	Remove-Item                           	-Option AllScope
                Set-Alias dir               	Get-Childitem                         	-Option AllScope
                Set-Alias erase             	Remove-Item                           	-Option AllScope
                Set-Alias move              	Move-Item                             	-Option AllScope
                Set-Alias rd                	Remove-Item                           	-Option AllScope
                Set-Alias ren               	Rename-Item                           	-Option AllScope
                Set-Alias set               	Set-Variable                          	-Option AllScope
                Set-Alias type              	Get-Content                           	-Option AllScope
                set-alias chdir             	cd                                    	-Option AllScope
                set-alias mkdir             	md                                    	-Option AllScope
# custom aliases
                Set-Alias sudo                  Elevate-Process           	            -Option AllScope
                Set-Alias su                    Start-PsElevatedSession           	    -Option AllScope

                set-alias pastDoEdit        	find-historyAppendClipboard           	-Option AllScope
                set-alias pastDo            	find-historyInvoke                    	-Option AllScope

                set-alias kidStream         	read-childrenAsStream                   -Option AllScope
                set-alias filesinfolasstream	read-childrenAsStream                 	-Option AllScope

                set-alias everything        	invoke-Everything                     	-Option AllScope
                set-alias executeThis       	invoke-FuzzyWithEverything            	-Option AllScope
                set-alias OpenAsADmin       	invoke-powershellAsAdmin              	-Option AllScope
                
                set-alias gitSingleRemote   	invoke-gitFetchOrig                   	-Option AllScope
                set-alias GitUp             	invoke-GitLazy                        	-Option AllScope
                set-alias gitSilently       	invoke-GitLazySilently                	-Option AllScope
                set-alias gremote           	invoke-gitRemote                      	-Option AllScope
                set-alias GitAdEPathAsSNB   	invoke-GitSubmoduleAdd                	-Option AllScope
                
                set-alias home              	open-here                             	-Option AllScope
                set-alias exp-pro           	open-ProfileFolder                    	-Option AllScope
                
                set-alias MyAliases         	read-aliases                          	-Option AllScope                
                set-alias printpaths        	read-EnvPaths                         	-Option AllScope
                set-alias uptime            	read-uptime                           	-Option AllScope
                
                set-alias bcompare          	start-bc                              	-Option AllScope
                set-alias edprofile         	start-Notepad-Profile                 	-Option AllScope
                set-alias start-su          	start-powershellAsAdmin               	-Option AllScope                                 
    
                Set-Alias env               	Get-Environment                       	-Option AllScope
                set-alias parameters        	get-parameters                        	-Option AllScope
                set-alias whoami            	get-username                          	-Option AllScope
                
                set-alias accelerators      	([accelerators]::Get)                 	-Option AllScope
                #set-alias history           	(Get-PSReadlineOption).HistorySavePath	-Option AllScope             	
                set-alias reboot            	exit-Nrenter                          	-Option AllScope
                set-alias wide              	format-wide                           	-Option AllScope
                set-alias reload            	initialize-profile                    	-Option AllScope
                
                
#-------------------------------    Set alias END     -------------------------------



$profileFolder = (split-path $profile -Parent)
Update-TypeData (join-path $profileFolder "My.Types.ps1xml")

# Increase history
$MaximumHistoryCount = 10000

# Sometimes home doesn't get properly set for pre-Vista LUA-style elevated admins
 if ($home -eq "") { remove-item -force variable:\home $home = (get-content env:\USERPROFILE) (get-psprovider 'FileSystem').Home = $home } set-content env:\HOME $home


$host.PrivateData.ErrorBackgroundColor = "DarkCyan"
$host.PrivateData.ErrorForegroundColor = "Magenta"
#loadMessage
echo (Split-Path -leaf $MyInvocation.MyCommand.Definition)

Write-Host "PSVersion: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Host "PSEdition: $($PSVersionTable.PSEdition)"
Write-Host ("Profile:   " + (Split-Path -leaf $MyInvocation.MyCommand.Definition))

Write-Host "This script was invoked by: "+$($MyInvocation.Line)



 function prompt {
    # KevMar logging
    $LastCmd = Get-History -Count 1
    if ($LastCmd) {
        $lastId = $LastCmd.Id
        Add-Content -Value "# $($LastCmd.StartExecutionTime)" -Path $PSLogPath
        Add-Content -Value "$($LastCmd.CommandLine)" -Path $PSLogPath
        Add-Content -Value '' -Path $PSLogPath
        $howlongwasthat = $LastCmd.EndExecutionTime.Subtract($LastCmd.StartExecutionTime).TotalSeconds
    }
    
    # Kerazy_POSH propmt
    # Get Powershell version information
    $MajorVersion = $PSVersionTable.PSVersion.Major
    $MinorVersion = $PSVersionTable.PSVersion.Minor

    # Detect if the Shell is 32- or 64-bit host
    if ([System.IntPtr]::Size -eq 8) {
        $ShellBits = 'x64 (64-bit)'
    } elseif ([System.IntPtr]::Size -eq 4) {
        $ShellBits = 'x86 (32-bit)'
    }

    # Set Window Title to display Powershell version info, Shell bits, username and computername
    $host.UI.RawUI.WindowTitle = "PowerShell v$MajorVersion.$MinorVersion $ShellBits | $env:USERNAME@$env:USERDNSDOMAIN | $env:COMPUTERNAME | $env:LOGONSERVER"

    # Set Prompt Line 1 - include Date, file path location
    Write-Host(Get-Date -UFormat "%Y/%m/%d %H:%M:%S ($howlongwasthat) | ") -NoNewline -ForegroundColor DarkGreen
    Write-Host(Get-Location) -ForegroundColor DarkGreen

    # Set Prompt Line 2
    # Check for Administrator elevation
    if (Test-Administrator) {
        Write-Host '# ADMIN # ' -NoNewline -ForegroundColor Cyan
    } else {        
        Write-Host '# User # ' -NoNewline -ForegroundColor DarkCyan
    }
    Write-Host '�' -NoNewLine -ForeGroundColor Green
    ' ' # need this space to avoid the default white PS>
} 

function Download-Latest-Profile {
    New-Item $( Split-Path $($PROFILE.CurrentUserCurrentHost) ) -ItemType Directory -ea 0

    if ( $(Get-Content "$($PROFILE.CurrentUserCurrentHost)" | Select-String "62a71500a0f044477698da71634ab87b" | Out-String) -eq "" ) 
    {Move-Item -Path "$($PROFILE.CurrentUserCurrentHost)" -Destination "$($PROFILE.CurrentUserCurrentHost).bak"}
    
    Invoke-WebRequest -Uri "https://gist.githubusercontent.com/apfelchips/62a71500a0f044477698da71634ab87b/raw/Profile.ps1" -OutFile "$($PROFILE.CurrentUserCurrentHost)"
    Reload-Profile
}

function write-To-log {
    $PSLogPath = (
        "{0}\Documents\WindowsPowerShell\log\{1:yyyyMMdd}-{2}.log" -f $env:USERPROFILE, (Get-Date), $PID
        )

    if (!(Test-Path $(Split-Path $PSLogPath))) 
    {
         md $(Split-Path $PSLogPath) 
    }

    Add-Content -Path $PSLogPath -Value "# $(Get-Date) $env:username $env:computername"
    Add-Content -Path $PSLogPath -Value "# $(Get-Location)"
}

write-To-log
