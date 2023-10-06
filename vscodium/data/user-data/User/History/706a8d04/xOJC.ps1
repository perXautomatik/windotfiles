# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# src: https://gist.github.com/apfelchips/62a71500a0f044477698da71634ab87b
# New-Item $(Split-Path "$($PROFILE.CurrentUserCurrentHost)") -ItemType Directory -ea 0; Invoke-WebRequest -Uri "https://git.io/JYZTu" -OutFile "$($PROFILE.CurrentUserCurrentHost)"

# ref: https://devblogs.microsoft.com/powershell/optimizing-your-profile/#measure-script
# ref: Powershell $? https://stackoverflow.com/a/55362991

# ref: Write-* https://stackoverflow.com/a/38527767
# Write-Host wrapper for Write-Information -InformationAction Continue

#src: https://stackoverflow.com/a/34098997/7595318
	function Test-IsInteractive {
    # Test each Arg for match of abbreviated '-NonInteractive' command.
    $NonInteractiveFlag = [Environment]::GetCommandLineArgs() | Where-Object{ $_ -like '-NonInteractive' }
    if ( (-not [Environment]::UserInteractive) -or (  $null -ne $NonInteractiveFlag ) ) {
        return $false
    }
    return $true
}

if ( Test-IsInteractive ) { # Clear-Host # remove advertisements (preferably use -noLogo)

if ( ( $null -eq $PSVersionTable.PSEdition) -or ($PSVersionTable.PSEdition -eq "Desktop") ) { $PSVersionTable.PSEdition = "Desktop" ;$IsWindows = $true }
    if ( -not $IsWindows ) { function Test-IsAdmin { if ( (id -u) -eq 0 ) { return $true } return $false } }  

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

# https://community.spiceworks.com/topic/1570654-what-s-in-your-powershell-profile?page=1#entry-5746422
	function Test-Administrator {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
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

    # http://www.lavinski.me/my-powershell-profile/
	function Elevate-Process {
        $file, [string]$arguments = $args
        $psi = new-object System.Diagnostics.ProcessStartInfo $file
        $psi.Arguments = $arguments
        $psi.Verb = 'runas'

        $psi.WorkingDirectory = Get-Location
        [System.Diagnostics.Process]::Start($psi)
    }

    # Helper Functions
    #######################################################

    if ( $PSVersionTable.PSVersion.Major -lt 7 ) { # hacks for old powerhsell versions
        # https://docs.microsoft.com/en-us/powershell/scripting/gallery/installing-psget
        if ( $PSVersionTable.PSVersion.Major -lt 6 ) { # hacks for old powerhsell versions
            if ( ( $null -eq $PSVersionTable.PSEdition) -or ($PSVersionTable.PSEdition -eq "Desktop") ) { $PSVersionTable.PSEdition = "Desktop" ; $IsWindows = $true }
        }
	function Get-ExitBoolean($command) { & $command | Out-Null; $?} ; Set-Alias geb   Get-ExitBoolean # fixed: https://github.com/PowerShell/PowerShell/pull/9849
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


    if ( $IsWindows ) {
        # src: http://serverfault.com/questions/95431
	function Test-IsAdmin { $user = [Security.Principal.WindowsIdentity]::GetCurrent(); return $(New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator); }

	function Reopen-here { Get-Process explorer | Stop-Process Start-Process "$(Get-HostExecutable)" -ArgumentList "-noProfile -noLogo -Command 'Get-Process explorer | Stop-Process'" -verb "runAs"}

	function Reset-Spooler { Start-Process "$(Get-HostExecutable)" -ArgumentList "-noProfile -noLogo -Command 'Stop-Service -Name Spooler -Force; Get-Item ${env:SystemRoot}\System32\spool\PRINTERS\* | Remove-Item -Force -Recurse; Start-Service -Name Spooler'" -verb "runAs"    }

	function subl { Start-Process "${Env:ProgramFiles}\Sublime Text\subl.exe" -ArgumentList $args -WindowStyle Hidden  } # hide subl shim script

	function get-tempfilesNfolders { foreach ($folder in @('C:\Windows\Temp\*', 'C:\Documents and Settings\*\Local Settings\temp\*', 'C:\Users\*\Appdata\Local\Temp\*', 'C:\Users\*\Appdata\Local\Microsoft\Windows\Temporary Internet Files\*', 'C:\Windows\SoftwareDistribution\Download', 'C:\Windows\System32\FNTCACHE.DAT')) {$_}  }
	function Export-Regestrykey { param ( $reg = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\' ,$outFile = 'H:\hkcu-regbackup.txt' ) get-childitem -path $reg | out-file $outFile }

	function start-bc ($REMOTE,$LOCAL,$BASE,$MERGED) { cmd /c "${Env:ProgramFiles}\BeondCompare4\BComp.exe" "$REMOTE" "$LOCAL" "$BASE" "$MERGED" } #todo: replace hardcode with global variable pointing to path
	function start-cygwin { param ( $cygwinpath = "${Env:ProgramFiles}\cygwin64\" ) ."$cygwinpath\Cygwin.bat" }

	function Compare-ImagesMetadata { param ( $exifToolPath = "${Env:ProgramFiles}\geosetter\tools\" ,$inputA = "E:\Pictures\Badges & Signs & Shablon Art\00 - soulcripple front (2).jpg" ,$inputB = "E:\Pictures\Badges & Signs & Shablon Art\00 - soulcripple front.jpg" ) ; $set1 = .\exiftool.exe -a -u -g1  $inputA ; $set2 = .\exiftool.exe -a -u -g1  $inputB ; Compare-Object $set1 $set2 | select -ExpandProperty inputobject }
	function new-SymbolicLink { param ( $where = 'H:\mina grejer\Till Github' ,$from = 'H:\mina grejer\Project shelf\Till Github' ) New-Item -Path $where -ItemType SymbolicLink -Value $from }

    }

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

    if (Test-CommandExists 'git')
    { #todo: move to git aliases
	function invoke-gitCheckout ()                { & git checkout $args }
	function invoke-gitFetchOrig                  { git fetch origin }
	function invoke-GitLazy($path,$message)       { cd $path ; git lazy $message } ; 
	function invoke-GitLazySilently               {Out-File -FilePath .\lazy.log -inputObject (invoke-GitLazy 'AutoCommit' 2>&1 )} ; #todo: parameterize #todo: rename to more descriptive #todo: breakout
	function invoke-gitRemote                     { param ($subCommand = 'get-url',$name = "origin" ) git remote $subCommand $name }
	function invoke-GitSubmoduleAdd([string]$leaf,[string]$remote,[string]$branch) { git submodule add -f --name $leaf -- $remote $branch ; git commit -am $leaf+$remote+$branch } ; #todo: move to git aliases #Git Ad $leaf as submodule from $remote and branch $branch
	function invoke-GitSubmoduleSplit([string]$leaf,[string]$branch) { git subtree split --prefix=$leaf -b $branch } ; #todo: move to git aliases #Git Ad $leaf as submodule from $remote and branch $branch
    }

    if ( $null -ne  $(Get-Module PSReadline -ea SilentlyContinue)) {
	function find-historyAppendClipboard($searchstring) { $path = get-historyPath; menu @( get-content $path | where{ $_ -match $searchstring }) | %{ Set-Clipboard -Value $_ }} #search history of past expressions and adds to clipboard
	function find-historyInvoke($searchstring)  { $path = get-historyPath; menu @( get-content $path | where{ $_ -match $searchstring }) | %{Invoke-Expression $_ } } #search history of past expressions and invokes it, doesn't register the expression itself in history, but the pastDo expression.
    }

	function all                                    { process                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        { $_ | Select-Object * } }  # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions?view=powershell-7#piping-objects-to-functions
	function ConvertFrom-Bytes 			            { param ( [string]$bytes, [string]$savepath ) $dir = Split-Path $savepath if (!(Test-Path $dir)) { md $dir | Out-Null } [convert]::FromBase64String($bytes) | Set-Content $savepath -Encoding Byte }
	function ConvertTo-Bytes( [string]$file )       { if (!$file -or !(Test-Path $file)) { throw "file not found: '$file'" } [convert]::ToBase64String((Get-Content $file -Encoding Byte)) }
	function df                                     { get-volume }
	function Test-Administrator                     { $user = [Security.Principal.WindowsIdentity]::GetCurrent() ; (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator) } # https://community.spiceworks.com/topic/1570654-what-s-in-your-powershell-profile?page=1#entry-5746422
	function gj                                     { Get-Job | select id, name, state | ft -a }
	function sj ($id = '*')                         { Get-Job $id | Stop-Job; gj }
	function rj                                     { Get-Job | ? state -match 'comp' | Remove-Job }
	function exit-Nrenter                           { cmd /c shutdown /r } #reboot
	function Get-DefaultAliases                     { Get-Alias | Where-Object                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        { $_.Options -match "ReadOnly" }}
	function get-envVar                             { Get-Childitem -Path Env:*}
	function get-EspHeader                          { param( $path = '.\FormiD.esp', $max = 13,$headerSize = 3 ) if (!$path -or !(Test-Path $path))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             { throw "file not found: '$path'" } $q = ((( -join (gc $path                                                                                                                                                                                    | select -first $headerSize)) -replace "[^\w. ]                                                                                                                                                                                                                                                                                                                                         {1,}","å").split("å") -match "^.*[.](esp |esm)$")                                                           ; $q                                                           | ?                                                                                                                                       {($q                                                                           | select -first $max) -NotContains $_}}
	function get-historyPath                        { (Get-PSReadlineOption).HistorySavePath }
	function get-parameters                         { Get-Member -Parameter *}
	function get-RegInstallpaths                    { Get-ChildItem HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall                                                                                                                                                                                          | %                                                                                                                                                                                                                                                                                                                                                                                           { Get -ItemProperty $_.PsPath }                                                     | Select DisplayName,InstallLocation }
	function get-whatpulse                          { param( $program,$path) if (!$path -or !(Test-Path $path))                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             { throw "file not found: '$path'" } $query = "select rightstr(path,instr(reverse(path),'/') -1) exe,path from (select max(path) path,max(cast(replace(version,'.','') as integer)) version from applications group by case when online_app_id = 0 then name else online_app_id end)" ; $adapter = newSqliteConnection -source (Everything 'whatpulse.db')[0] -query $query   ; $b=@($data.item('exe'))                                          ; $a = @($data.item('path'))                                   ; $i=0                                                                            ; while($i -lt $a.Length)                                                   {$res[$b[$i]]=$a[$i] ; $i++ }                                                                                 ; $res                        | where                                                                                                                                                                  { $_.name -match $program -and $_.path -match $path}}
	function grep                                   { process { $_ | Select-String -Pattern $args } } # function grep($regex, $dir) { if ( $dir ) { ls $dir | select-string $regex return } $input | select-string $regex }
	function Initialize-Profile 			        {. $PROFILE.CurrentUserCurrentHost} #function initialize-profile { & $profile } #reload-profile is an unapproved verb.
	function invoke-powershellAsAdmin 		    { Start-Process powershell -Verb runAs } #new ps OpenAsADmin
	function join-ByRuncunfig                       { param( $prefix='[$]APPLICATION_CONFIG_DIR[$][/]',$refixReplace='C:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\',   $runconfig="TillMinaMedelanden.run.xml",$output='runConfig/Combined.sql') [xml]$xml=get -content $runConfig -Encoding UTF8             ; $xml.component.configuration.'script -file'                                           | %                                                                                                                                                                                                                                                                                               {$_.value -replace $prefix, ($prefixReplace -replace '\\','/')} | %                                                                                                                                                                                                                                                  {" - -:$_"                                                  ; get -content -path $_ -Encoding UTF8                                            ; "go" } >> $output }
	function list                                   { process { $_ | Format-List * } } # fl is there by default
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
                    Set-Alias kill              	Stop-Process                          	-Option AllScope
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

Write-Host "PSVersion: $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor).$($PSVersionTable.PSVersion.Patch)"
Write-Host "PSEdition: $($PSVersionTable.PSEdition)"
Write-Host "Profile:   $PSCommandPath"
} # interactive test close
