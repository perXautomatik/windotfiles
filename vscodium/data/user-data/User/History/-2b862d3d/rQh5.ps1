(New-Object -ComObject Shell.Application).NameSpace("G:\\").Items() | 
    select @{
        n="OriginalLocation";
        e= { $_.ExtendedProperty("\ {9B174B33-40FF-11D2-A27E-00C04FC30871} 2\")
            }
    },Name


(new-object -ComObject shell.application).namespace("shell:History")

$x = 0x9
(new-object -ComObject shell.application).namespace($x).Items()
<#
typedef enum ShellSpecialFolderConstants {
  ssfDESKTOP = 0,
  ssfPROGRAMS = 0x2,
  ssfCONTROLS = 0x3,
  ssfPRINTERS = 0x4,
  ssfPERSONAL = 0x5,
  ssfFAVORITES = 0x6,
  ssfSTARTUP = 0x7,
  ssfRECENT = 0x8,
  ssfSENDTO = 0x9,
  ssfBITBUCKET = 0xa,
  ssfSTARTMENU = 0xb,
  ssfDESKTOPDIRECTORY = 0x10,
  ssfDRIVES = 0x11,
  ssfNETWORK = 0x12,
  ssfNETHOOD = 0x13,
  ssfFONTS = 0x14,
  ssfTEMPLATES = 0x15,
  ssfCOMMONSTARTMENU = 0x16,
  ssfCOMMONPROGRAMS = 0x17,
  ssfCOMMONSTARTUP = 0x18,
  ssfCOMMONDESKTOPDIR = 0x19,
  ssfAPPDATA = 0x1a,
  ssfPRINTHOOD = 0x1b,
  ssfLOCALAPPDATA = 0x1c,
  ssfALTSTARTUP = 0x1d,
  ssfCOMMONALTSTARTUP = 0x1e,
  ssfCOMMONFAVORITES = 0x1f,
  ssfINTERNETCACHE = 0x20,
  ssfCOOKIES = 0x21,
  ssfHISTORY = 0x22,
  ssfCOMMONAPPDATA = 0x23,
  ssfWINDOWS = 0x24,
  ssfSYSTEM = 0x25,
  ssfPROGRAMFILES = 0x26,
  ssfMYPICTURES = 0x27,
  ssfPROFILE = 0x28,
  ssfSYSTEMx86 = 0x29,
  ssfPROGRAMFILESx86 = 0x30
} ;
#>
<#
Value	Name	Description
0x00	ssfDESKTOP	Windows desktop—the virtual folder that is the root of the namespace.
0x02	ssfPROGRAMS	File system directory that contains the user’s program groups.
0x03	ssfCONTROLS	Virtual folder that contains icons for the Control Panel applications.
0x04	ssfPRINTERS	Virtual folder that contains installed printers.
0x05	ssfPERSONAL	File system directory that serves as a common repository for a user’s documents.
0x06	ssfFAVORITES	File system directory that serves as a common repository for the user’s favorite URLs.
0x07	ssfSTARTUP	File system directory that corresponds to the user’s Startup program group.
0x08	ssfRECENT	File system directory that contains the user’s most recently used documents.
0x09	ssfSENDTO	File system directory that contains Send To menu items.
0x0a	ssfBITBUCKET	Virtual folder that contains the objects in the user’s Recycle Bin.
0x0b	ssfSTARTMENU	File system directory that contains Start menu items.
0x10	ssfDESKTOPDIRECTORY	File system directory used to physically store file objects on the desktop.
0x11	ssfDRIVES	My Computer—the virtual folder that contains everything on the local computer: storage devices, printers, and Control Panel. The folder can also contain mapped network drives.
0x12	ssfNETWORK	Network Neighborhood—the virtual folder that represents the root of the network namespace hierarchy.
0x13	ssfNETHOOD	A file system folder that contains the link objects that may exist in the My Network Places virtual folder.
0x14	ssfFONTS	A virtual folder that contains fonts.
0x15	ssfTEMPLATES	File system directory that serves as a common repository for document templates.
0x16	ssfCOMMONSTARTMENU	File system directory that contains common Start menu items.
0x17	ssfCOMMONPROGRAMS	File system directory that contains common program groups for all users of a computer.
0x18	ssfCOMMONSTARTUP	File system directory that is used to physically store file objects on the desktop of all users of a computer. This folder is always empty unless someone puts something in it.
0x19	ssfCOMMONDESKTOPDIR	File system directory that contains files and folders that appear on the desktop of all users of a computer. This folder is always empty unless someone puts something in it.
0x1a	ssfAPPDATA	Version 4.71 and later: A file system directory that serves as a data repository for applications. A typical path is C:\Users\ username \AppData\Roaming. This CSIDL value is equivalent to CSIDL_APPDATA .
0x1b	ssfPRINTHOOD	Version 4.71 and later: A file system directory that contains the link objects that can exist in the Printers virtual folder. A typical path is C:\Users\ username \AppData\Roaming\Microsoft\Windows\Printer Shortcuts . This CSIDL value is equivalent to CSIDL_PRINTHOOD .
0x1c	ssfLOCALAPPDATA	Version 5.0 and later: A file system directory that serves as a data repository for local (nonroaming) applications. A typical path is C:\Users\ username \AppData\Local . This CSIDL value is equivalent to CSIDL_LOCAL_APPDATA .
0x1d	ssfALTSTARTUP	
#>

# Synopsis: Get a list of files in a given path, relative to that path
function Get-RelativeFileList {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    # Get all the files in the path recursively
    $files = Get-ChildItem -Path $Path -File -Recurse
    # For each file, get its relative path by removing the base path
    $relativeFiles = $files | ForEach-Object {
        $_.FullName.Replace($Path,'')
    }
    # Return the relative file list
    return $relativeFiles
}

# Synopsis: Move a file in one path to match the relative path of another file in a different path
function Move-FileToMatchRelativePath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SourceFile,
        [Parameter(Mandatory=$true)]
        [string]$SourcePath,
        [Parameter(Mandatory=$true)]
        [string]$TargetFile,
        [Parameter(Mandatory=$true)]
        [string]$TargetPath
    )
    # Get the relative path of the source file by removing the source path
    $sourceRelativePath = $SourceFile.Replace($SourcePath,'')
    # Get the destination path by joining the target path and the source relative path
    $destinationPath = Join-Path -Path $TargetPath -ChildPath $sourceRelativePath
    # Create the destination directory if it does not exist
    $destinationDirectory = Split-Path -Path $destinationPath -Parent
    if (-not (Test-Path -Path $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
    }
    # Move the file to the destination path, overwriting if it exists
    Move-Item -Path $SourceFile -Destination $destinationPath -Force
}

# Synopsis: Given two paths, A and B, move files in B to match the relative paths of files in A with the same name
function Sync-FilesByRelativePath {
    param (
        [Parameter(Mandatory=$true)]
        [string]$A,
        [Parameter(Mandatory=$true)]
        [string]$B
    )
    # Get the relative file lists for both paths
    $AFiles = Get-RelativeFileList -Path $A
    $BFiles = Get-RelativeFileList -Path $B
    # For each file in B, check if there is a file with the same name in A
    foreach ($BFile in $BFiles) {
        # Get the file name by splitting the relative path
        $BFileName = Split-Path -Path $BFile -Leaf
        # Find a file in A with the same name, if any
        $AFile = $AFiles | Where-Object {$_ -like "*$BFileName"}
        # If there is a matching file in A, and its relative path is different from B, move the file in B to match A's relative path
        if ($AFile -and ($AFile -ne $BFile)) {
            Move-FileToMatchRelativePath -SourceFile (Join-Path -Path $B -ChildPath $BFile) `
                                         -SourcePath $B `
                                         -TargetFile (Join-Path -Path $A -ChildPath $AFile) `
                                         -TargetPath $A
        }
    }
}
