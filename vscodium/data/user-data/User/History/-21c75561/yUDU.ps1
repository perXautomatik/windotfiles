
Write-Host 'Installing and configuring Scoop manifests...'
. "$PSScriptRoot\Utils.ps1"


'gitextensions', `
'git-filter-repo', `
'git-interactive-rebase-tool', `
'gitomatic', `
'git-sizer', `
'rclone-browser', 'sagemath','steam-library-manager',
'vscodium'
'lockhunter','nirlauncher',`

#System
"7zip",`                               #A multi-format file archiver with high compression ratios
"dotnet-sdk",`                         #.NET is a free, cross-platform, open source developer platform for building many different types of applications.
"everything-cli",`                     #Command line interface to Everything.

#Enable contextMenue
"hardlinkshellext",`                   #Hard link shell extension

#CommandLineTools
"echoargs",`                           #Very simple little console class that you can use to see how PowerShell is passing parameters to legacy console apps.
"find-java",`                          #PowerShell script to locate Java on Windows, optionally sets JAVA_HOME and JRE_HOME
"htmlq",`                              #Like jq, but for HTML. (Uses CSS selectors to extract bits of content from HTML files)
    #json
"gron",`                               #Transform JSON into discrete assignments to make it easier to grep and see the absolute 'path'.
"jd",`                                 #jd is a commandline utility and Go library for diffing and patching JSON values.
    #
"lazy-posh-git",`                      #PowerShell proxy command around Set-Location to defer import of posh-git module until one changes working directory to the root of a git directory.


#With Presistent
"advancedrenamer",`                    #Batch file renaming utility for Windows
"autohotkey",`                         #The ultimate automation scripting language for Windows.
"beyondcompare",`                      #Directory and file compare functions in one package
"cherrytree",`                         #Hierarchical note taking application, featuring rich text and syntax highlighting.
"ditto",`                              #An enhanced clipboard manager
"everything",`                         #Locate files and folders by name instantly.
"freefilesync",`                       #A folder comparison and synchronization software.
"freemind",`                           #FreeMind is a free mind mapping application written in Java. It provides extensive export capabilities.
"irfanview",`                          #A fast, compact and innovative graphic viewer (with PlugIns)


#every now and then
"antidupl.net",`                       #Image duplicate finder
"bfg",`                                #BFG Repo-Cleaner removes large or troublesome blobs like git-filter-branch does, but faster
"busybox",`                            #BusyBox is a single binary that contains many common Unix tools
#screen OCR
'Text Grab'
#    "capture2text",`                       #OCR capture utility
"context-menu-manager",`               #A program to manage the Windows right-click context menu.
"ContextMenuManager",`                 #一个纯粹的Windows右键菜单管理程序.
"coretemp",`                           #Monitor processor temperature and other vital information.
"crystaldiskinfo",`                    #HDD/SSD utility software which supports S.M.A.R.T and a part of USB-HDD
"czkawka-gui",`                        #Find duplicates, empty folders, similar images, unnecessary files, etc.
"datagrip",`                           #Cross-Platform IDE for Databases & SQL by JetBrains.
"deepgit",`                            #Git Archaeology Tool.

"discord",`                            #Free Voice and Text Chat
"dxwnd",`                              #Window hooker to run fullscreen programs in window and much more.
"gephi",`                              #Visualization and exploration software for all kinds of graphs and networks
"fancontrol",`                         #A highly customizable fan controlling software for the Windows OS.
"gimp",`                               #GNU Image Manipulation Program
"gitextensions",`                      #A graphical user interface for Git that allows you to control Git without using the commandline.
"glary-utilities",`                    #All-in-one utility for cleaning your PC
"glaryutilities",`                     #Powerful and all-in-one utility for cleaning your PC.
"graphviz",`                           #Open source graph visualization software.
"knime",`                              #KNIME Analytics Platform. Software for creating data science applications and services. Intuitive, open, and continuously integrating new developments, KNIME makes understanding data and design...
"koodoreader",`                        #A modern ebook manager and reader with sync and backup capacities
"lepton",`                             #A lean code snippet manager based on GitHub Gist
"lively",`                             #A free and open-source software that allows users to set animated desktop wallpapers and screensavers.
"lockhunter",`                         #Delete files blocked by something you do not know.
"macrocreator",`                       #Automation tool and script generator based on AutoHotkey language


#experimental
"act",`                                #Local Github actions runner.
"actionlint",`                         #Static checker for GitHub Actions workflow files
"ag",`                                 #A tool for searching code. Fork of The Silver Searcher; dedicated to building a well behaved version for Windows.
"audioswitcher",`                      #Makes switching between sound devices trivial. No longer do you have to go into Control Panel or the Windows® Sound options, instead there is an easy to access icon, or even hotkeys.
"android-messages",`                   #Cross-platform Desktop App for android messages.
    #snippet management tool.
"beeftext",`                           #An open-source text substitution/
#    "cacher",`                             #Code snippet organizer for pro developers
"bugn",`                               #Tiling window manager add-on for the Explorer shell of Microsoft Windows
"byenow",`                             #Utility for folder removal
"cheat",`                              #Create and view interactive cheatsheets on the command-line
"chezmoi",`                            #Manage your dotfiles across multiple diverse machines, securely.
"chuck",`                              #Strongly-timed, Concurrent, and On-the-fly Music Programming Language.
"cmdow",`                              #Win32 console application for manipulating program windows.
"code-minimap",`                       #A high performance code minimap render
"codeowners-validator",`               #The GitHub Codeowners file validator
"compactgui",`                         #CompactGUI is a standalone user interface that makes the Windows 10 compact.exe function easier to use.
"compactor",`                          #A user interface for Windows 10 filesystem compression
"concfg",`                             #Import/export Windows console settings
"conftest",`                           #Test utility for structured configuration files
"csview",`                             #A high performance csv viewer with cjk/emoji support
"cuda",`                               #A parallel computing platform and programming model invented by NVIDIA
"d2",`                                 #A modern diagram scripting language that turns text to diagrams.
"dbmate",`                             #A lightweight, framework-agnostic database migration tool
"depends",`                            #A free utility that scans any 32-bit or 64-bit Windows module (exe, dll, ocx, sys, etc.) and builds a hierarchical tree diagram of all dependent modules.
"deskreen",`                           #Turn any device into a secondary screen for your computer.
"desktop-ini-editor",`                 #A simple app that allows users to edit the desktop.ini file in thier folders.

"direnv",`                             #load or unload environment variables depending on the current directory

    #sourcCodeExplore
"cscope",`                             #Developer's tool for browsing source code.
"ctags",`                              #Generates an index (or tag) file of language objects found in source files
"ctypes",`                             #A file type manager for Windows that allows you to edit program associations, icons, context menus and a few other things.

    #json
"dadroitjsonviewer",`                  #A JSON viewer that gives a new approach to process JSON Data files.
"dasel",`                              #DAta-SELector. Command line utility for querying and modifying data structures inside JSON, TOML, YAML, ...

    #diff tools
"delta",`                              #A syntax-highlighter for git and diff output
"diffsitter",`                         #A tree-sitter based AST difftool to get meaningful semantic diffs
"difftastic",`                         #A structural diff that understands syntax
"dirhash",`                            #DirHash is a Windows console program that computes the hash of a given directory content or a single file
"dolt",`                               #Dolt is a SQL database that you can fork, clone, branch, merge, push and pull just like a git repository.
"dotter",`                             #Dotfile manager and templater
"dprint",`                             #Pluggable and configurable code formatting platform written in Rust.
"drive-letter-changer",`               #A simple app that allows you to change the letter of your hard drives.
"driverstoreexplorer",`                #A GUI tool to manage Windows driver store
"dual-monitor-tools",`                 #Set of utilities for managing multiple monitor setups.
"dualmonitortaskbar",`                 #A taskbar for the second monitor
"easy-context-menu",`                  #A simple app for editing the context menu.
"easyserviceoptimizer",`               #A portable freeware to optimize services for almost all Windows versions (except for Win 98 and before).
"edgedb",`                             #A graph-relational database
"editorconfig",`                       #Maintain consistent coding styles for multiple developers working on the same project across various editors and IDEs.
    #LargeFile
"emeditor",`                           #A fast, lightweight and extensible text editor for Windows. Useful for opening very large files.

"emplace",`                            #Synchronizes installed packages on multiple machines.
    #env Variable
"envsubst",`                           #Environment variables substitution

"exe-explorer",`                       #Executable File Explorer for OS/2, NE, PE32, PE32+ and VxD file types
    #regex
"expresso",`                           #Editor equally suitable as a teaching tool for the beginning user of regular expressions or as a full-featured development environment for the experienced programmer or web designer with an ext...

    #fileType
"file",`                               #Determine file type.

"flow-launcher",`                      #Quick file searcher and app launcher with community-made plugins
    #database migration
"flyway",`                             #Database migration tool that favors simplicity and convention over configuration.

"folder-marker",`                      #A tool to label folders with color-coded / image-coded icon
"forcebindip",`                        #Bind any Windows application to a specific interface or IP address.

    #Logic designer
"digital",`                            #A digital logic designer and circuit simulator
"freemove",`                           #Moves directories freely without breaking installations or shortcuts.
"gammy",`                              #Adaptive screen brightness tool
"gcfscape",`                           #An archive viewer and extractor for BSP, GCF, NCF, PAK, SGA, VPK, WAD, and XZP files

    #gitIgnore
"gibo",`                               #gibo (short for .gitignore boilerplates) is a shell script to help you easily access .gitignore boilerplates from github.com/github/gitignore.

    #Wim
"gimagex",`                            #A free GUI tool for working with WIM files.
    #git
"git-filter-repo",`                    #git filter-branch replacement
"git-interactive-rebase-tool",`        #An improved sequence editor for Git
"git-sizer",`                          #Compute various size metrics for a Git repository, flagging those that might cause problems.
"gitomatic",`                          #A tool to monitor git repositories and automatically pull & push changes.
"gitversion",`                         #Easy Semantic Versioning for projects using Git.
"gource",`                             #OpenGL-based 3D visualisation tool for source control repositories.
    #regex
"grex",`                               #A regular expression generator

    #system restore
"hekasoft-backup-restore",`            #Hekasoft Backup and Restore is a free tool to backup and restores your browser settings. It allows you to migrate your profile from one browser to another and even custom your profile by removi...

    #largeFiles
"hex-editor-neo",`                     #Binary file editor optimized for large files
"hexyl",`                              #Hex viewer, which uses colored output to distinguish different categories of bytes.

    #git ignore
"ignoreit",`                           #Quickly load .gitignore templates

    #management
"imdone",`                             #Simple and powerful kanban board built on top of plain text markdown files or code.
"infoqube",`                           #information management system
"joplin",`                             #A note taking and to-do application with synchronization capabilities

    #window tiling
"komorebi",`                           #A tiling window manager for Windows

#management
"logseq",`                             #A privacy-first platform for knowledge sharing and management
"manictime",`                          #A time tracking software

# piping
"logstash",`                           #A data processing pipeline that ingests data from a multitude of sources simultaneously, transforms it, and then sends it to your favorite "stash".

#snippet
"masscode",`                           #A free and open source code snippets manager for developers

#windows manager
"maxto",`                              #A window manager to divide your screen, increase your productivity.

#wim
"mediacreationtool",`                  #Create your own Windows 10 installation media using either a USB flash drive or a DVD

#fileSystem
"metastore",`                          #Store and restore metadata from a filesystem

#git
"metrogit",`                           #Git visualization tool that's more than just git.
"lazygit",`                            #A simple terminal UI for git commands

#json
"miller",`                             #Like awk, sed, cut, join, and sort for data formats such as CSV, TSV, JSON, JSON Lines, and positionally-indexed.



#futhuer experiments
"apache-directory-studio",`            #LDAP browser and directory client
"alpinewsl",`                          #Install AlpineWSL as a WSL Instance
"ascii-image-converter",`              #A cross-platform command-line tool to convert images into ascii art and print them on the console. Now supports braille art!

"bat2exe",`                            #A simple application which converts any windows batch file to a fully working executable .exe with an icon of your choice.
"batcodecheck",`                       #Batch file (.bat) linter
"battery-care",`                       #Tool to optimize the usage and performance of the modern laptop's battery.
"bioedit",`                            #Biological sequence alignment editor.

"cairo-desktop",`                      #Alternative desktop environment for Windows
"camo-studio",`                        #Use your phone as a webcam
"camunda-modeler",`                    #Made for developers, edit your BPMN process diagrams and DMN decision tables.
"carvel-vendir",`                      #Carvel vendir is a tool that makes it easy to vendor portions of git repos, github releases, helm charts, docker image contents, etc. declaratively
"castle-view-image",`                  #Image viewer and converter using Castle Game Engine, supporting common image formats (PNG, JPG...) and some exotic ones (DDS, KTX, RGBE)
"centertaskbar",`                      #Centers Windows taskbar icons.
"clickcharts",`                        #Versatile Diagram Drawing and Editing software.
"cue",`                                #CUE is an open source data constraint language which aims to simplify tasks involving defining and using data.
"dataspell",`                          #Cross-Platform IDE for Data Scientists by JetBrains.
"DbxCli",`                             #Dropbox command line interface
"dd",`                                 #Allows the flexible copying of data in a win32 environment
"digdag",`                             #A simple, open source, multi-cloud workflow engine that helps you to build, run, schedule, and monitor complex pipelines of tasks
"dive",`                               #A tool for exploring each layer in a docker image.
"electronics-assistant",`              #An electronics helper that offers resistor colour codes, capacitance and power calculations.
"falcon-sql-client",`                  #SQL client with inline data visualization
"gink",`                               #On-screen annotation software inspired by Epic Pen
"google-java-format",`                 #Reformats Java source code to comply with Google Java Style.
"islc",`                               #Utility that will monitor and clear the memory standby list when it is > 1000mb (1gb).

"lili",`                               #LiLi creates portable, bootable and virtualized USB stick running Linux.

"mindforger",`                         #Personal knowledge manager
"MongoDB",`                            #A document database with the scalability and flexibility.
"mp3tag",`                             #Powerful and easy-to-use tool to edit metadata of audio files.
"multrin",`                            #Organize multiple apps in tabs!
"nanazip",`                            #The 7-Zip derivative intended for the modern Windows experience
"Nativefier",`                         #
"ndm",`                                #A Open Source npm desktop GUI.
"nefcon",`                             #Windows device driver installation and management tool
"ngspice",`                            #SPICE simulator for electric and electronic circuits
"nilesoft-shell",`                     #A context menu extender that lets you handpick the items to integrate into Windows File Explorer context menu.
"nimbleset",`                          #Simple tool for quickly comparing lists.
"nimbletext",`                         #Text manipulation and code generation tool
"nirlauncher",`                        #More than 200 portable freeware utilities for Windows, all of them developed for NirSoft Web site during the last few years
"nodejs-lts",`                         #As an asynchronous event driven JavaScript runtime, Node is designed to build scalable network applications. (Long Term Support)
"notepad2-zufuliu",`                   #Fork of Notepad2, a light-weight Scintilla-based text editor. Featuring syntax highlighting, code folding, auto-completion and API list for about 80 programming languages/documents.
"npiperelay",`                         #npiperelay allows you to access Windows named pipes from WSL
"nuget-package-explorer",`             #GUI tool for creating, updating, and deploying NuGet packages
"obsidian",`                           #Powerful knowledge base that works on top of a local folder of plain text Markdown files.
"office-365-custom",`                  #Family of client software, server software and services developed by Microsoft. This package includes custom config file.
"ontopreplica",`                       #A real-time always-on-top “replica” of a window
"openboard",`                          #Interactive whiteboard for schools and universities
"openresty",`                          #
"opentrack",`                          #Tracks user's head movements and relaying the information to games and flight simulation software.
"opera-gx",`                           #Gaming counterpart of Opera web browser
"OSBasePackages",`                     #
"outlook-google-calendar-sync",`       #Sync your Outlook and Google calendars.
"paperwork",`                          #Personal document manager
"patchcleaner",`                       #Cleans your windows Installer directory of orphaned and redundant installation (.msi) and patch (.msp) files
"patheditor",`                         #A convenient GUI for editing the PATH environment variable
"pester",`                             #Pester is a test and mock framework for PowerShell.
"phraseexpress",`                      #Autotext and Text Autocompletion in any application.
"pip-tool",`                           #Use the Picture in Picture mode on Windows.
"plantuml",`                           #A tool to draw UML diagrams, using a simple and human readable text description.
"pnpm",`                               #A fast and disk space efficient Node package manager.
"pocketsphinx",`                       #Lightweight speech recognition engine, specifically tuned for handheld and mobile devices.
"posh-git",`                           #A PowerShell module which provides Git/PowerShell integration.
"PowerShell-pre",`                     # PowerShell Core is a cross-platform (Windows, Linux, and macOS) automation and configuration tool/framework that works well with your existing tools and is optimized for dealing with structure...
"PowerShell",`                         # PowerShell Core is a cross-platform (Windows, Linux, and macOS) automation and configuration tool/framework that works well with your existing tools and is optimized for dealing with structure...
"PowerShellCore",`                     #
"PowerShellCorePreview",`              #
"PowerShellWindows",`                  #
"powertab",`                           #Tab expansion module for PowerShell. Handles more content and provides a new, optional interface.
"powertoys",`                          #A set of utilities for power users to tune and streamline their Windows experience for greater productivity.
"propertree",`                         #Cross platform GUI plist editor written in python.
"proxifier",`                          #Allows network applications that do not support working through proxy servers to operate through a SOCKS or HTTPS proxy and chains.
"pscolor",`                            #Provides color highlighting for some basic PowerShell output.
"pseps",`                              #Templating tool for PowerShell
"pspad",`                              #A text editor for developers
"psreadline",`                         #A bash inspired readline implementation for PowerShell
"pwsh",`                               #Cross-platform automation and configuration tool/framework, known as Powershell Core, that works well with existing tools and is optimized for dealing with structured data.
"pycharm",`                            #Cross-Platform IDE for Python by JetBrains (Community edition).
"pyenv",`                              #Simple python version management tool for switching between multiple versions of Python.
"python",`                             #A programming language that lets you work quickly and integrate systems more effectively.
"quicklook",`                          #Bring macOS 'Quick Look' feature to Windows
"quicktextpaste",`                     #Insert pre-defined text in any Windows applications via keyboard shortcut.
"rainmeter",`                          #A desktop customization tool
"rapidee",`                            #Environment variables editor.
"rbtray",`                             #Background program making any application minimizable to the system tray by right-clicking its Minimize button
"rclone-browser",`                     #A simple rclone GUI
"rednotebook",`                        #Graphical diary and journal
"registry-finder",`                    #Registry Finder is an improved replacement for the built-in Windows registry editor
"reicon",`                             #A simple app that allows users to backup and restore their Desktop Icon layout.
"rktools2k3",`                         #Streamline manage administrator tasks. (troubleshooting OS, manage AD, deploy applications, ...)
"runastool",`                          #A simple app that allows users to run a specific program with administrator privileges without the need to enter the administrator password.
"rustup",`                             #Manage multiple rust installations with ease
"sagemath",`                           #Mathematics software system
"sapling",`                            #Sapling SCM is a cross-platform, highly scalable, Git-compatible source control system.
"scantailor-advanced",`                #Interactive post-processing tool for scanned pages
"schema",`                             #
"schismtracker",`                      #An oldschool sample-based music composition tool
"scoop-completion",`                   #A Scoop tab completion module for PowerShell
"scoop-sd",`                           #A program to search for scoop packages. Powered by https://scoopsearch.github.io/
"ScoopInstalled",`                     #
"scopy",`                              #A software oscilloscope and signal analysis toolset
"screenoff",`                          #Turn off Windows laptop monitor screen in a click, without putting it to Sleep.
"search-deflector",`                   #A small program that forwards searches from Cortana to your preferred browser and search engine
"sendto-menu-editor",`                 #A simple app that helps users manage the shortcuts present in the Windows “Send To” Menu.
"SetPowerConfiguration",`              #
"shawl",`                              #Windows service wrapper for arbitrary commands
"shutter",`                            #A multifunctional scheduling utility, which has a user friendly, easy-to-use interface and supports many different Events and Actions.
"sidebar-diagnostics",`                #A simple sidebar that displays hardware diagnostic information.
"silentcmd",`                          #Executes a batch file without opening the command prompt window.
"siyuan-note",`                        #SiYuan is a local-first personal knowledge management system, supports fine-grained block-level reference, and Markdown WYSIWYG.
"sleek",`                              #Open-source (FOSS) todo manager based on the todo.txt syntax
"smartgit",`                           #A graphical Git client with support for SVN and Pull Requests for GitHub and Bitbucket.
"smartsystemmenu",`                    #A tool extends system menu of all windows in the system.
"smarttaskbar",`                       #Automatically switch the display state of the Windows Taskbar
"smplayer",`                           #A free media player with built-in codecs.
"snaketail",`                          #A Windows tail utility for monitoring growing text log files.
"snappy-driver-installer-origin",`     #Device drivers installer and updater
"snoop",`                              #Spy/browse the visual tree of a running application (without the need for a debugger) and change properties, view triggers, set breakpoints on property changes and more.
"sophiapp",`                           #An open-source app for configuring and fine-tuning Windows 10 & Windows 11.
"soundswitch",`                        #Switch your default playback devices and/or recording devices using simple hotkeys
"spicetify-cli",`                      #Tool for customizing the Spotify client.
"spotify",`                            #A digital music service that gives you access to millions of songs.
"spotube",`                            #A lightweight free Spotify client, which handles playback manually, streams music using Youtube & no Spotify premium account is needed.
"sqlitebrowser",`                      #DB Browser for SQLite (DB4S) project
"squashfs-tools",`                     #Mounts SquashFS archives in user-space.
"static-web-server",`                  #A blazing fast and asynchronous web server for static files-serving
"steam-library-manager",`              #An utility to manage your Steam and Origin libraries in ease of use with multi library support.
"strokesplus",`                        #Mouse gesture recognition utility for Windows which allows you to create powerful mouse gestures that save you time.
"sublime-merge",`                      #A Git client with snappy UI, three-way merge tool, side-by-side diffs, syntax highlighting, and more.
"sumatrapdf",`                         #PDF and eBook reader
"super-productivity",`                 #To-do list & time tracker for programmers and other digital workers with Jira, Github, and Gitlab integration
"superf4",`                            #Force quit apps by pressing Ctrl-Alt-F4
"sweethome3d",`                        #A free interior design application that helps you draw the plan of your house, arrange furniture on it and visit the results in 3D.
"swipl",`                              #Comprehensive free Prolog environment.
"switcheroo",`                         #The humble incremental-search task switcher for Windows
"sysinternals",`                       #A set of utilities to manage, diagnose, troubleshoot, and monitor a Windows environment.
"tabula",`                             #A tool for liberating data tables trapped inside PDF files.
"task-coach",`                         #Todo list manager
"terminal-icons",`                     #A PowerShell module to show file and folder icons in the terminal
"tesseract",`                          #Open Source OCR Engine
"text-grab",`                          #Minimal Windows utility for copying and pasting any visible text, without internet access.
"texteditoranywhere",`                 #Text Editor Anywhere allows you to use your favourite text editor anywhere you can enter text.
"thebrain",`                           #power of digital thought
"thonny",`                             #Python IDE for beginners
"tileiconifier",`                      #Creates tiles for most Windows 8.1 and 10 start menu icons.
"timeseriesadmin",`                    #Administration panel and querying interface for InfluxDB databases
"tinytask",`                           #Windows automation app for recording and repeating actions.
"todotxt-net",`                        #Implementation of todo.txt for Windows using the .NET framework
"typora",`                             #Typora — a minimal markdown editor, markdown reader.
"umbrello",`                           #UML (Unified Modelling Language) diagram program based on KDE Technology
"universal-ctags",`                    #Generates an index (or tag) file of language objects found in source files for many popular programming languages.
"UnverifiedChoco",`
"ussf",`                               #A compact utility designed to help you find the silent switch in the applications that you want to install.
"vcredist-aio",`                       #All-in-one repack for latest Microsoft Visual C++ Redistributable Runtimes, without the original setup bloat payload.
"virtualhere-client",`                 #Allows USB devices to be used remotely over a network just as if they were locally connected (server-side app)
"virtualhere-server",`                 #Allows USB devices to be used remotely over a network just as if they were locally connected (server-side app)
"vitrite",`                            #Configures the level of transparency for almost any visible window.
"volta",`                              #Volta is a hassle-free way to manage your JavaScript command-line tools
"vott",`                               #End to end Object Detection Models builder from Images and Videos
"VSCode-Nightly",`                     #Visual Studio Code is a lightweight but powerful source code editor (Insiders, Portable Edition).
"vscodium",`                           #Binary releases of VS Code without MS branding/telemetry/licensing.
"w10privacy",`                         #Adjust Windows according to your preferences to improve the performance and privacy of the OS.
"waifu2x-extension-gui",`              #Video, Image and GIF upscale/enlarge(Super-Resolution) and Video frame interpolation. Achieved with Waifu2x, Real-ESRGAN, Real-CUGAN, SRMD, RealSR, Anime4K, RIFE, CAIN, DAIN, and ACNet.
"watchman",`                           #
"weebp",`                              #A wallpaper engine, set any window as your wallpaper.
"winaero-tweaker",`                    #Tweaks and hidden settings for power-users for Windows 7/8/8.1/10/11
"WindowsPowerShell",`                  #
"windowtextextractor",`                #A tool allows you to get a text from any window of an operating system including asterisk passwords.
"wingetui",`                           #A GUI to manage Winget and Scoop packages
"winmerge2011",`                       #A fork of WinMerge, an open source differencing and merging tool
"winpython",`                          #Free, open-source and portable Python distribution for Windows
"wiztree",`                            #A hard drive disk space analyser that finds the files and folders using the most space.
"workspacer",`                         #A tiling window manager for Windows 10
"workspaceutilities",`                 #Provides hotkey access to custom window sizes and layouts
"wslgit",`                             #A small executable that forwards all arguments to git running inside Bash on Windows/Windows Subsystem for Linux (WSL)
"wxMEdit",`                            #A Cross-platform Text/Hex editor.
"xkill",`                              #Display a special cursor as a prompt for the user to select a window to be killed.
"xmlnotepad",`                         #Provides a simple intuitive User Interface for browsing and editing XML documents
"youtube-dl-gui",`                     #A cross platform front-end GUI of the popular youtube-dl written in wxPython.
"zeal",`                               #An offline documentation browser for software developers



ForEach-Object {
    Write-Host "Installing $_..."
    Scoop install $_
}


