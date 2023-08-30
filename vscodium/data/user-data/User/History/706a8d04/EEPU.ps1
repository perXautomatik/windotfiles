# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# src: https://gist.github.com/apfelchips/62a71500a0f044477698da71634ab87b
# New-Item $(Split-Path "$($PROFILE.CurrentUserCurrentHost)") -ItemType Directory -ea 0; Invoke-WebRequest -Uri "https://git.io/JYZTu" -OutFile "$($PROFILE.CurrentUserCurrentHost)"

# ref: https://devblogs.microsoft.com/powershell/optimizing-your-profile/#measure-script
# ref: Powershell $? https://stackoverflow.com/a/55362991

# ref: Write-* https://stackoverflow.com/a/38527767
# Write-Host wrapper for Write-Information -InformationAction Continue

# Helper Functions
#######################################################


function Test-CommandExists { #src: https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
    Param ($command)
    $oldErrorActionPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try { Get-Command $command; return $true }
    catch {return $false}
    finally { $ErrorActionPreference=$oldErrorActionPreference }
}    

function Out-Default { # http://get-powershell.com/post/2008/06/25/Stuffing-the-output-of-the-last-command-into-an-automatic-variable.aspx
    if ($input.GetType().ToString() -ne 'System.Management.Automation.ErrorRecord') {
        try {
            $input | Tee-Object -Variable global:lastobject | Microsoft.PowerShell.Core\Out-Default
        } catch {
            $input | Microsoft.PowerShell.Core\Out-Default
        }
    } else {
        $input | Microsoft.PowerShell.Core\Out-Default
    }
}
function get-historyPath  { (Get-PSReadlineOption).HistorySavePath }

function Test-Administrator {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent() ;
     (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) 
   } # https://community.spiceworks.com/topic/1570654-what-s-in-your-powershell-profile?page=1#entry-5746422

#src: https://stackoverflow.com/a/34098997/7595318

function Test-IsInteractive {
   # Test each Arg for match of abbreviated '-NonInteractive' command.
   $NonInteractiveFlag = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonInteractive' }
   if ( (-not [Environment]::UserInteractive) -or (  $null -ne $NonInteractiveFlag ) ) {
       return $false
   }
   return $true
}
# http://www.lavinski.me/my-powershell-profile/
function Elevate-Process {
    $file, [string]$arguments = $args
    $psi = new-object System.Diagnostics.ProcessStartInfo $file
    $psi.Arguments = $arguments
    $psi.Verb = 'runas'

    $psi.WorkingDirectory = Get-Location
    [System.Diagnostics.Process]::Start($psi)
}

if ( Test-IsInteractive ) { # Clear-Host # remove advertisements (preferably use -noLogo)

if ( ( $null -eq $PSVersionTable.PSEdition) -or ($PSVersionTable.PSEdition -eq "Desktop") ) 
    { $PSVersionTable.PSEdition = "Desktop" ;$IsWindows = $true }
if ( -not $IsWindows ) { function Test-IsAdmin { if ( (id -u) -eq 0 ) { return $true } return $false } }  


# hacks for old powerhsell versions
if ( $PSVersionTable.PSVersion.Major -lt 7 ) {
    # https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget
    function Install-PowerShellGet {
        Start-Process "$(Get-HostExecutable)" -ArgumentList "-noProfile -noLogo -Command Install-PackageProvider -Name NuGet -Force; Install-Module -Name PowerShellGet -Repository PSGallery -Force -AllowClobber -SkipPublisherCheck; pause" -verb "RunAs"
    }

    $PSDefaultParameterValues['Out-File:Encoding'] = 'utf8' # Fix Encoding for PS 5.1 https://stackoverflow.com/a/40098904

    function Get-ExitBoolean($command) { # fixed: https://github.com/PowerShell/PowerShell/pull/9849
        & $command | Out-Null; $?
    }
    Set-Alias geb   Get-ExitBoolean

    function Use-Default # $var = d $Value : "DefaultValue" eg. ternary # fixed: https://toastit.dev/2019/09/25/ternary-operator-powershell-7/
    {
        for ($i = 1; $i -lt $args.Count; $i++){
            if ($args[$i] -eq ":"){
                $coord = $i; break
            }
        }
        if ($coord -eq 0) {
            throw new System.Exception "No operator!"
        }
        if ($args[$coord - 1] -eq ""){
            $toReturn = $args[$coord + 1]
        } else {
            $toReturn = $args[$coord -1]
        }
        return $toReturn
    }
    Set-Alias d    Use-Default
}

}
 # interactive test close

 if (Test-CommandExists 'search-Everything')
 { 
     function invoke-Everything([string]$filter)                     { @(Search-Everything -filter $filter -global) }
     function Every-Menu([string]$filter)                            { $a= @(invoke-Everything $filter) ; if($a.count -eq 1) {$q = $a} else {$q = menu @($a)} ; return $q }
     function invoke-FuzzyWithEverything([string]$searchstring)      { menu @(invoke-Everything "ext:exe $searchString") | %{& $_ } } #use whatpulse db first, then everything #todo: sort by rescent use #use everything to find executable for fast execution
     function Every-AsHashMap([string]$filter)                       {  $q = @{} ; invoke-Everything $filter | %{@{ name = (get -item $_).name ; time=(get -item $_).LastWriteTime ; path=(get -item $_) } } | sort -object -property time | %{ $q[$_.name] = $_.path } ; $q | select -property values}
     function Every-execute([string]$filter,$navigate=$true)         { Every-Menu $filter | %{ if($navigate) {cd ($_ | split-path -parent)} ; . $_ } }
     function Every-Explore([string]$filter,$navigate=$true)         { Every-Menu $filter | % { $path = if(!( Test-Path $_ -PathType Container)) { $_ | split-path -leaf } else {$_} ; explorer $path } }
     #function Every-Load                                            { param( $psFileFilter = 'convert-xlsx-to-csv.ps1') .( everythnig $psFileFilter | select -first 1) } ; invoke-expression "ExcelToCsv -File 'D:\unsorted\fannyUtskick.xlsx'"
 }
 
 if ( $null -ne  $(Get-Module PSReadline -ea SilentlyContinue)) {
     function find-historyAppendClipboard($searchstring) { $path = get-historyPath; menu @( get-content $path | where{ $_ -match $searchstring }) | %{ Set-Clipboard -Value $_ }} #search history of past expressions and adds to clipboard
     function find-historyInvoke($searchstring)  { $path = get-historyPath; menu @( get-content $path | where{ $_ -match $searchstring }) | %{Invoke-Expression $_ } } #search history of past expressions and invokes it, doesn't register the expression itself in history, but the pastDo expression.
 }

function Start-PsElevatedSession { # Open a new elevated powershell window
    if (!(Test-Administrator)) {
        if ($host.Name -match 'ISE') {
            start PowerShell_ISE.exe -Verb runas
        } else {
            start powershell -Verb runas -ArgumentList $('-noexit ' + ($args | Out-String))
        }
    } else {
        Write-Warning 'Session is already elevated'
    }
} 
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


$profileFolder = (split-path $profile -Parent)
Update-TypeData (join-path $profileFolder "My.Types.ps1xml")

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"


# Produce UTF-8 by default

if ( $PSVersionTable.PSVersion.Major -lt 7 ) {
	# https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget
	$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8' # Fix Encoding for PS 5.1 https://stackoverflow.com/a/40098904
}

Write-Host "This profile.ps1 was invoked by: "+$($MyInvocation.Line)


