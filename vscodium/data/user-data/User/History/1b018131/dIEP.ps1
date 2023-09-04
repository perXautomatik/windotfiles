# Define the force flag parameter
param (
[switch]$Force
)

# Install gh if not already installed
if (-not (Get-Command -Name gh -ErrorAction SilentlyContinue)) {
    iwr -useb https://cli.github.com/packages/install.ps1 | iex
}

# Define the name of the SQLite database file
$dbFile = "gists.db"

$PSScriptRoot
$dllPath = "C:\ProgramData\scoop\apps\flow-launcher\1.15.0\app-1.15.0\Plugins\Flow.Launcher.Plugin.BrowserBookmark\System.Data.SQLite.dll"

# Import the System.Data.SQLite module
try {
    Import-Module $dllPath
    Write-Output "Imported System.Data.SQLite module"
}
catch {
    Write-Error "Failed to import System.Data.SQLite module : $_"
    exit
}

# Create a new SQLite connection object
$mainConnection = New-Object System.Data.SQLite.SQLiteConnection

# Set the connection string to use the database file
$mainConnection.ConnectionString = "Data Source=$dbFile"

# Open the connection
try {
    $mainConnection.Open()
    Write-Output "Opened connection to $dbFile"
}
catch {
    Write-Error "Failed to open connection to $dbFile : $_"
    exit
}

# Create a new SQLite command object
$command = $mainConnection.CreateCommand()

# Check if the gists table exists in the database
$command.CommandText = "SELECT name FROM sqlite_master WHERE type='table' AND name='gists'"
$tableExists = $command.ExecuteScalar()

# If the table does not exist, create it with the required columns
if (-not $tableExists) {
    try {
        # Add a column for filecontent to store the content of each gist file as a blob
        $command.CommandText = "CREATE TABLE gists (id TEXT PRIMARY KEY, filename TEXT, visibility TEXT, description TEXT, filecontent BLOB, updated_at DATETIME, UNIQUE (id, filename))"
        $command.ExecuteNonQuery()
        Write-Output "Created table gists"
    }
    catch {
        Write-Error "Failed to create table gists: $_"
        exit
    }
}
else {
    Write-Output "Table gists already exists"
}

# Import the custom module that contains the functions for working with gists
try {

    # If the force flag is not set, check if there are any gists in the table for the given username
    if (-not $Force) {
        try {
            $Command.CommandText = "SELECT COUNT(*) FROM gists"
            $gistCount = $Command.ExecuteScalar()
            Write-Output "There are $gistCount gists in the table for user $Username"
        }
        catch {
            Write-Error "Failed to count gists in the table for user $Username : $_"
            return
        }
    }
} catch {}

    
# Define a function to check if a gist exists in the database by ID and filename
function Test-GistExists {
    param (
        # The ID of the gist to check
        [string]$Id,

        # The filename of the gist to check
        [string]$Filename,

        # The SQLite command object to execute queries on the database
        [System.Data.SQLite.SQLiteConnection]$connection
    )


    # Create a SqlCommand object with the connection
    $Command = New-Object System.Data.SQLite.SQLiteCommand
    $Command.Connection = $Connection


    # Set the command text to select all columns from the gists table where they match the given ID and filename
    $Command.CommandText = "SELECT * FROM gists WHERE id='$Id'"

    # Execute the command and get a data reader object
    $reader = $Command.ExecuteReader()

    # Check if the reader has any rows
    if ($reader.HasRows) {
       
        # Return true as the gist exists in the database
        return $true
    }
    else {

        # Return false as the gist does not exist in the database
        return $false
    }
}
# Define a function to insert a gist into the database with its information and content
function Add-Gist {
    param (
        # The ID of the gist to insert
        [string]$Id,

        # The filename of the gist to insert
        [string]$Filename,

        # The visibility of the gist to insert (public or private)
        [string]$Visibility,

        # The description of the gist to insert
        [string]$iDescription,

        # The content of the gist file to insert as a byte array
        [byte[]]$FileContent,

        [datetime] $updated_at,
        # The SQLite command object to execute queries on the database
        [System.Data.SQLite.SQLiteConnection]$connection
    )

    # Create an empty string to store the command text
    $commandText = ""

    # Create an empty array to store the column names and values
    $columns = @()
    $values = @()

    # Check each parameter and add it to the array if it is not null or empty
    if (-not [string]::IsNullOrEmpty($Id)) {
        $columns += "id"
        $values += "'$Id'"
    }
    if (-not [string]::IsNullOrEmpty($Filename)) {
        $columns += "filename"
        $values += "'$Filename'"
    }
    if (-not [string]::IsNullOrEmpty($Visibility)) {
        $columns += "visibility"
        $values += "'$Visibility'"
    }
    if (-not [string]::IsNullOrEmpty($iDescription)) {
        $columns += "description"
        $values += "'$iDescription'"
    }
    if (-not [string]::IsNullOrEmpty($updated_at)) {
        $columns += "updated_at"
        $values += "'$updated_at'"
    }
    if ($FileContent -ne $null) {
        $columns += "filecontent"
        # Add a placeholder for the file content parameter
        $values += "@FileContent"
    }
    else {
        $columns += "filecontent"
        $values += "NULL"
    }
    # Join the arrays with commas to form the column names and values part of the command text
    $columnNames = $columns -join ", "
    $columnValues = $values -join ", "

    # Set the command text to insert a row into the gists table with the given values
    $commandText = "INSERT INTO gists ($columnNames) VALUES ($columnValues)"


    # Create a SqlCommand object with the connection
    $Command = New-Object System.Data.SQLite.SQLiteCommand
    $Command.Connection = $Connection

    # Set the command text property of the command object
    $Command.CommandText = $commandText

    # If the file content parameter is not null, add a parameter for it as a blob type and bind it to the byte array value
    if ($FileContent -ne $null) {
        $Command.Parameters.Add("@FileContent", [System.Data.DbType]::Blob).Value = $FileContent
    }


    # Execute the command and return a boolean value indicating whether it succeeded or not
    try {
        $Command.ExecuteNonQuery()
        return $true
    }
    catch {
        # Get the exception message from the error object
        $errorMessage = $_.Exception.Message

                # Check if the error message contains "UNIQUE constraint failed" indicating a unique key violation
        if ($errorMessage -match "UNIQUE constraint failed") {
            # Get the column name and value that caused the violation from the error message using a regular expression
            if ($errorMessage -match "UNIQUE constraint failed: gists.(\w+) \((.+)\)") {
                # Assign the matched groups to variables for readability
                $columnName = $Matches[1]
                $columnValue = $Matches[2]

                # Write an error message that explains why the insertion failed and what value was submitted and what was already there in the table
                Write-Error "Failed to insert gist into the table because there is already another gist with the same value for column: '$columnName'. You submitted: '$columnValue' but there is already a gist with that value in the table."
            }
            else {
                # Write an error message that shows the gist that was tried to insert and the gist that is already in the database
                # Get the gist information and content from the parameters and convert them to a string
                # Initialize a variable to store the file content as a string
                $FileContentString = ""

                # Try to convert the byte array to a string using the GetString method
                try {
                    $FileContentString = [System.Text.Encoding]::UTF8.GetString($FileContent)
                }
                # Catch the exception if the byte array is null or empty
                catch {
                    # Write a warning message to the console
                    Write-Warning "The file content is null or empty. Cannot convert to string."
                }

                # Create a custom object with the gist information and file content string
                $gistToInsert = [PSCustomObject]@{
                    Id = $Id
                    Filename = $Filename
                    Visibility = $Visibility
                    Description = $Description
                    FileContent = $FileContentString
                } | Out-String

                # Get the gist information and content from the table by using the Test-GistExists function with the -Verbose switch
                # This will print the gist that is already in the table to the verbose stream, which can be captured by using 4>&1 redirection
                $gistInTable = Test-GistExists -Id $Id -Filename $Filename -Command $Command -Verbose 4>&1

                # Write an error message that shows the gist that was tried to insert and the gist that is already in the database
                Write-Error "Failed to insert gist into the table because there is already another gist with some of the same values. Please check your input and try again.`nGist you tried to insert:`n$gistToInsert`nCurrently in database:`n$gistInTable"
            }
        }
        else {
            # Write an error message that indicates a generic SQLite error and shows its message
            Write-Error "Failed to insert gist into the table due to an SQLite error: '$errorMessage'"
}

        # Return false as the insertion failed
        return $false
    }
}



# Define a function to update a gist in the database with its information and content
function Update-Gist {
    param (
        # The ID of the gist to update
        [string]$Id,

        # The filename of the gist to update
        [string]$Filename,

        # The visibility of the gist to update (public or private)
        [string]$Visibility,

        # The description of the gist to update
        [string]$uDescription,

        # The content of the gist file to update as a byte array
        [byte[]]$FileContent,

        # The SQLite command object to execute queries on the database
        [System.Data.SQLite.SQLiteCommand]$Command
    )

    # Set the command text to update a row in the gists table with the given values where they match the given ID and filename
    $Command.CommandText = "UPDATE gists SET visibility='$Visibility', description='$uDescription', filecontent=@FileContent WHERE id='$Id' AND filename='$Filename'"

    # Add a parameter for the file content as a blob type and bind it to the byte array value
    $Command.Parameters.Add("@FileContent", [System.Data.DbType]::Blob).Value = $FileContent

    # Execute the command and return a boolean value indicating whether it succeeded or not
    try {
        $Command.ExecuteNonQuery()
        return $true
    }
    catch {
        return $false
    }
}    

     # If the force flag is not set, check if there are any gists in the table for the given username
    if (-not $Force) {
        try {
            $Command.CommandText = "SELECT COUNT(*) FROM gists WHERE filename LIKE '%/$Username/%'"
            $gistCount = $Command.ExecuteScalar()
            Write-Verbose "There are $gistCount gists in the table for user $Username"
        }
        catch {
            Write-Error "Failed to count gists in the table for user $Username : $_"
            return
        }
    }
	
# Define a function to get gists from GitHub with parameters
function Get-GistsFromGitHub {
    param (
        # The username of the GitHub user whose gists are to be fetched
        [string]$Username,

        # The flag to indicate whether to force fetching gists from GitHub or not
        [switch]$Force,

        # The SQLite command object to execute queries on the database
        [System.Data.SQLite.SQLiteCommand]$Command
    )

    # If the force flag is set or there are no gists in the table for the given username, get the list of gists from GitHub
    if ($Force -or -not $gistCount) {
        try {
                        
            # Initialize a variable to keep track of the index in the loop
            $i = 0
            # Get the array of gists from the gh api command
            $gists = gh api gists --paginate --cache "1h" --jq '.[] | {id,files,public,description,updated_at}' | ConvertFrom-Json -AsHashtable
            # Get the number of gists in the array
            $gistCount = $gists.Count

            # Loop through each gist in the array
            foreach ($gist in $gists) {
                # Increment the index by one
                $i++
                # Write a progress bar with the current gist information
                Write-Progress -Activity "Downloading gists" -Status "$i of $gistCount gists downloaded" -PercentComplete ($i / $gistCount * 100) -CurrentOperation "Downloading gist $($gist.id)"

                # Get the gist ID and URL
                $id = $gist.id
                $url = "https://gist.github.com/$id"

                # Get the number of files in the gist
                $files = $gist.files.Count

                # Get the visibility of the gist (public or private)
                if ($gist.public) {
                    $visibility = "public"
                }
                else {
                    $visibility = "private"
                }

                # Loop through each file in the gist and get its name and content
                foreach ($file in $gist.files) {
                    # Get the filename of the gist file
                    $vs = $file.Values
                    $gq = $vs[0]
                    # Get the URL of the gist file from its value object
                    $fileUrl = $gq.raw_url

                    # Create a PowerShell custom object with the gist information and content
                    $gistObject = [PSCustomObject]@{
                        Id = $id
                        Filename = $file.Keys[0]
                        Visibility = $visibility
                        Description = $gist.description
                        FileContent = $fileContent
                        updated_at = [DateTime]::Parse($gist.updated_at)
                    }

                    # Output the gist object to the pipeline or store it in a variable as needed
                    $gistObject
                }
            }
            catch {
                Write-Error "Failed to get gists from GitHub : $_"
                return
            }
        } catch {}
    }
}

# Check if the gist already exists in the table by ID and filename using the Test-GistExists function

# Call the function to get gists from GitHub for the current user with the force flag parameter
$gObjs =  Get-GistsFromGitHub -Username $env:USERNAME -Force:$Force -Command $command


# Create a SqlConnection object with a connection string
$SqlConnection = $mainConnection;

$gObjs | %{
        # Assume $item is an object with properties that match the parameters of the Add-Gist function
        $item = $_

        # Check if the gist exists in the database using the Test-GistExists function
        $gistExists = Test-GistExists -Id $item.id -Filename $item.filename -connection $SqlConnection

        # If the gist does not exist, insert it into the table using the Add-Gist function with splatting
        if (-not $gistExists) {
            # Create a hashtable with the parameters and values from the $item object
            $params = @{
                Id = $item.id
                Filename = $item.filename.Replace("'", "''")
                Visibility = $item.visibility
                Description = $item.description
                Connection = $SqlConnection
                updated_at = $item.updated_at
            }

            # Call the Add-Gist function with splatting using the @ symbol before the hashtable name
            if (Add-Gist @params) {
                # Do something if the insertion was successful
            }          
            else {
                Write-Output "Failed to insert gist with ID: "+ $item.id+" and filename: "+ $item.filename +" without content: $_"
            }
        }
        # If the gist exists, skip it as it already has its information and content in the table
        else {
            Write-Verbose ("Skipped gist with ID:  "+ $item.id+" and filename: "+ $item.filename +" as it already exists in the table")
        }
}
    
# Close the connection
    $SqlConnection.Close()

    # Open the connection
try {
    $mainConnection.Open()
    Write-Output "Opened connection to $dbFile"
}
catch {
    Write-Error "Failed to open connection to $dbFile : $_"
    exit
}
# Define a function that takes a command text and a connection object as parameters
function Get-Gists {
    param (
        [string]$CommandText,
        [System.Data.SQLite.SQLiteConnection]$Connection
    )

    # Create a SQLiteCommand object with the command text and the connection
    $Command = New-Object System.Data.SQLite.SQLiteCommand
    $Command.CommandText = $CommandText
    $Command.Connection = $Connection

    # Execute the command and get a data reader object
    $Reader = $Command.ExecuteReader()

    # Loop through each row of the data reader and create a custom object with its values
    while ($Reader.Read()) {
        $fileContentString = $null;
        # Check if the file content is null or empty
        if (-not $reader.IsDBNull($reader.GetOrdinal("filecontent")) -and $fileContent.Length -gt 0) {
            # Convert the byte array to a string using UTF8 encoding
            $fileContentString = [System.Text.Encoding]::UTF8.GetString($fileContent)
        }
        else {
            # Write a warning message to the console
            $fileContentString = $null;
        }

        $null = [string]$Reader["id"]
        $null = [string]$Reader["filename"]
        $null = [string]$Reader["visibility"]
        $null = [string]$Reader["description"]
        $null = $fileContentString
        $null = $Reader["updated_at"]

        # Create a PowerShell custom object with the gist information and output it to the pipeline
        [PSCustomObject]@{
            Id = [string]$Reader["id"]
            Filename = [string]$Reader["filename"]
            Visibility = [string]$Reader["visibility"]
            Description = [string]$Reader["description"]
            FileContent = $fileContentString
            updated_at = [DateTime]$Reader["updated_at"]
        }
    }
}

# Get all the gists from the table that do not have a file content for the given username
try {
    # Set the command text to select all columns from the gists table where filecontent is null and filename matches the username pattern
    $gistsWithoutContent = Get-Gists -CommandText "SELECT * FROM gists WHERE filecontent IS NULL" -Connection $SqlConnection

}
catch {
    Write-Error "Failed to get gists without content from the table : $_"
    return
}

# Loop through each gist without content and fetch its content from GitHub and update it in the table
foreach ($gist in $gistsWithoutContent) {
    # Get the gist ID, filename, and URL
    $id = $gist.Id
    $filename = $gist.Filename
    $url = "https://gist.github.com/$Username/$id/$filename"

    # Download the content of the gist file as a byte array using Invoke-WebRequest
    try {
        $fileContent = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    }
    catch {
        Write-Error "Failed to download file content from URL: $url : $_"
        continue
    }

    # Update the gist in the table with its content using the Update-Gist function
    if (Update-Gist -Id $id -Filename $filename -FileContent $fileContent -Command $Command) {
        Write-Verbose "Updated gist with ID: "+ $item.id+" and filename: "+ $item.filename +" with content"
    }
    else {
        Write-Error "Failed to update gist with ID: "+ $item.id+" and filename: "+ $item.filename +" with content: $_"
        continue
    }
}


# Get all the gists from the table and output information
try {
    Get-Gists -CommandText "SELECT * FROM gists" -Connection $SqlConnection | % {

        # Output the information in a formatted string
        Write-Output "Gist ID: " + $_.id
        Write-Output "Gist filename: " + $_.filename
        Write-Output "Visibility: " + $_.visibility
        Write-Output "Description: " + $_.description
        Write-Output "File content:"
        # Use a code block to display the file content in a formatted way
        Write-Output $_.fileContent

    }
}
catch {
    Write-Error "Failed to get gists from the table: $_"
    exit
}
finally {
    # Close the reader and dispose it
    if ($reader) {
        $reader.Close()
        $reader.Dispose()
        Write-Output "Closed reader and disposed it"
    }

    # Close the connection and dispose it
    if ($connection) {
        $connection.Close()
        Write-Output "Closed connection and disposed it"
    }
}