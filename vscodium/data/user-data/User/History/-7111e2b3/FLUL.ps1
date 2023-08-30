Hello, this is Bing. I can try to help you with your powershell script. Here is one possible way to break it up into smaller functions:

```powershell
# Create a scheduled task to run a script with highest privileges
function New-ScheduledTaskWithHighestPrivileges {
    [CmdletBinding()]
    param(
        # The name of the scheduled task
        [Parameter(Mandatory=$true)]
        [string]$TaskName,
        # The script to run as the task action
        [Parameter(Mandatory=$true)]
        [string]$Script,
        # The repetition interval of the task trigger
        [Parameter(Mandatory=$true)]
        [timespan]$Repeat,
        # The username and password of the task user
        [Parameter(Mandatory=$true)]
        [pscredential]$Credential
    )
    # Add a synopsis comment
    <#
        .SYNOPSIS
        Create a scheduled task to run a script with highest privileges.

        .DESCRIPTION
        This function creates a scheduled task that runs a given script with highest privileges, whether the user is logged on or not. The task is triggered once at the current date and repeats at a specified interval indefinitely. The task also has some settings to ensure it runs only when the network is available and does not stop on battery or idle conditions.

        .EXAMPLE
        New-ScheduledTaskWithHighestPrivileges -TaskName "Recurring PowerShell Task" -Script "w32tm /resync" -Repeat (New-TimeSpan -Hours 3) -Credential (Get-Credential)

        This example creates a scheduled task named "Recurring PowerShell Task" that runs the script "w32tm /resync" every 3 hours with highest privileges, using the credential provided by the user.
    #>
    # Create the task action to execute powershell.exe with the script as argument
    $action = New-ScheduledTaskAction –Execute "$pshome\powershell.exe" -Argument  "$script"
    # Set the repetition duration to the maximum value
    $duration = ([timeSpan]::maxvalue)
    # Create the task trigger to start once at the current date and repeat at the given interval
    $trigger =New-ScheduledTaskTrigger -Once -At (Get-Date).Date -RepetitionInterval $repeat -RepetitionDuration $duration

    # Get the username and password from the credential parameter
    $username = $Credential.UserName
    $password = $Credential.GetNetworkCredential().Password
    # Create the task settings to run only when network is available and not stop on battery or idle conditions
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable -DontStopOnIdleEnd
    # Register the scheduled task with the given name, action, trigger, user, password, settings and run level
    Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger -RunLevel Highest -User $username -Password $password -Settings $settings

}

# Main script

# Define the variables for the function parameters
$jobname = "Recurring PowerShell Task"
$script =  "w32tm /resync"
$repeat = (New-TimeSpan -hours 3)
$msg = "Enter the username and password that will run the task"; 
$credential = $Host.UI.PromptForCredential("Task username and password",$msg,"$env:userdomain\$env:username",$env:userdomain)

# Call the function with the parameters
New-ScheduledTaskWithHighestPrivileges -TaskName $jobname -Script $script -Repeat $repeat -Credential $credential

```