permently rewrites history to only include what's dictated in filter
 --index-filter 'git ls-files | grep -v "^SolVision" | xargs --no-run-if-empty git rm --cached' HEAD
git filter-branch --subdirectory-filter 'Organized/SolVision'
