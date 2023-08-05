@echo off
rem Define the file name that contains the list of paths
set "FileName=%1"

rem Read the file content and split it by line
for /f "delims=" %%p in (%FileName%) do (
    rem Get all the files in the path and sort them by size
    for /f "delims=" %%f in ('dir /b /a-d /o-s "%%p\*"') do (
        rem Get the smallest file as the target
        if not defined target set "target=%%f"
        rem Get the current file and its name before moving
        set "file=%%f"
        set "oldName=%%~nxf"
        setlocal enabledelayedexpansion
        rem Move and rename the file to the target with force
        move /y "!file!" "!target!" >nul
        git add .
        rem Commit with a message containing the old name
        git commit -m "Moved and renamed !oldName! to !target!"
        endlocal
    )
    rem Reset the target for the next path
    set "target="
)
