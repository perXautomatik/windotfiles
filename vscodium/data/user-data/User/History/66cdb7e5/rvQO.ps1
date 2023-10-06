# Define a function to split a .gitattributes file into ranges
function Split-GitAttributes {
    # Get the file content as an array of lines
    $file = Get-Content -Path $args[0]

    # Initialize an empty list of ranges
    $ranges = @()

    # Initialize the current range type, start, end, and order
    $type = ""
    $start = 0
    $end = 0
    $order = 0

    # Loop through each line in the file
    foreach ($line in $file) {
        # Check if the line is a comment, an entry, or an empty line
        if ($line -match "^#") {
            # The line is a comment
            if ($type -eq "comment") {
                # The current range is also a comment, so extend it
                $end++
            }
            else {
                # The current range is not a comment, so save it and start a new one
                if ($type -ne "") {
                    $ranges += [PSCustomObject]@{
                        Type = $type
                        Start = $start
                        End = $end
                        Order = $order
                    }
                    $order++
                }
                $type = "comment"
                $start = $end + 1
                $end++
            }
        }
        elseif ($line -match "\S") {
            # The line is an entry (contains non-whitespace characters)
            if ($type -eq "entry") {
                # The current range is also an entry, so extend it
                $end++
            }
            else {
                # The current range is not an entry, so save it and start a new one
                if ($type -ne "") {
                    $ranges += [PSCustomObject]@{
                        Type = $type
                        Start = $start
                        End = $end
                        Order = $order
                    }
                    $order++
                }
                $type = "entry"
                $start = $end + 1
                $end++
            }
        }
        else {
            # The line is an empty line, so skip it and increment the end index
            $end++
        }
    }

    # Save the last range if any
    if ($type -ne "") {
        $ranges += [PSCustomObject]@{
            Type = $type
            Start = $start
            End = $end
            Order = $order
        }
    }

    # Initialize an empty list of associations
    $associations = @()

    # Loop through each entry range in the ranges list
    foreach ($entry in ($ranges | Where-Object {$_.Type -eq "entry"})) {
        # Find the comment range that has -1 order (above the entry range)
        $comment = ($ranges | Where-Object {$_.Type -eq "comment" -and $_.Order -eq ($entry.Order - 1)}) | Select-Object -First 1

        # Associate the entry range with the comment range if any, and add it to the associations list
        if ($comment) {
            $associations += [PSCustomObject]@{
                EntryRange = "$($entry.Start)-$($entry.End)"
                CommentRange = "$($comment.Start)-$($comment.End)"
            }
        }
        else {
            # No comment range found, so use null as the value for the comment range
            $associations += [PSCustomObject]@{
                EntryRange = "$($entry.Start)-$($entry.End)"
                CommentRange = $null
            }
        }
    }

    # Return the associations list as the result set
    return $associations

}

# Call the function with a sample .gitattributes file and display the result set in a table format

Split-GitAttributes ".\sample.gitattributes" | Format-Table

