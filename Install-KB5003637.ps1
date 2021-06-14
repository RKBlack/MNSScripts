$CabUrl = 'http://download.windowsupdate.com/d/msdownload/update/software/secu/2021/06/windows10.0-kb5003637-x64_54182e037903c3010ff0d56c4f8dbc951cd95a03.cab'
$CabFile = 'C:\kworking\windows10.0-kb5003637-x64_54182e037903c3010ff0d56c4f8dbc951cd95a03.cab'
$LogFile = 'C:\kworking\KB5003637.txt'
Invoke-WebRequest -Uri $CabUrl -OutFile $CabFile
Add-WindowsPackage -Online -PackagePath $CabFile -LogPath $LogFile -NoRestart
