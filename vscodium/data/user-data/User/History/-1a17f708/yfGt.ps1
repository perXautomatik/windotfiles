<# Synopsis: Appends all git repositories and their parent paths to queues and runs git status on them in parallel
# Parameters:
#   -QueA: An array of paths to git repositories
#   -SimulTainusJobbCount: The maximum number of parallel jobs to run
# Example usage:
$paths = Get-ChildItem -Path 'D:\Project Shelf\PowerShellProjectFolder\scripts\Modules\Personal\migration' -Recurse -Filter '.git' | Select-Object -ExpandProperty FullName
Append-And-Run -QueA $paths -SimulTainusJobbCount 4

#>
function Append-And-Run {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$QueA,
        [Parameter(Mandatory=$true)]
        [int]$SimulTainusJobbCount
    )

    # Initialize an empty array for QueB
    $QueB = @()

    # For each path in QueA, append the parent path to QueB if it is unique
    foreach ($path in $QueA) {
        $parent = Split-Path $path -Parent
        if ($parent -notin $QueB) {
            $QueB += $parent
        }
    }

    # Initialize an empty array for QueC
    $QueC = @()

    # For each path in QueB, get the child directories and append them to QueC
    foreach ($path in $QueB) {
        $children = Get-ChildItem -Path $path -Directory
        $QueC += $children
    }

    # Initialize an empty hashtable for QueD
    $QueD = @{}

    # For each git repository in QueA, run git status in parallel while limiting the number of simultaneous jobs
    foreach ($git in $QueA) {

        # While the length of QueA is greater than the maximum number of parallel jobs
        while ($QueA.Length -gt $SimulTainusJobbCount) {

            # While the number of active jobs is less than the maximum number of parallel jobs or greater than the length of QueA, and the length of QueA is not zero
            while (($activejobs -lt $SimulTainusJobbCount -or $SimulTainusJobbCount -gt $QueA.Length) -and $QueA.Length -ne 0) {

                # Pop a path from QueA and initiate a threaded job
                $path = $QueA | Select-Object -Last 1
                $QueA = $QueA | Select-Object -First ($QueA.Length - 1)
                Start-Job -ScriptBlock {
                    # Capture the output of git status and push it to QueD with the path and job ID
                    $capture = (git status $args[0])
                    $QueD[$args[0]] = @{
                        "Output" = $capture;
                        "JobID" = Get-Job | Select-Object -Last 1 | Select-Object -ExpandProperty ID;
                    }
                    # Exit the job
                    Exit
                } -ArgumentList $path

            }

            # Clear the screen and output the contents of QueD to the console
            Clear-Host
            foreach ($item in $QueD.GetEnumerator()) {
                Write-Output "$($item.Key):"
                Write-Output "$($item.Value.Output)"
                Write-Output "JobID: $($item.Value.JobID)"
                Write-Output ""
            }
        }
    }
}

