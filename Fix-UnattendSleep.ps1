Write-Host "This script will disable the unatennded sleep profile.  Make sure you have found the reg key referenced in the ITG document"
Write-Host "Example for entry below: Computer\HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\Power\PowerSettings\238c9fa8-0aad-41ed-83f4-97be242c8f20\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0"
$partregkey = Read-Host "Enter the path from UnattendSleep reg key found in RegEdit"
$fullregkey = $partregkey.Replace("Computer\HKEY_LOCAL_MACHINE", "HKLM:") + "DefaultPowerSchemeValues"
Write-Host $fullregkey
Write-Host "Current Settings:"
Get-ChildItem -Path "$fullregkey" -Recurse | Get-ItemProperty | Select-Object PSChildName, ACSettingIndex, DCSettingIndex
Start-Sleep -Seconds 2
Get-ChildItem -Path "$fullregkey" -Recurse | Set-ItemProperty -Name ACSettingIndex -Value 0
Get-ChildItem -Path "$fullregkey" -Recurse | Set-ItemProperty -Name DCSettingIndex -Value 0
Start-Sleep -Seconds 2
Write-Host "New Settings:"
Get-ChildItem -Path "$fullregkey" -Recurse | Get-ItemProperty | Select-Object PSChildName, ACSettingIndex, DCSettingIndex
