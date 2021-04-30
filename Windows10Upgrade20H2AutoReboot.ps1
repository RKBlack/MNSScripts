#Download Windows 10 20H2 ISO from Microsoft and silently run the upgrade.
$SourceLink = 'https://bit.ly/3rZOupN'
$ISO = 'C:\kworking\Win10_20H2_English_x64.iso'
$ProgressPreference = 'SilentlyContinue'
Dismount-DiskImage -ImagePath $ISO -ErrorAction SilentlyContinue
Invoke-WebRequest $SourceLink -OutFile $ISO
$MountResult = Mount-DiskImage -ImagePath $ISO -PassThru
$driveLetter = (Get-DiskImage -ImagePath $ISO | Get-Volume).DriveLetter
$setupFile = $driveLetter + ':\setup.exe'
$runSetup = Start-Process -FilePath $setupFile -ArgumentList '/quiet /auto upgrade /SkipFinalize /copylogs C:\Temp\Logfiles /showoobe none' -PassThru
$runSetup.WaitForExit()
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name BurntToast -Force -Confirm:$false
Install-Module -Name RunAsUser -Force -Confirm:$false
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
$ProtocolHandler = get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
New-item 'HKCR:\ToastReboot' -force
set-itemproperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force
set-itemproperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force
new-itemproperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688
New-item 'HKCR:\ToastReboot\Shell\Open\command' -force
$finalCommand = Start-Process -FilePath $driveLetter + ':\setup.exe' -ArgumentList '/quiet /auto upgrade /Finalize /copylogs C:\Temp\Logfiles /showoobe none'
set-itemproperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value $finalCommand -force
}
Set-Content -Path c:\windows\temp\message.txt -Value $args
Invoke-AsCurrentUser -scriptblock {
$messagetext = Get-Content -Path c:\windows\temp\message.txt
$heroimage = New-BTImage -Source 'https://www.rkblack.com/images/brand-logo.png' -HeroImage
$Text1 = New-BTText -Content  "Message from R. K. Black IT"
$Text2 = New-BTText -Content "Your IT provider has installed updates on your computer at $(get-date). Please select if you'd like to reboot now, or snooze this message."
$Button = New-BTButton -Content "Snooze" -snooze -id 'SnoozeTime'
$Button2 = New-BTButton -Content "Reboot now" -Arguments "ToastReboot:" -ActivationType Protocol
$5Min = New-BTSelectionBoxItem -Id 5 -Content '5 minutes'
$10Min = New-BTSelectionBoxItem -Id 10 -Content '10 minutes'
$1Hour = New-BTSelectionBoxItem -Id 60 -Content '1 hour'
$4Hour = New-BTSelectionBoxItem -Id 240 -Content '4 hours'
$1Day = New-BTSelectionBoxItem -Id 1440 -Content '1 day'
$Items = $5Min, $10Min, $1Hour, $4Hour, $1Day
$SelectionBox = New-BTInput -Id 'SnoozeTime' -DefaultSelectionBoxItemId 10 -Items $Items
$action = New-BTAction -Buttons $Button, $Button2 -inputs $SelectionBox
$Binding = New-BTBinding -Children $text1, $text2 -HeroImage $heroimage
$Visual = New-BTVisual -BindingGeneric $Binding
$Content = New-BTContent -Visual $Visual -Actions $action
Submit-BTNotification -Content $Content
}
Remove-Item -Path c:\windows\temp\message.txt
