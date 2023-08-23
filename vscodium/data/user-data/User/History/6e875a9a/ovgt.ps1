
#src: https://stackoverflow.com/a/34098997/7595318
function Test-IsInteractive {
    # Test each Arg for match of abbreviated '-NonInteractive' command.
    $NonInteractiveFlag = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonInteractive' }
    if ( (-not [Environment]::UserInteractive) -or (  $null -ne $NonInteractiveFlag ) ) {
	return $false
    }
    return $true
}

function Download-Latest-Profile {
    New-Item $( Split-Path $($PROFILE.CurrentUserCurrentHost) ) -ItemType Directory -ea 0
    if ( $(Get-Content "$($PROFILE.CurrentUserCurrentHost)" | Select-String "62a71500a0f044477698da71634ab87b" | Out-String) -eq "" ) {
	Move-Item -Path "$($PROFILE.CurrentUserCurrentHost)" -Destination "$($PROFILE.CurrentUserCurrentHost).bak"
    }
    Invoke-WebRequest -Uri "https://gist.githubusercontent.com/apfelchips/62a71500a0f044477698da71634ab87b/raw/Profile.ps1" -OutFile "$($PROFILE.CurrentUserCurrentHost)"
    Reload-Profile
}

#------------------------------- SystemMigration end  -------------------------------
#------------------------------- prompt beguin -------------------------------

$prompt = join-path -Path $profileFolder -ChildPath 'prompt.ps1'
Import-Module $prompt
#------------------------------- prompt beguin END   -------------------------------

#------------------------------- # Type overrides (starters compliments of Scott Hanselman)-------------------------------

Update-TypeData (join-path $profileFolder "My.Types.ps1xml")

#-------------------------------  # Type overrides end 				           -------------------------------

#------------------------------- Set Paths           -------------------------------

$paths = join-path -Path $profileFolder  -ChildPath 'setPaths.ps1'
Import-Module  $paths
#------------------------------- Set Paths  end       -------------------------------

#------------------------------- overloading begin

#https://www.sapien.com/blog/2014/10/21/a-better-tostring-method-for-hash-tables/

#better hashtable ToString method
if ( $(Test-CommandExists 'System.Collections.HashTable.ToString') ) {

    Update-TypeData -TypeName "System.Collections.HashTable"   `
    -MemberType ScriptMethod `
    -MemberName "ToString" -Value { $hashstr = "@{"; $keys = $this.keys; foreach ($key in $keys) { $v = $this[$key];
           if ($key -match "\s") { $hashstr += "`"$key`"" + "=" + "`"$v`"" + ";" }
           else { $hashstr += $key + "=" + "`"$v`"" + ";" } }; $hashstr += "}";
           return $hashstr }
  }
  #-------------------------------  overloading end


# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

# Load Posh-VsVars
. 'B:\Users\chris\Documents\WindowsPowerShell\Modules\Posh-VsVars\Posh-VsVars-Profile.ps1'

# Import git-status-cache-posh-client
#####BigGit#####
#####BigGit#####
$pos = join-path -Path $profileFolder -ChildPath 'importModules.ps1'
#------------------------------- Import Modules END   -------------------------------
, 'C:\tools\poshgit\dahlbyk-posh-git-9bda399\src\posh-git.psd1' ,, 'C:\ProgramData\chocolatey\lib\git-status-cache-posh-client\tools\git-status-cache-posh-client-1.0.0\GitStatusCachePoshClient.psm1', 'C:\ProgramData\chocolatey\lib\BigGit\tools\BigGit\BigGit.psm1', $pos




# Produce UTF-8 by default

if ( $PSVersionTable.PSVersion.Major -lt 7 ) {
	# https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget
	$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8' # Fix Encoding for PS 5.1 https://stackoverflow.com/a/40098904
}

#------------------------------- Import Modules BEGIN -------------------------------
<#
 * FileName: Microsoft.PowerShell_profile.ps1
 * Author: perXautomatik
 * Email: christoffer.broback@gmail.com
 * Date: 08/03/2022
 * Copyright: No copyright. You can use this code for anything with no warranty.
#>
$host.PrivateData.ErrorBackgroundColor = "DarkCyan"
$host.PrivateData.ErrorForegroundColor = "Magenta"
#loadMessage
echo (Split-Path -leaf $MyInvocation.MyCommand.Definition)

# Increase history
$MaximumHistoryCount = 10000

$profileFolder = (split-path $profile -Parent)
# Sometimes home doesn't get properly set for pre-Vista LUA-style elevated admins

# if ($home -eq "") { remove-item -force variable:\home $home = (get-content env:\USERPROFILE) (get-psprovider 'FileSystem').Home = $home } set-content env:\HOME $home


#------------------------------- SystemMigration      -------------------------------

#choco check if installed
#path to list of aps to install
#choco ask to install if not present

#list of portable apps,download source
#path
#download and extract if not present, ask to confirm

#path to portable apps
#path to standard download location


#git Repos paths and origions,
#git systemwide profile folder
#git global path

#everything data folder
#autohotkey script to run on startup

#startup programs

#reg to add if not present