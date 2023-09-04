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
$connection = New-Object System.Data.SQLite.SQLiteConnection

# Set the connection string to use the database file
$connection.ConnectionString = "Data Source=$dbFile"

# Open the connection
try {
    $connection.Open()
    Write-Output "Opened connection to $dbFile"
}
catch {
    Write-Error "Failed to open connection to $dbFile : $_"
    exit
}

# Create a new SQLite command object
$command = $connection.CreateCommand()

# Check if the gists table exists in the database
$command.CommandText = "SELECT name FROM sqlite_master WHERE type='table' AND name='gists'"
$tableExists = $command.ExecuteScalar()

# If the table does not exist, create it with the required columns
if (-not $tableExists) {
    try {
        # Add a column for filecontent to store the content of each gist file as a blob
        $command.CommandText = "CREATE TABLE gists (id TEXT PRIMARY KEY, filename TEXT, visibility TEXT, description TEXT, filecontent BLOB)"
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
        [System.Data.SQLite.SQLiteCommand]$Command
    )

    # Set the command text to select the ID and filename from the gists table where they match the given values
    $Command.CommandText = "SELECT id, filename FROM gists WHERE id='$Id'"

    # Execute the command and return a boolean value indicating whether the gist exists or not
    return [bool]$Command.ExecuteScalar()
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
        [string]$Description,

        # The content of the gist file to insert as a byte array
        [byte[]]$FileContent,

        # The SQLite command object to execute queries on the database
        [System.Data.SQLite.SQLiteCommand]$Command
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
    if (-not [string]::IsNullOrEmpty($Description)) {
        $columns += "description"
        $values += "'$Description'"
    }
    if ($FileContent -ne $null) {
        $columns += "filecontent"
        # Add a placeholder for the file content parameter
        $values += "@FileContent"
    }

    # Join the arrays with commas to form the column names and values part of the command text
    $columnNames = $columns -join ", "
    $columnValues = $values -join ", "

    # Set the command text to insert a row into the gists table with the given values
    $commandText = "INSERT INTO gists ($columnNames) VALUES ($columnValues)"

    # Set the command text property of the command object
    $Command.CommandText = $commandText

    # If the file content parameter is not null, add a parameter for it as a blob type and bind it to the byte array value
    if ($FileContent -ne $null) {
        $Command.Parameters.Add("@FileContent", [System.Data.DbType]::Blob).Value = $FileContent
    }

    # Execute the command and return a boolean value indicating whether it succeeded or not
    try {
        try {
            Write-Output $Command.ExecuteNonQuery()
        }
        catch {
            throw $_
        }
        return $true
    }
    catch {
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
        [string]$Description,

        # The content of the gist file to update as a byte array
        [byte[]]$FileContent,

        # The SQLite command object to execute queries on the database
        [System.Data.SQLite.SQLiteCommand]$Command
    )

    # Set the command text to update a row in the gists table with the given values where they match the given ID and filename
    $Command.CommandText = "UPDATE gists SET visibility='$Visibility', description='$Description', filecontent=@FileContent WHERE id='$Id' AND filename='$Filename'"

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
            $gists = gh api gists --paginate --cache "1h" --jq '.[] | {id, files, public, description}' | ConvertFrom-Json -AsHashtable
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

                # Get the description of the gist, or use a default value if empty
                $description = $gist.description

                # Loop through each file in the gist and get its name and content
                foreach ($file in $gist.files) {
                    # Get the filename of the gist file
                    $filename = $file.Keys[0]
                    $vs = $file.Values
                    $gq = $vs[0]
                    # Get the URL of the gist file from its value object
                    $fileUrl = $gq.raw_url

                    # Create a PowerShell custom object with the gist information and content
                    $gistObject = [PSCustomObject]@{
                        Id = $id
                        Filename = $filename
                        Visibility = $visibility
                        Description = $description
                        FileContent = $fileContent
                    }

                    # Output the gist object to the pipeline or store it in a variable as needed
                    $gistObject
                }
            }
            catch {
                Write-Error "Failed to get gists from GitHub for user: $Username : $_"
                return
            }
        } catch {}
    }
}

# Check if the gist already exists in the table by ID and filename using the Test-GistExists function

# Call the function to get gists from GitHub for the current user with the force flag parameter
$gObjs =  Get-GistsFromGitHub -Username $env:USERNAME -Force:$Force -Command $command
$gObjs | %{ 
    $gistExists = Test-GistExists -Id $id -Filename $filename -Command $Command

    # If the gist does not exist, insert it into the table with its information but without its content using the Add-Gist function
    if (-not $gistExists) {
        if (Add-Gist -Id $id -Filename $filename -Visibility $visibility -Description $description -Command $Command) {
            Write-Output "Inserted gist with ID: $id and filename: $filename for user: $Username without content"
        }
        else {
            Write-Verbose "Failed to insert gist with ID: $id and filename: $filename for user: $Username without content: $_"
        }
    }
    # If the gist exists, skip it as it already has its information and content in the table
    else {
        Write-Verbose "Skipped gist with ID: $id and filename: $filename for user: $Username as it already exists in the table"
    }
}

# Get all the gists from the table that do not have a file content for the given username
try {
    # Set the command text to select all columns from the gists table where filecontent is null and filename matches the username pattern
    $Command.CommandText = "SELECT * FROM gists WHERE filecontent IS NULL AND filename LIKE '%/$Username/%'"
    # Execute the command and get a data reader object
    $reader = $Command.ExecuteReader()
    # Create an empty array to store the gists without content as custom objects
    $gistsWithoutContent = @()
    # Loop through each row of the data reader and create a custom object with its values
    while ($reader.Read()) {
        # Get the gist information from each row of the table
        $id = [string]$reader["id"]
        $filename = [string]$reader["filename"]
        $visibility = [string]$reader["visibility"]
        $description = [string]$reader["description"]

        # Create a PowerShell custom object with the gist information and add it to the array
        $gistObject = [PSCustomObject]@{
            Id = $id
            Filename = $filename
            Visibility = $visibility
            Description = $description
        }
        $gistsWithoutContent += $gistObject
    }

}
catch {
    Write-Error "Failed to get gists without content from the table for user: $Username : $_"
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
        Write-Verbose "Updated gist with ID: $id and filename: $filename for user: $Username with content"
    }
    else {
        Write-Error "Failed to update gist with ID: $id and filename: $filename for user: $Username with content: $_"
        continue
    }
}




# Get all the gists from the table and output information
try {
    $command.CommandText = "SELECT * FROM gists"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        # Get the gist information from each row of the table
        $id = $reader["id"]
        $filename = $reader["filename"]
        $visibility = $reader["visibility"]
        $description = $reader["description"]
        # Get the file content as a byte array and convert it to a string using UTF8 encoding
        $fileContent = [System.Text.Encoding]::UTF8.GetString($reader["filecontent"])

        # Output the information in a formatted string
        Write-Output "Gist ID: $id"
        Write-Output "Gist filename: $filename"
        Write-Output "Visibility: $visibility"
        Write-Output "Description: $description"
        Write-Output "File content:"
        # Use a code block to display the file content in a formatted way
        Write-Output "```powershell"
        Write-Output "$fileContent"        
        Write-Output ""
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