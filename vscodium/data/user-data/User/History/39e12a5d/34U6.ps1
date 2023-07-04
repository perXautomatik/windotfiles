function AddNabsorb ([string]$ref, [string]$relative) {

    Git submodule add $ref $relative
    echo "#---- commit"
    git commit -m "as submodule $relative"
    echo "#---- absorbgitdirs"
    Git submodule absorbgitdirs $relative

}