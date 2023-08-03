<#
.SYNOPSIS
Creates registry entries for different file extensions associated with 7-Zip.

.DESCRIPTION
Creates registry entries for different file extensions associated with 7-Zip using the specified installation path and excluding some file extensions.

.PARAMETER AppDir
The installation path of 7-Zip. It should be a valid folder path.

.PARAMETER ExcludeExt
An array of file extensions to exclude from the registry entries. It should be a subset of the supported file types by 7-Zip.

.OUTPUTS
None. The AppInstalled function does not return any output.

.EXAMPLE
AppInstalled -AppDir "C:\Program Files\7-Zip" -ExcludeExt @(".iso", ".vhd")

This example creates registry entries for 7-Zip installed in C:\Program Files\7-Zip and excludes the .iso and .vhd file extensions.
#>

function Create-Subkey ($Key) {
	New-Item $Key -Force | Out-Null
}

function Create-Item ($Key, $Name, $Value) {
	New-Item $Key -Force | Out-Null
	New-ItemProperty $Key -Name $Name -Value $Value -Force | Out-Null
}

function Create-SupportedTypes ($App) {
	New-Item "HKCU:\SOFTWARE\Classes\Applications\$App\SupportedTypes" -Force | Out-Null
}

function AppInstalled([String]$AppDir, $ExcludeExt = @()) {
    # Validate the parameters
    if (-not (Test-Path $AppDir -PathType Container)) {
		Write-Error "Invalid installation path: $AppDir"
		return
    }
    if ($ExcludeExt -notcontains $fileTypes.Keys) {
		Write-Error "Invalid file extensions to exclude: $ExcludeExt"
		return
    }

    # Define the CLSID of the 7-Zip shell extension
    $sevenZipCLSID = "{23170F69-40C1-278A-1000-000100020000}"

    # Define the file types and their associated icon indexes
    $fileTypes = @{
	"7z" = 0
	"zip" = 1
	"bz2" = 2
	"bzip2" = 2
	"tbz" = 2
	"tbz2" = 2
	"rar" = 3
	"arj" = 4
	"z" = 5
	"taz" = 5
	"lzh" = 6
	"lha" = 6
	"cab" = 7
	"iso" = 8
	"001" = 9
	"rpm" = 10
	"deb" = 11
	"cpio" = 12
	"tar" = 13
	"gz" = 14
	"tgz" = 14
	"gzip" = 14
	"tpz" = 14
	"wim" = 15
	"swm" = 15
	"lzma" = 16
	"dmg" = 17
	"hfs" = 18
	"xar" = 19
	"vhd" = 20
	"fat" = 21
	"ntfs" = 22
	"xz" = 23
	"txz" = 23
	"squashfs" = 24
    }

    # Create registry values for the general settings of 7-Zip
    Create-Item -Key 'HKEY_CURRENT_USER\Software\7-Zip' -Name 'LargePages' -Value '1' -Type DWORD
    Create-Item -Key 'HKEY_CURRENT_USER\Software\7-Zip\Options' -Name 'ContextMenu' -Value '-2147479177' -Type DWORD
    Create-Item -Key 'HKEY_CURRENT_USER\Software\7-Zip\Options' -Name 'MenuIcons' -Value '1' -Type DWORD
    Create-Item -Key 'HKEY_CURRENT_USER\Software\7-Zip\FM' -Name 'ShowDots' -Value '1' -Type DWORD
    Create-Item -Key 'HKEY_CURRENT_USER\Software\7-Zip\FM' -Name 'ShowRealFileIcons' -Value '1' -Type DWORD
    Create-Item -Key 'HKEY_CURRENT_USER\Software\7-Zip\FM' -Name 'ShowSystemMenu' -Value '1' -Type DWORD

    # Register the shell extension of 7-Zip
    EnsureShellExtensionRegistered -CLSID $sevenZipCLSID -Label '7-Zip Shell Extension' -DLL64Path "$AppDir\7-zip.dll" -DLL32Path "$AppDir\7-zip32.dll"

    # Create registry values for the context menu and drag and drop handlers of different items
    Create-Item -Key 'HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\7-Zip' -Name '' -Value "$sevenZipCLSID"
    Create-Item -Key 'HKEY_CLASSES_ROOT\Directory\shelex\ContextMenuHandlers\7-Zip' -Name '' -Value "$sevenZipCLSID"
    Create-Item -Key 'HKEY_CLASSES_ROOT\Directory\shellex\DragDropHandlers\7-Zip' -Name '' -Value "$sevenZipCLSID"
    Create-Item -Key 'HKEY_CLASSES_ROOT\Drive\shellex\DragDropHandlers\7-Zip' -Name '' -Value "$sevenZipCLSID"
    Create-Item -Key 'HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\7-Zip' -Name '' -Value "$sevenZipCLSID"
    Create-Item -Key 'HKEY_CLASSES_ROOT\Folder\shellex\DragDropHandlers\7-Zip' -Name '' -Value "$sevenZipCLSID"

    # Loop through each file extension and create the registry entries
    foreach ($ext in $fileTypes.Keys) {
	if ( $ExcludeExt.Contains($ext)) {
	    # Remove the file type and the file extension association if they are excluded
	    FileTypeUndefine -Type "7-Zip.$ext"
	    FileExtAssociate -Ext "$ext" -FileType $null -IfFileType "7-Zip.$ext"
	} else {
	    # Get the icon index of the file type
	    $iconIndex = $fileTypes[$ext]

	    # Define the file type and the file extension association
	    FileTypeDefine -Type "7-Zip.$ext" -Label "$ext Archive" -Command """$AppDir\7zFM.exe"" ""%1""" -Icon "$AppDir\7z.dll,$iconIndex"
	    FileExtAssociate -Ext "$ext" -FileType "7-Zip.$ext"
	}
    }
}


<#
.SYNOPSIS
Removes registry entries for different file extensions associated with 7-Zip.

.DESCRIPTION
Removes registry entries for different file extensions associated with 7-Zip and excludes some file extensions.

.PARAMETER ExcludeExt
An array of file extensions to exclude from the registry entries removal. It should be a subset of the supported file types by 7-Zip.

.OUTPUTS
None. The AppUninstalled function does not return any output.

.EXAMPLE
AppUninstalled -ExcludeExt @(".iso", ".vhd")

This example removes registry entries for 7-Zip and excludes the .iso and .vhd file extensions.
#>
function AppUninstalled($ExcludeExt = @())
{
    # Validate the parameter
    if ($ExcludeExt -notcontains $fileTypes.Keys) {
		Write-Error "Invalid file extensions to exclude: $ExcludeExt"
		return
    }

    # Define the CLSID of the 7-Zip shell extension
    $sevenZipCLSID = "{23170F69-40C1-278A-1000-000100020000}"

    # Define the file types and their associated icon indexes
    $fileTypes = @{
		"7z" = 0
		"zip" = 1
		"bz2" = 2
		"bzip2" = 2
		"tbz" = 2
		"tbz2" = 2
		"rar" = 3
		"arj" = 4
		"z" = 5
		"taz" = 5
		"lzh" = 6
		"lha" = 6
		"cab" = 7
		"iso" = 8
		"001" = 9
		"rpm" = 10
		"deb" = 11
		"cpio" = 12
		"tar" = 13
		"gz" = 14
		"tgz" = 14
		"gzip" = 14
		"tpz" = 14
		"wim" = 15
		"swm" = 15
		"lzma" = 16
		"dmg" = 17
		"hfs" = 18
		"xar" = 19
		"vhd" = 20
		"fat" = 21
		"ntfs" = 22
		"xz" = 23
		"txz" = 23
		"squashfs" = 24
    }

    # Remove registry values for the general settings of 7-Zip
    EnsureRegistryKeyDeleted -Path 'HKEY_CURRENT_USER\Software\7-Zip'

    # Unregister the shell extension of 7-Zip
    EnsureShellExtensionUnregistered -CLSID $sevenZipCLSID

    # Remove registry values for the context menu and drag and drop handlers of different items
    EnsureRegistryKeyDeleted -Path 'HKEY_CLASSES_ROOT\*\shellex\ContextMenuHandlers\'
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\shellex\ContextMenuHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Directory\shellex\DragDropHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Drive\shellex\DragDropHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Folder\shellex\ContextMenuHandlers\7-Zip"
    EnsureRegistryKeyDeleted -Path "HKEY_CLASSES_ROOT\Folder\shellex\DragDropHandlers\7-Zip"

    foreach ($ext in $fileTypes.Keys) {
	FileTypeUndefine -Type "7-Zip.$ext"
	FileExtAssociate -Ext "$ext" -FileType $null -IfFileType "7-Zip.$ext"
    }
}
