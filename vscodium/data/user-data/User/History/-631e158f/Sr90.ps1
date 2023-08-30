
#ps setHistorySavePath
if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = Join-Path -Path "$HOME" -ChildPath ".config" }; $XDG_CONFIG_HOME = $env:XDG_CONFIG_HOME
if (-not $env:XDG_DATA_HOME) { $env:XDG_DATA_HOME = Join-Path -Path "$HOME" -ChildPath ".local/share" }; $XDG_DATA_HOME = $env:XDG_DATA_HOME
if (-not $env:XDG_CACHE_HOME) { $env:XDG_CACHE_HOME = Join-Path -Path "$HOME" -ChildPath ".cache" }; $XDG_CACHE_HOME = $env:XDG_CACHE_HOME

if (-not $env:DESKTOP_DIR) { $env:DESKTOP_DIR = Join-Path -Path "$HOME" -ChildPath "desktop" }; $DESKTOP_DIR = $env:DESKTOP_DIR

if (-not $env:NOTES_DIR) { $env:NOTES_DIR = Join-Path -Path "$HOME" -ChildPath "notes" }; $NOTES_DIR = $env:NOTES_DIR
if (-not $env:CHEATS_DIR) { $env:CHEATS_DIR = Join-Path -Path "$env:NOTES_DIR" -ChildPath "cheatsheets" }; $CHEATS_DIR = $env:CHEATS_DIR
if (-not $env:TODO_DIR) { $env:TODO_DIR = Join-Path -Path "$env:NOTES_DIR" -ChildPath "_ToDo" }; $TODO_DIR = $env:TODO_DIR

if (-not $env:DEVEL_DIR) { $env:DEVEL_DIR = Join-Path -Path "$HOME" -ChildPath "devel" }; $DEVEL_DIR = $env:DEVEL_DIR
if (-not $env:PORTS_DIR) { $env:PORTS_DIR = Join-Path -Path "$HOME" -ChildPath "ports" }; $PORTS_DIR = $env:PORTS_DIR

# Load scripts from the following locations   

$profileFolder = (split-path $profile -Parent)
$EnvPath = join-path -Path $profileFolder -ChildPath 'Snipps'
$env:Path += ";$EnvPath"

$historyX = "$home\appdata\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt"

if( test-path $historyX) {$global:historyPath = $historyX} else {Write-Host "$historyX not found"}

#$path = [Environment]::GetEnvironmentVariable('PSModulePath', 'Machine')

# vscode Portable Path
$vscodepath = 'D:\portapps\6, Text,programming, x Editing\PortableApps\vscode-portable\vscode-portable.exe'
if( test-path $vscodepath) {[Environment]::SetEnvironmentVariable("code", $vscodepath)} else {Write-Host "$vscodepath not found"}


#sqlite dll
$workpath = "C:\Users\crbk01\AppData\Local\GMap.NET\DllCache\SQLite_v103_NET4_x64\System.Data.SQLite.DLL"  ; 

if (Test-ModuleExists 'pseverything') {
$alternative = @(everything 'wfn:System.Data.SQLite.DLL')[0] ;
$p = if(Test-Path $workpath){$workpath} else {$alternative} ;
Add-Type -Path $p
}
else
{"pseverything not loaded" ; "sqlite not loaded"}




### local variables
$global:whatPulseDbQuery = "select rightstr(path,instr(reverse(path),'/')-1) exe,path from (select max(path) path,max(cast(replace(version,'.','') as integer)) version from applications group by case when online_app_id = 0 then name else online_app_id end)"
if (Test-ModuleExists 'pseverything') { $global:whatPulseDbPath = @(Everything 'whatpulse.db')[0];
[Environment]::SetEnvironmentVariable("WHATPULSE_DB", $whatPulseDbPath)
if (-not $env:WHATPULSE_DB) { $env:WHATPULSE_DB = $whatPulseDbPath }; $WHATPULSE_DB = $env:WHATPULSE_DB
} else {Write-Host "whatPulseDbpath not set"}

[Environment]::SetEnvironmentVariable("WHATPULSE_QUERY", $whatPulseDbQuery)
if (-not $env:WHATPULSE_QUERY) { $env:WHATPULSE_QUERY = $whatPulseDbQuery }; $WHATPULSE_QUERY = $env:WHATPULSE_QUERY

$datagripx = '$home\appdata\Roaming\JetBrains\DataGrip2021.1'
if (test-path $datagripx) { $global:datagripPath = $datagripx ; [Environment]::SetEnvironmentVariable("datagripPath", $datagripx) } else {Write-Host "datagrippath not set"}

$bcompareX = 'D:\PortableApps\2. fileOrganization\PortableApps\Beyond Compare 4'
if (test-path $bcompareX) { $global:bComparePath = $bcompareX ; [Environment]::SetEnvironmentVariable("bComparePath", $bcompareX)
} else {Write-Host "bcompare path not set"}
echo "paths set"