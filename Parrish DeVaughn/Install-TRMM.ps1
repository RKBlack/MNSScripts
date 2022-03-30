$DeploymentURL = "https://api.rkbcloud.net/clients/f9b13315-6197-4e6c-8230-85688b57fd84/deploy/"
$DeploymentPath = "$env:TEMP\TRMM"
$DeploymentFile = "$DeploymentPath\rmm-workstation.exe"

$serviceName = 'tacticalrmm'
If (Get-Service $serviceName -ErrorAction SilentlyContinue) {
    Exit 0
}Else {
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
    New-Item -ItemType Directory -Path $DeploymentPath -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath $DeploymentPath -Force -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath "C:\Program Files\TacticalAgent\*" -Force -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath "C:\Windows\Temp\winagent-v*.exe" -Force -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath "C:\Program Files\Mesh Agent\*" -Force -ErrorAction SilentlyContinue
    Add-MpPreference -ExclusionPath "C:\Windows\Temp\TRMM\*" -Force -ErrorAction SilentlyContinue
    Invoke-WebRequest -Uri $DeploymentURL -OutFile $DeploymentFile
    Start-Sleep -Seconds 60
    Start-Process $DeploymentFile -NoNewWindow -Wait
    Remove-MpPreference -ExclusionPath $DeploymentPath -Force -ErrorAction SilentlyContinue
}
