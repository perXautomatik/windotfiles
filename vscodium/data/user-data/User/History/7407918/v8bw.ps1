# Define a namespace for the aggregation tools
namespace aggregationTools {

    # Define a function to join two tables on a common column
    function Join-On {
        <#
        .SYNOPSIS
        Joins two tables on a common column.

        .DESCRIPTION
        This function joins two tables on a common column and returns the result as a new table. It takes the first table from the pipeline and the second table as a parameter. It also takes the name of the column to join on as a parameter.

        .PARAMETER JoinTarget
        The second table to join with. This parameter is mandatory and must be a valid table object.

        .PARAMETER ColumnName
        The name of the column to join on. This parameter is mandatory and must be a valid column name in both tables.

        .EXAMPLE
        $table1 | Join-On -JoinTarget $table2 -ColumnName "ID"

        This example joins $table1 and $table2 on the "ID" column and returns the result as a new table.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
            [ValidateNotNull()]
            [object]$InputObject, # The first table to join with

            [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [object]$JoinTarget, # The second table to join with

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$ColumnName # The name of the column to join on
        )

        # Validate the parameters
        if (-not ($InputObject -is [System.Data.DataTable])) {
            Write-Error "Input object must be a table"
            return
        }

        if (-not ($JoinTarget -is [System.Data.DataTable])) {
            Write-Error "Join target must be a table"
            return
        }

        if (-not ($InputObject.Columns.Contains($ColumnName))) {
            Write-Error "Input object does not have column $ColumnName"
            return
        }

        if (-not ($JoinTarget.Columns.Contains($ColumnName))) {
            Write-Error "Join target does not have column $ColumnName"
            return
        }

        # Create a new table to store the join result
        $result = New-Object System.Data.DataTable

        # Add all the columns from both tables to the result table
        foreach ($column in $InputObject.Columns) {
            $result.Columns.Add($column.ColumnName, $column.DataType)
        }

        foreach ($column in $JoinTarget.Columns) {
            # Skip the column that is used for joining to avoid duplication
            if ($column.ColumnName -ne $ColumnName) {
                $result.Columns.Add($column.ColumnName, $column.DataType)
            }
        }

        # Loop through the rows of the first table
        foreach ($row1 in $InputObject.Rows) {
            # Get the value of the join column for the current row
            $value = $row1[$ColumnName]

            # Find all the matching rows in the second table using Select method
            $matches = $JoinTarget.Select("$ColumnName = '$value'")

            # Loop through the matching rows
            foreach ($row2 in $matches) {
                # Create a new row for the result table using NewRow method
                $newRow = $result.NewRow()

                # Copy all the values from both rows to the new row
                foreach ($column in $InputObject.Columns) {
                    $newRow[$column.ColumnName] = $row1[$column.ColumnName]
                }

                foreach ($column in $JoinTarget.Columns) {
                    # Skip the column that is used for joining to avoid duplication
                    if ($column.ColumnName -ne $ColumnName) {
                        $newRow[$column.ColumnName] = $row2[$column.ColumnName]
                    }
                }

                # Add the new row to the result table using Add method
                $result.Rows.Add($newRow)
            }
        }

        # Return the result table
        return $result
    }

    # Define a function to perform an inner join on two tables on a common column
    function InnerJoin-On {
        <#
        .SYNOPSIS
        Performs an inner join on two tables on a common column.

        .DESCRIPTION
        This function performs an inner join on two tables on a common column and returns the result as a new table. It takes the first table from the pipeline and the second table as a parameter. It also takes the name of the column to join on as a parameter. An inner join only includes rows that have matching values in both tables.

        .PARAMETER JoinTarget
        The second table to join with. This parameter is mandatory and must be a valid table object.

        .PARAMETER ColumnName
        The name of the column to join on. This parameter is mandatory and must be a valid column name in both tables.

        .EXAMPLE
        $table1 | InnerJoin-On -JoinTarget $table2 -ColumnName "ID"

        This example performs an inner join on $table1 and $table2 on the "ID" column and returns the result as a new table.
        #>
        [CmdletBinding()]
        param(
            [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
            [ValidateNotNull()]
            [object]$InputObject, # The first table to join with

            [Parameter(Mandatory=$true)]
            [ValidateNotNull()]
            [object]$JoinTarget, # The second table to join with

            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$ColumnName # The name of the column to join on
        )

        # Validate the parameters
        if (-not ($InputObject -is [System.Data.DataTable])) {
            Write-Error "Input object must be a table"
            return
        }

        if (-not ($JoinTarget -is [System.Data.DataTable])) {
            Write-Error "Join target must be a table"
            return
        }

        if (-not ($InputObject.Columns.Contains($ColumnName))) {
            Write-Error "Input object does not have column $ColumnName"
            return
        }

        if (-not ($JoinTarget.Columns.Contains($ColumnName))) {
            Write-Error "Join target does not have column $ColumnName"
            return
        }

        # Create a new table to store the join result
        $result = New-Object System.Data.DataTable

        # Add all the columns from both tables to the result table
        foreach ($column in $InputObject.Columns) {
            $result.Columns.Add($column.ColumnName, $column.DataType)
        }

        foreach ($column in $JoinTarget.Columns) {
            # Skip the column that is used for joining to avoid duplication
            if ($column.ColumnName -ne $ColumnName) {
                $result.Columns.Add($column.ColumnName, $column.DataType)
            }
        }

        # Loop through the rows of the first table
        foreach ($row1 in $InputObject.Rows) {
            # Get the value of the join column for the current row
            $value = $row1[$ColumnName]

            # Find all the matching rows in the second table using Select method
            $matches = $JoinTarget.Select("$ColumnName = '$value'")

            # Check if there are any matches
            if ($matches.Count -gt 0) {
                # Loop through the matching rows
                foreach ($row2 in $matches) {
                    # Create a new row for the result table using NewRow method
                    $newRow = $result.NewRow()

                    # Copy all the values from both rows to the new row
                    foreach ($column in $InputObject.Columns) {
                        $newRow[$column.ColumnName] = $row1[$column.ColumnName]
                    }

                    foreach ($column in $JoinTarget.Columns) {
                        # Skip the column that is used for joining to avoid duplication
                        if ($column.ColumnName -ne $ColumnName) {
                            $newRow[$column.ColumnName] = $row2[$column.ColumnName]
                        }
                    }

                    # Add the new row to the result table using Add method
                    $result.Rows.Add($newRow)
                }
            }
        }

        # Return the result table
        return $result
    }

    # Define a function to perform a union on two tables by column index
    function Union {
        <#
        .SYNOPSIS
        Performs a union on two tables by column index.

        .DESCRIPTION
        This function performs a union on two tables by column index and returns the result as a new table. It takes the first table from the pipeline and the second table as a parameter. It also takes an optional parameter to specify column pairings. A union combines all rows from both tables and adds null columns if uneven. If no null columns flag is specified, it removes any null columns from the result.

        .PARAMETER JoinTarget
        The second table to join with. This parameter is mandatory and must be a valid table object.

        .PARAMETER ColumnPairings
        A hashtable of column pairings to specify which columns from both tables should be matched. The keys are the column indexes from the first table and the values are the column indexes from the second table. This parameter is optional and defaults to an empty hashtable.

        .PARAMETER NoNullColumns
        A switch to indicate whether to remove any null columns from the result or not. This parameter is optional and defaults to false.

        .EXAMPLE
        $table1 | Union -JoinTarget $table2

        This example performs a union on $table1 and $table2 by column index and returns the result as a new table.
        
        .EXAMPLE
        $table1 | Union -JoinTarget $table2 -ColumnPairings @{0