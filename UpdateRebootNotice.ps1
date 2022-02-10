#Checking if ToastReboot:// protocol handler is present
New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT -erroraction silentlycontinue | out-null
$ProtocolHandler = get-item 'HKCR:\ToastReboot' -erroraction 'silentlycontinue'
if (!$ProtocolHandler) {
    #create handler for reboot
    New-item 'HKCR:\ToastReboot' -force
    Set-ItemProperty 'HKCR:\ToastReboot' -name '(DEFAULT)' -value 'url:ToastReboot' -force
    Set-ItemProperty 'HKCR:\ToastReboot' -name 'URL Protocol' -value '' -force
    New-ItemProperty -path 'HKCR:\ToastReboot' -propertytype dword -name 'EditFlags' -value 2162688
    New-item 'HKCR:\ToastReboot\Shell\Open\command' -force
    Set-ItemProperty 'HKCR:\ToastReboot\Shell\Open\command' -name '(DEFAULT)' -value 'C:\Windows\System32\shutdown.exe -r -t 00' -force
}

Install-Module -Name BurntToast -Force

$Text1 = New-BTText -Content  "Message from R. K. Black IT";
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
$Binding = New-BTBinding -Children $text1, $text2
$Visual = New-BTVisual -BindingGeneric $Binding
$Content = New-BTContent -Visual $Visual -Actions $action

Submit-BTNotification -Content $Content
