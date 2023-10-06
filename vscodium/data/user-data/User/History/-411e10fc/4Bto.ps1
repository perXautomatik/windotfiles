function chain-renamePaths ($paths, $newname) {

# Define a function that takes an array of paths and a new filename as parameters
    # Initialize an empty array to store the arguments for git filter-repo
    $args = @()

    # Loop through each path and add a rename-path option to the argument array
    foreach ($path in $paths) {
        # Add a rename-path option with the old and new filenames
        $args += "--rename-path", "$path"+":"+"$newname"
    }

    # Invoke git filter-repo with the argument array
    git filter-repo $args
}
