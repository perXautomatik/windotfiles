. .\Init-GitRepo.ps1

. .\Add-GitRemote.ps1

. .\Fetch-GitAll.ps1

. .\Checkout-GitBranch.ps1

. .\Switch-GitBranch.ps1

. .\Filter-GitRepo.ps1

. .\Rename-GitBranch.ps1

. .\Push-GitBranch.ps1

# Initialize a new git repo in C:\temp\repo 
Set-Location 'C:\temp\repo'
Init-GitRepo 

# Add a remote repo named scoop with path C:\ProgramData\scoop\persist\PowerShellCmdHist 
Add-GitRemote -RemoteName scoop -RemotePath 'C:\ProgramData\scoop\persist\PowerShellCmdHist' 

# Fetch all branches and tags from scoop 
Fetch-GitAll -RemoteName scoop 

# Checkout onlytxt branch from scoop 
Checkout-GitBranch -RemoteName scoop -BranchName onlytxt 

# Switch to onlytxt branch locally 
Switch-GitBranch -BranchName onlytxt 

# Filter files and folders by PSReadline subdirectory and force overwrite history 
Filter-GitRepo -Subdirectory PSReadline -Force 

# Rename onlytxt branch to OnlyPSReadline 
Rename-GitBranch -OldName onlytxt -NewName OnlyPSReadline 

# Push OnlyPSReadline branch to scoop and set it as upstream branch and force overwrite remote branch 
Push-GitBranch -RemoteName scoop -BranchName OnlyPSReadline -Force 
