<#todo
fallback solutions
* if everything fails, 
    set got dir path to abbsolute value and edit work tree in place
* if comsumption fails, 
    due to modulefolder exsisting, revert move and trye to use exsisting folder instead, 
    if this ressults in error, re revert to initial 
        move inplace module to x prefixed
        atempt to consume again
* if no module is provided, utelyse everything to find possible folders
    use hamming distance like priorit order 
        where
        1. exact parrentmatch 
           rekative to root 
            order resukts by total exact 


        take first precedance
        2. predefined patterns taken
        and finaly sort rest by hamming
#>

[CmdletBinding()]
param (

    [Parameter(Mandatory=$true,
                HelpMessage=".git")] 
                [ValidateNotNullOrEmpty()]
    [string]$errorus,

    [Parameter(Mandatory=$true,    
                HelpMessage="subModuleRepoDir")] 
     #can be done with everything and menu
    [Parameter(Mandatory=$true,    
                HelpMessage="subModuleDirInsideGit")] 
                [ValidateNotNullOrEmpty()]
    [string]$toReplaceWith
)
$pastE = $error
$error.Clear()

Try {
    $null = Resolve-Path -Path $errorus -ErrorAction Stop    
    $null = Resolve-Path -Path $toReplaceWith -ErrorAction Stop    
    $null = Test-Path -Path $errorus -ErrorAction Stop    
    $null = Test-Path -Path $toReplaceWith -ErrorAction Stop
}
catch {
    ECHO "paths was unresolvable"
    echo $error
    exit
}

    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Stop"
     
    function git-root {
        $gitrootdir = (git rev-parse --show-toplevel)
        if ($gitrootdir) {
	    Set-Location $gitrootdir
        }
    }

    #---- move --- probably faile due to .git being a folder, and or module folder not exsiting, not critical

    #([System.IO.FileInfo]$errorus) | get-member

    
    echo '************************************************************'    
    
    echo "#---- asFile"
        $asFile = ([System.IO.Fileinfo]$errorus.trim('\'))
        $childy = [System.IO.Fileinfo] $asFile.FullName
    echo $asFile

    echo "#---- targetFolder"    
        $targetFolder = $asFile.Directory
    echo $targetFolder.ToString()

        $name = $targetFolder.Name
    echo $name.ToString()

        $parentY = ($asFile | Split-Path -Parent)
        $path = $targetFolder.Parent.FullName

    echo $path.ToString()

        $configFile = ($errorus + '\config')
    echo $configFile.ToString()

    echo "#---- target"
        $target = $targetFolder | Join-Path -ChildPath 'x.git'
echo "#---- asFile"
$parentY = ($asFile | Split-Path -Parent)
$childy = [System.IO.Fileinfo] (".\"+($asFile | Split-Path -leaf))
cd $parentY

    echo $target

    echo '************************************************************'
    
   # cd $parentY
            
    try{       
        $childy.MoveTo($target)
    }
    catch 
    {
        echo 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx failed xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        echo "xxxxx to move $childy"
        echo "xxxxx target $target"
    }
    try{
        $q = ($targetFolder | Join-Path -ChildPath '.git')
echo "#---- toReplaceWith"
$asFile = ([System.IO.FileInfo]$toReplaceWith)
echo "#---- target"
$target = $targetFolder | Join-Path -ChildPath '.git'
echo "#---- asFile"
        mv $toReplaceWith -Destination $q -Verbose -PassThru

        #([System.IO.FileInfo]$toReplaceWith).MoveTo(($targetFolder | Join-Path -ChildPath '.git')) 
    }
    catch {
        echo 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx failed to move xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        echo "xxxxx module dir $toReplaceWith"
        echo "xxxxx target $q"
        echo $Error

        exit
    }
    
    $path = $targetFolder.Parent.FullName
    $configFile = ($errorus + '\config')



    echo '************************************************************'
       
    echo $targetFolder.ToString()
    echo $name.ToString()
    echo $path.ToString()
        
    echo $configFile.ToString()

#--- remove worktree line
echo "#---- path"
$path = $errorus + '\config'
    # putting get-content in paranteses makes it run as a separate thread and doesn't lock the file further down the pipe
echo "#---- Get-Content"
    (Get-Content -Path $path | ? { ! ($_ -match 'worktree') }) | Set-Content -Path $path

# --- forget about files in path
echo "#---- Push-Location"
Push-Location
    cd $targetFolder
echo "#---- get-url"
    out-null -InputObject($ref = (git remote get-url origin) 2>1 ) 
    
    echo '************************** ref *****************************'           
    echo $ref.ToString()
    echo '************************** ref *****************************'
    if($ref)
    {
        if(!($ref.IndexOf('\') -gt 0))
        {
            $ref = $targetFolder
        }
    }
   else {
     $ref = $targetFolder
   }

echo "#---- name"
$name = $targetFolder.Name
echo "#---- path"
$path = $targetFolder.Parent.FullName

    echo '************************************************************'


        

    #---- move --- probably faile due to .git being a folder, and or module folder not exsiting, not critical

    #([System.IO.FileInfo]$errorus) | get-member
    
    try{       
       ([System.IO.FileInfo]$errorus).MoveTo(($targetFolder | Join-Path -ChildPath 'x.git')) 
    }
    catch 
    {
        echo $errorus
    }
    try{
        $q = ($targetFolder | Join-Path -ChildPath '.git')
        mv  $toReplaceWith -Destination $q -ErrorAction Stop
        #([System.IO.FileInfo]$toReplaceWith).MoveTo(($targetFolder | Join-Path -ChildPath '.git')) 
    }
    catch {
        echo 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx failed to move module dir xxxxxxxxxxxxxxxxxxxxxxxxxxxx'
        echo $toReplaceWith
        echo $q
    }
    
    #--- remove worktree line -- ! error, not critical, continue
        
        # putting get-content in paranteses makes it run as a separate thread and doesn't lock the file further down the pipe
        (Get-Content -Path $configFile | ? { ! ($_ -match 'worktree') }) | Set-Content -Path $configFile

    # --- forget about files in path, error if git already ignore path, not critical

    Push-Location
                cd $targetFolder     
                $ref = (git remote get-url origin)
    
    echo '************************** ref *****************************'           
    echo $ref.ToString()
    echo '************************** ref *****************************'
    cd $path
echo "#---- cached"
        git rm -r --cached $name 
echo "#---- commit"
        git commit -m "forgot about $name"

# --- Read submodule
echo "#---- path"
    echo '******************************* bout to read as submodule ****************************************' 
cd $path
    cd $path ; Git-root # (outside of ref)
echo "#---- git-root"
    $relative = ((Resolve-Path -Path $targetFolder.FullName -Relative) -replace([regex]::Escape('\'),'/')).Substring(2)
echo "#---- submodu"
Git submodule add $ref $relative
echo "#---- commit"
git commit -m "as submodule $relative"
echo "#---- absorbgitdirs"
Git submodule absorbgitdirs $relative
=======
    # --- Read submodule

    echo '******************************* bout to read as submodule ****************************************' 

    cd $path ; Git-root # (outside of ref)

    $relative = ((Resolve-Path -Path $targetFolder.FullName -Relative) -replace([regex]::Escape('\'),'/')).Substring(2)

    echo $relative
    echo $ref 
    echo '****************************** relative path ****************************************************'

    function AddNabsorb ([string]$ref, [string]$relative) {

        Git submodule add $ref $relative
        echo "#---- commit"
        git commit -m "as submodule $relative"
        echo "#---- absorbgitdirs"
        Git submodule absorbgitdirs $relative

    }

    AddNabsorb -ref $ref -relative $relative

    Pop-Location

    $ErrorActionPreference = $previousErrorAction
    $error = $pastE