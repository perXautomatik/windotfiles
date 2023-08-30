$d = Get-Module -ListAvailable | Where-Object {$_.ModuleBase.ToString().StartsWith("C:\ProgramData\scoop\modules")}
$d