
Write-Host 'Installing and configuring Scoop manifests...'
. "$PSScriptRoot\Utils.ps1"

"advancedrenamer",`                    #Batch file renaming utility for Windows
"autohotkey",`                         #The ultimate automation scripting language for Windows.
"beyondcompare",`                      #Directory and file compare functions in one package
"cherrytree",`                         #Hierarchical note taking application, featuring rich text and syntax highlighting.
"datagrip",`                           #Cross-Platform IDE for Databases & SQL by JetBrains.
"ditto",`                              #An enhanced clipboard manager
"dotter",`                             #Dotfile manager and templater
"everything",`                         #Locate files and folders by name instantly.
"freefilesync",`                       #A folder comparison and synchronization software.
"freemind",`                           #FreeMind is a free mind mapping application written in Java. It provides extensive export capabilities.
"irfanview",`                          #A fast, compact and innovative graphic viewer (with PlugIns)
"opera-gx",`                           #Gaming counterpart of Opera web browser
"smartgit",`                           #A graphical Git client with support for SVN and Pull Requests for GitHub and Bitbucket.
"vscodium",`                           #Binary releases of VS Code without MS branding/telemetry/licensing.
"wiztree",`                            #A hard drive disk space analyser that finds the files and folders using the most space.
"dprint",`                             #Pluggable and configurable code formatting platform written in Rust.

| forEach-Object {
    Write-Host "Installing $_..."
    Scoop install $_
}


