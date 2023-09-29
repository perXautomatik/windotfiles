param ($source,$target,$original)


    (Get-Content $source) >> $original

 try {
 (Get-Content $source) | .\jq.exe '.' | out-file -FilePath $target
    }
catch { }


