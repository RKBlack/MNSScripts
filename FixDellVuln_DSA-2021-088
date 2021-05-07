# Query WMI and get a list of all user profile locations
$Profiles=(Get-WmiObject win32_userprofile).LocalPath

# Build a list of all possible locations
$FileList=@()
foreach ($profile in $profiles){
    $FileList +="$profile\AppData\Local\Temp\dbutil_2_3.sys"
}
$FileList += "$env:SystemRoot\Temp\dbutil_2_3.sys"

write-host "Checking the following locations:`n"
$Filelist

# Check each location and delete the file if found. Log the results to StdOut.
$FileFound=$false
$Errors=$false
foreach ($file in $FileList){
    if (test-path -PathType Leaf $file){
        $FileFound=$true
        write-host "`nFound file: $file"
        if ($PSVersionTable.PSVersion.Major -ge 4){
            Get-FileHash -Algorithm SHA256 $file
        }
        Remove-Item $file -Force
        start-sleep 1 # Wait a second to make sure the OS has had a chance to remove the file.
        if (test-path -PathType Leaf $file){
            write-host "`tWARNING: Unable to remove dbutil_2_3.sys"
            $Errors=$true
        }
        else {
            write-host "`tSuccessfully removed dbutil_2_3.sys"
        }
    }
}

if ($FileFound -eq $false){
    write-host "`ndbutil_2_3.sys was not found on this system."
}
if ($Errors -eq $true){
    exit 1
}
