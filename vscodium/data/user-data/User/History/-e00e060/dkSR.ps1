function Join () {

    param
    (
        # Define the source path where the scripts are located
        $sourcePath = "C:\Scripts",

        # Define the destination file where the scripts will be joined
        $destinationFile = "C:\JoinedScripts.ps1",

        # Define the delimiter string that will separate the scripts and contain the relative path
        $delimiter = "### Script from {0} ###`n"
        $ext = '.ps1'
    )
    # Get all the script files from the source path recursively
    $scriptFiles = Get-ChildItem -Path $sourcePath -Filter '*+$ext' -Recurse

    # Loop through each script file and append its content to the destination file with the delimiter
    foreach ($scriptFile in $scriptFiles) {
        # Get the relative path of the script file
        $relativePath = $scriptFile.FullName.Replace($sourcePath, "")

        # Write the delimiter with the relative path to the destination file
        $delimiter -f $relativePath | Out-File -FilePath $destinationFile -Append

        # Write the content of the script file to the destination file
        Get-Content -Path $scriptFile.FullName | Out-File -FilePath $destinationFile -Append
    }
}