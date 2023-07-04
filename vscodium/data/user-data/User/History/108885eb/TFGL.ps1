$minttyPath = "C:\Program Files\Git\usr\bin\mintty.exe"

function callGitBash($ilepath,$command)
{
    #git help git-bash
    & "$gitDir\git-bash.exe" --cd=$filePath -c $command
}

function callGitBashWithMintty($ilepath,$command)
{
    & $minttyPath --icon git-bash.exe,0 --window full --exec "/usr/bin/bash" --login -i --cd=$filePath -c $command
}



#So git-bash.exe just seems to be a simple wrapper that first parses the --cd... options and then runs

#usr\bin\mintty.exe --icon git-bash.exe,0 --exec "/usr/bin/bash" --login -i <other arguments>
#or similar. That's why only --cd.. and bash options are parsed correctly and not mintty.

#If you want to use other options from mintty, you should use a similar command instead of trying to do it with git-bash.exe. E.g.:

#usr\bin\mintty.exe --icon git-bash.exe,0 --window full --exec "/usr/bin/bash" --login -i #source:https://superuser.com/questions/1104567/how-can-i-find-out-the-command-line-options-for-git-bash-exe

<#
.SYNOPSIS
Runs a git command in a bash shell with mintty.

.DESCRIPTION
This function runs a git command in a bash shell with mintty, which is a terminal emulator for Windows. The function can optionally change the current directory to a specified path before running the command. The function also sets up the git configuration with the user name, email, color and code editor.

.PARAMETER FilePath
The path of the directory where the git command will be executed. If not specified, the current directory will be used.

.PARAMETER Command
The git command that will be executed in the bash shell.

.PARAMETER Editor
The code editor that will be used by git. The valid values are "atom", "sublime" or "code". If not specified, "atom" will be used.
#>
function Invoke-Git-Bash {
   [CmdletBinding()]
   param (
       [Parameter(Mandatory = $false)]
       [string]
       $FilePath,

       [Parameter(Mandatory = $true)]
       [string]
       $Command,

       [Parameter(Mandatory = $false)]
       [ValidateSet("atom", "sublime", "code")]
       [string]
       $Editor = "atom"
   )

   # Define the path of the mintty executable
   $minttyPath = "C:\Program Files\Git\usr\bin\mintty.exe"

   # Define the path of the git-bash executable
   $gitBashPath = "C:\Program Files\Git\git-bash.exe"

   # Define the icon for the mintty window
   $icon = "$gitBashPath,0"

   # Define the window mode for the mintty window
   $window = "full"

   # Define the executable for the bash shell
   $bash = "/usr/bin/bash"

   # Define the login and interactive options for the bash shell
   $options = "--login -i"

   # Define the code editor options for git based on the editor parameter
   switch ($Editor) {
       "atom" {
           $editorOption = "atom --wait"
           break
       }
       "sublime" {
           $editorOption = "'C:\Program Files\SublimeText2\sublime_text.exe' -n -w"
           break
       }
       "code" {
           $editorOption = "code --wait"
           break
       }
   }

   # Set up git with your name
   git config --global user.name "<Your-Full_Name>"

   # Set up git with your email
   git config --global user.email "<your-email-address>"

   # Make sure that git output is colored
   git config --global color.ui auto

   # Set up git with your code editor
   git config --global core.editor $editorOption

   # Run the mintty command with the bash shell and the git command
   & $minttyPath --icon $icon --window $window --exec $bash $options --cd=$FilePath -c $Command
}
