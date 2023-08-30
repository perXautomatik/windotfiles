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
