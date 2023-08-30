Sure, I can try to write a PowerShell script that does both methods on a local git repo, but prints to screen as fast as anything shows up, continuing the search in the background and appending it to the console as it finds more. Here is one possible script:

# Define the search string and the local git repo path
$search = "string"
$repo = "C:\path\to\local\git\repo"

# Method 1: Use git submodule foreach to run git grep on each submodule
Write-Host "Method 1: Using git submodule foreach"
cd $repo
# Start a background job that runs git submodule foreach and outputs the results to a file
Start-Job -ScriptBlock { param($search, $repo) cd $repo git submodule foreach "git grep '$search' $(git rev-list --all --remotes)" > method1.txt } -ArgumentList $search, $repo
# Wait for the job to finish and display the results from the file
Wait-Job -Name Job1 | Out-Null
Get-Content method1.txt

# Method 2: Use git-subrepo to work with submodules as normal files
Write-Host "Method 2: Using git-subrepo"
cd $repo
# Install git-subrepo if not already installed
if (!(Get-Command git subrepo -ErrorAction SilentlyContinue)) {
    # You can change the installation method according to your preference
    # This example uses chocolatey (https://chocolatey.org/)
    choco install git-subrepo
}
# Start a background job that runs git grep on the main repo and submodules and outputs the results to a file
Start-Job -ScriptBlock { param($search, $repo) cd $repo git subrepo pull --all # Update all submodules git grep '$search' $(git rev-list --all --remotes) > method2.txt } -ArgumentList $search, $repo
# Wait for the job to finish and display the results from the file
Wait-Job -Name Job2 | Out-Null
Get-Content method2.txt

I hope this script helps you with your task. 😊

Källa: Konversation med Bing, 2023-08-28
(1) How can I run a command for each git submodule in powershell?. https://stackoverflow.com/questions/16311458/how-can-i-run-a-command-for-each-git-submodule-in-powershell.
(2) List submodules in a Git repository - Stack Overflow. https://stackoverflow.com/questions/12641469/list-submodules-in-a-git-repository.
(3) [Solved]-How can I run a command for each git submodule in powershell .... https://www.appsloveworld.com/powershell/100/17/how-can-i-run-a-command-for-each-git-submodule-in-powershell.
(4) git archive export with submodules (git archive all / recursive). https://stackoverflow.com/questions/14783127/git-archive-export-with-submodules-git-archive-all-recursive.