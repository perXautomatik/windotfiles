function git-GetSubmodulePathsUrls
{  
      [CmdletBinding()]
        Param(       
            [Parameter(Mandatory=$true)]
            [ValidateScript({Test-Path -Path "$_\.gitmodules"})]            
            [string]
            $RepoPath
        )
        try {    
            if(validGitRepo)
            {
                $zz = (git config -f .gitmodules --get-regexp '^submodule\..*\.path$')  
            }
            else{
                $rgx = "submodule" # Set the regular expression to use for splitting

                # Change the current directory to the working path
                Set-Location $RepoPath

                # Set the path to the .gitmodules file
                $p = Join-Path $RepoPath ".gitmodules"

                # Split the text in the .gitmodules file by the regular expression and store the results in a variable
                $TextRanges = Split-TextByRegex -Path $p -Regx $rgx

                $zz = $TextRanges | keyPairTo-PsCustom 
                if(! ($zz))
                {
                    # Convert the key-value pairs in the text ranges to custom objects and store the results in a variable
                    $zz = $TextRanges | ForEach-Object {
                        try {
                            # Trim and join the values in each text range
                            $q = $_.value.trim() -join ","
                        }
                        catch {
                            # If trimming fails, just join the values
                            $q = $_.value -join ","
                        }
                        try {
                            # Split the string by commas and equal signs and create a hashtable with the path and url keys
                            $t = @{
                                path = $q.Split(',')[0].Split('=')[1].trim()
                                url = $q.Split(',')[1].Split('=')[1].trim()
                            }
                        }
                        catch {
                            # If splitting fails, just use the string as it is
                            $t = $q
                        }
                        # Convert the hashtable to a JSON string and then back to a custom object
                        $t | ConvertTo-Json | ConvertFrom-Json
                    }
              }
            }

            $zz| % {
                $path_key, $path = $_.split(" ")
                $prop = [ordered]@{ 
                    Path = $path
                    Url = git config -f .gitmodules --get ("$path_key" -replace "\.path",".url")
                    NonRelative = Join-Path $RepoPath $path
                }
                return New-Object –TypeName PSObject -Property $prop
            }        
        }
        catch{
            Throw "$($_.Exception.Message)"
        }
}
