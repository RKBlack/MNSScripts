$ShadowSnapPath = 'C:\Program Files (x86)\StorageCraft\ShadowProtect'
$TestShadowSnap = Test-Path $ShadowSnapPath
$SPUToolsUrl = 'https://www.dropbox.com/s/pz97de1yz1rlbp7/spuninstalltools.zip?dl=1'
$SPUToolsZip = 'C:\Temp\spuninstalltools.zip'
$SPUToolsPath = 'C:\Temp\SPU\'
$vssins64 = 'C:\Temp\SPU\64bit\vssins64.exe'
$stcinst = 'C:\Temp\SPU\64bit\stcinst.exe'
$vsnapvss = 'C:\Program Files (x86)\StorageCraft\ShadowProtect\vsnapvss.exe'
$ShadowProtectSvc = 'C:\Program Files (x86)\StorageCraft\ShadowProtect\ShadowProtectSvc.exe'

if ($TestShadowSnap -eq 'True') {
	#Download the tools and extract
	Invoke-WebRequest -Uri $SPUToolsURL -OutFile $SPUToolsZip -ErrorAction Continue
	Start-Sleep -Seconds 10
	Expand-Archive -LiteralPath $SPUToolsZip -DestinationPath $SPUToolsPath
	Start-Sleep -Seconds 10
}
if ($TestShadowSnap -eq 'True') {
	#Stop the ShadowSnap Services
	Stop-Service -Name 'vsnapvss'
	Stop-Service -Name 'ShadowProtectSvc'
	#Unregister VSSnap
	Start-Process -FilePath $vssins64 -ArgumentList '-u' -ErrorAction Continue
	Start-Sleep -Seconds 10
	Start-Process -FilePath $vsnapvss -ArgumentList '/unregister' -ErrorAction Continue
	Start-Sleep -Seconds 10
	Start-Process -FilePath $ShadowProtectSvc -ArgumentList '-UnregServer' -ErrorAction Continue
	Start-Sleep -Seconds 10
	regsvr32 /u sbimgmnt.dll
	Start-Sleep -Seconds 5
	New-ItemProperty -Path ​'HKLM:\SYSTEM\CurrentControlSet\services\sbmount' -Name 'DeleteFlag' -PropertyType 'DWord' -Value '1' -ErrorAction Continue
	Set-ItemProperty -Path ​'HKLM:\SYSTEM\CurrentControlSet\services\sbmount' -Name 'Start' -Value '4' -ErrorAction Continue
	Remove-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\Class\{0A2D3D86-E1F2-4165-AB5C-E636D32C0BDE}' -Recurse -ErrorAction Continue
	Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ShadowSnap' -Recurse -ErrorAction Continue
	Remove-Item 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ShadowProtect' -Recurse -ErrorAction Continue
	Remove-Item 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ShadowProtect' -Recurse -ErrorAction Continue
	Remove-Item 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ShadowSnap' -Recurse -ErrorAction Continue
	Start-Sleep -Seconds 10
	#Unregister SPS Driver
	Start-Process -FilePath $stcinst -ArgumentList '-u' -ErrorAction Continue
	Start-Sleep -Seconds 10
	Remove-Item -Path $ShadowSnapPath -Recurse
}
