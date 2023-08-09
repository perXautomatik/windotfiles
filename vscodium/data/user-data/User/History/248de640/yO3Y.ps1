<#This script uses Dolt to compare two text files as tables
It assumes that Dolt is installed and available in the PATH
It takes two file paths as parameters and creates a new Dolt repository
It imports the files as tables, commits them, and compares them using SQL
Define parameters for file paths#>
param ( [string]$file1 = 'K:\D2RMM 1.4.5\mods\Vanilla++\global\excel\weapons.txt', [string]$file2='K:\Diablo II Resurrected\mods\D2RMM\D2RMM.mpq\data\global\excel\Weapons.txt' )

#Create a new Dolt repository
Invoke-Expression “dolt init”
$q = "dolt table import -c"+'--file-type psv --delim' +"' '"
# Create an object literal to store the arguments
$args = @{
    "c" = $true
    "f" = $true
    "pk" = "name"

}
#Write the Invoke-Expression command to run the Dolt command with the object literal as the argument. You can use the splatting operator (@) to pass the object literal as named parameters. For example:
# Invoke the Dolt command with the object literal as the argument
& dolt table import @args armor1 $file1 --file-type=psv --delim="'  '"



Invoke-Expression "dolt table import -c @args armor2 $file2"

#Import the first file as a table named armor1 with name as primary key
Invoke-Expression ($importString1)

#Commit the changes
Invoke-Expression “dolt commit -am ‘Imported armor1’”

#Import the second file as a table named armor2 with name as primary key
Invoke-Expression $importString2

#Commit the changes
Invoke-Expression “dolt commit -am ‘Imported armor2’”

#Compare the two tables using SQL
Write-Output “Comparing armor1 and armor2 tables:” 
Invoke-Expression “dolt sql -q ‘SELECT * FROM dolt_commit_diff_armor1 WHERE to_commit = ‘‘HEAD’’ AND from_commit = ‘‘HEAD~1’’;’”