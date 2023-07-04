# Synopsis: Clears the screen, sets the execution policy, imports a script and counts the occurrences of 'echo' in the git history
function Count-Echo {
   # Clear the screen
   Clear-Host

   # Set the execution policy to bypass for the current user
   Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser

   # Import the Tokenization.ps1 script from a network path
   . '\\100.84.7.151\NetBackup\Project Shelf\ToGit\PowerShellProjectFolder\scripts\TodoProjects\Tokenization.ps1'

   # Change directory to a local path
   Set-Location 'C:\Users\chris\AppData\Roaming\Microsoft\Windows\PowerShell'

   # Get the first 10 revisions from the git history and grep for 'echo' in each of them
   $mytable = ((git rev-list --all) | 
   Select-Object -First 10 |
   ForEach-Object { (git grep "echo" $_ )})  | ForEach-Object { $all = $_.Split(':') ; [system.String]::Join(":", $all[2..$all.length]) }

   # Initialize an empty hashtable
   $HashTable=@{}

   # For each line in mytable, increment the count for that line in the hashtable
   foreach($r in $mytable)
   {
       $HashTable[$r]++
   }

   # Initialize a null variable for errors
   $errors = $null

   # Get the hashtable entries and sort them by value and name, then select the value, name and token columns
   $HashTable.GetEnumerator() | Sort-Object -property @{Expression = "value"; Descending = $true},name  | Select-Object value, name, @{Expression = TokenizeCode $_ ; Name = "token"}
}

# Example usage:
Count-Echo
