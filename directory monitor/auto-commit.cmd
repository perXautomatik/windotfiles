@echo off
REM This cmd file takes the following parameters:
REM %dirpath%: The path to the directory where the file is located
REM %fullfile%: The full path to the file
REM %fulldir%: The full path to the directory
REM %file%: The name of the file
REM %dir%: The name of the directory
REM %size%: The size of the file in bytes
REM %oldfullfile%: The full path to the old version of the file (if applicable)
REM %user%: The user who triggered the event
REM %username%: The username of the user who triggered the event
REM %userprocess%: The process that triggered the event
REM %event%: The type of event that occurred (create, modify, delete, rename)
REM %date%: The date of the event
REM %time%: The time of the event

REM Change the current directory to the directory where the file is located
cd /d %1

REM Call git add on the file
git add %2

REM Call git commit with a message that includes the event and the file name
git commit -m "%3 %4; directory monitor triggered"
pause