@echo off
rem A script that moves and renames files in a list of paths to the smallest file in the list.

rem Define the file name that contains the list of paths
set "FileName=%1"

rem Check if the file name is provided and valid
if "%FileName%" == "" (
    echo No file name provided. Please provide a file name that contains a list of paths to files.
    exit /b 1
)
if not exist "%FileName%" (
    echo File name is invalid. Please provide a valid file name that exists and contains a list of paths to files.
    exit /b 2
)

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
        git mv "%%f" "%%~nxf"
        rem Commit with a message containing the old name
        git commit -m "Moved and renamed !oldName! to !target!"
        endlocal
    )
    rem Reset the target for the next path
    set "target="
)
