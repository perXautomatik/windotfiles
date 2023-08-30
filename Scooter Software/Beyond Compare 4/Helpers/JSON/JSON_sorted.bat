if "%PROCESSOR_ARCHITECTURE%"=="AMD64" then (
Helpers\Json\jq64.exe -S . < %1 > %2
) else (
Helpers\Json\jq.exe -S . < %1 > %2
)
