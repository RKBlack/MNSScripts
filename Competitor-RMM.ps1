##########RMM Agent Detector v0.0.0.0.0.1 #################
$ApplicationList = @(
    "*Kaseya*"
    "*Datto*"
    "*Solarwinds*"
    "*Ninja*"
    "*GFI*"
    "*Atera*"
    "*Connectwise*"
    "*Continuum*"
    "*ScreenConnect*"
    "*Webroot*"
    "*Sure Sense*"
    "*Syncro*"
    "*Sophos Endpoint*"
)


if (Test-Path "c:\Windows\ltsvr"){
    # Rmm-Alert -Category "Monitoring" -Body "Labtech service"
     $outp = Write-Output "Labtech service"
     $outp.substring(0, [System.Math]::Min(12, $s.Length)) | Out-File -FilePath C:\kworking\OtherRMM.txt -Encoding ascii -NoNewline
     $founderror = 1
    }
else {}
    

$CompetitorRMM = Foreach($Application in $ApplicationList){
get-childitem "HKLM:\software\microsoft\windows\currentversion\uninstall"  | ForEach-Object { Get-ItemProperty $_.PSPath }  | Select-Object DisplayVersion,InstallDate,ModifyPath,Publisher,UninstallString,Language,DisplayName | Where-Object {$_.DisplayName -like $Application}
get-childitem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\"  | ForEach-Object { Get-ItemProperty $_.PSPath }  | Select-Object DisplayVersion,InstallDate,ModifyPath,Publisher,UninstallString,Language,DisplayName | Where-Object {$_.DisplayName -like $Application}

}
if($CompetitorRMM) {
   # Rmm-Alert -Category "Monitoring" -Body "$($CompetitorRMM.displayname)"
   $outp = Write-Output "$($CompetitorRMM.displayname)"
   $outp.substring(0, [System.Math]::Min(12, $s.Length)) | Out-File -FilePath C:\kworking\OtherRMM.txt -Encoding ascii -NoNewline
   exit 1
}
if($founderror) {
exit 1
}
$outp = Write-Output "No Other RMM" 
$outp.substring(0, [System.Math]::Min(12, $s.Length)) | Out-File -FilePath C:\kworking\OtherRMM.txt -Encoding ascii -NoNewline
exit 0