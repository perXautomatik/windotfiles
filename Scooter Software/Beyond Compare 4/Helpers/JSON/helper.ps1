Param(
[Parameter()] [path] [$input],
[Parameter()] [ParameterType] [$output])

cd 'D:\PortableApplauncher\Apps\.free\bCompare\Helpers\JSON'

 get-content $input | .\jq.exe '.' > $output

