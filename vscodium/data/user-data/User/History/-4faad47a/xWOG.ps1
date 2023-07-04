
Get-ChildItem -path B:\GitPs1Module\* -Filter '*.ps1' | % { . $_.FullName }
                     
                
# Use List-Git-DuplicateHashes function to list the duplicate hashes in a given path and pipe them to Show-Duplicates function 
 list-git-DuplicateHashes -path 'D:\Users\crbk01\AppData\Roaming\JetBrains\DataGrip2021.1\projects\SubProjects\Kvutsokning' | 
 #select -first 1 | 
 % { $_ | Show-Duplicates | Choose-Duplicates | Delete-Duplicates }