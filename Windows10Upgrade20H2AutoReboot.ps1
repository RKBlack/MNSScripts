$SourceLink = 'https://software-download.microsoft.com/db/Win10_20H2_English_x64.iso?t=3c210902-33d5-448d-8f10-657cc6dd7c6b&e=1619607832&h=07117be41dbd38102093cfa1c62f48d7'
$ISO = 'C:\kworking\Win10_20H2_English_x64.iso'
$ProgressPreference = 'SilentlyContinue'
Dismount-DiskImage -ImagePath $ISO -ErrorAction SilentlyContinue
Invoke-WebRequest $SourceLink -OutFile $ISO
$MountResult = Mount-DiskImage -ImagePath $ISO -PassThru
$driveLetter = (Get-DiskImage -ImagePath $ISO | Get-Volume).DriveLetter
$setupFile = $driveLetter + ':\setup.exe'
Start-Process -FilePath $setupFile -ArgumentList '/quiet /auto upgrade /copylogs C:\Temp\Logfiles /showoobe none'
