#Uninstall N-Able
$uninstallers = @(
    'C:\Program Files (x86)\SolarWinds MSP\Ecosystem Agent\unins000.exe'
    'C:\Program Files (x86)\MspPlatform\FileCacheServiceAgent\unins000.exe'
    'C:\Program Files (x86)\MspPlatform\PME\unins000.exe'
    'C:\Program Files (x86)\MspPlatform\RequestHandlerAgent\unins000.exe'
    )

$nservices = @(
    'NablePatchRepositoryService'
    'BASupportExpressStandaloneService_N_Central'
    'BASupportExpressSrvcUpdater_N_Central'
    'Windows Agent Service'
    )

$ndirectories = @(
    'C:\Program Files (x86)\N-able Technologies'
    'C:\Program Files (x86)\MspPlatform'
    'C:\Program Files (x86)\SolarWinds MSP'
    'C:\Program Files (x86)\RequestHandlerAgent'
    )

$nregkeys = @(
    'HKLM:\SOFTWARE\N-able Technologies'
)

$nwindowsagent = Get-WMIObject -Class win32_Product -Filter "Name='Windows Agent'"
$nwindowsprobe = Get-WMIObject -Class win32_Product -Filter "Name='Windows Software Probe'"

$nwindowsagent.Uninstall()
$nwindowsprobe.Uninstall()

Foreach ($unins000 in $uninstallers) {
    Start-Process $unins000 -ArgumentList '/SILENT' -NoNewWindow -Wait
    Start-Sleep -Seconds 10
    }

Foreach ($nservice in $nservices) {
    Stop-Service -Name $nservice -Force
    Start-Sleep -Seconds 10
    $service = Get-WmiObject -Class Win32_Service -Filter "Name=$nservice"
    $service.delete()
    Start-Sleep -Seconds 10
    }

Foreach ($ndirectory in $ndirectories) {
    Remove-Item $ndirectory -Recurse -Force
    Start-Sleep -Seconds 10
    }

foreach ($neregkey in $nregkeys) {
    Remove-Item $neregkey -Force -Recurse
}
