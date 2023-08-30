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
$d = Get-ChildItem -Path $PSScriptRoot\*.ps1 | Where-Object { $_.Name -notlike '*profile*' } | Where-Object { $_.Name -notlike 'importModules.ps1' }
$d | Foreach-Object {
     . $_.FullName 
     Write-Host "loaded:" + $_.FullName 
    }
#------------------------------- prompt beguin -------------------------------


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


# Sometimes home doesn't get properly set for pre-Vista LUA-style elevated admins
 if ($home -eq "") { remove-item -force variable:\home $home = (get-content env:\USERPROFILE) (get-psprovider 'FileSystem').Home = $home } set-content env:\HOME $home


#loadMessage
echo (Split-Path -leaf $MyInvocation.MyCommand.Definition)

Write-Host "PSVersion: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Host "PSEdition: $($PSVersionTable.PSEdition)"
Write-Host ("Profile:   " + (Split-Path -leaf $MyInvocation.MyCommand.Definition))

Write-Host "This script was invoked by: "+$($MyInvocation.Line)


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


function Download-Latest-Profile {
    New-Item $( Split-Path $($PROFILE.CurrentUserCurrentHost) ) -ItemType Directory -ea 0

    if ( $(Get-Content "$($PROFILE.CurrentUserCurrentHost)" | Select-String "62a71500a0f044477698da71634ab87b" | Out-String) -eq "" ) 
    {Move-Item -Path "$($PROFILE.CurrentUserCurrentHost)" -Destination "$($PROFILE.CurrentUserCurrentHost).bak"}
    
    Invoke-WebRequest -Uri "https://gist.githubusercontent.com/apfelchips/62a71500a0f044477698da71634ab87b/raw/Profile.ps1" -OutFile "$($PROFILE.CurrentUserCurrentHost)"
    Reload-Profile
}
