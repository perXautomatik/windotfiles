function git-root {
    $gitrootdir = (git rev-parse --show-toplevel)
    if ($gitrootdir) {
    Set-Location $gitrootdir
    }
}
