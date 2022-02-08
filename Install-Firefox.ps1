# Path for the workdir
$workdir = "c:\Windows\Temp\"
# Check if work directory exists if not create it
If (Test-Path -Path $workdir -PathType Container)
{ Write-Host "$workdir already exists" -ForegroundColor Red}
ELSE
{ New-Item -Path $workdir  -ItemType directory }

#Sleep Timer
function Start-Sleep($seconds) {
    $doneDT = (Get-Date).AddSeconds($seconds)
    while($doneDT -gt (Get-Date)) {
        $secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        $percent = ($seconds - $secondsLeft) / $seconds * 100
        Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining $secondsLeft -PercentComplete $percent
        [System.Threading.Thread]::Sleep(500)
    }
    Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}

# Download the installer
$source = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"
$destination = "$workdir\Firefox-Setup.exe"
Invoke-WebRequest $source -OutFile $destination
# Start the installation
Start-Process -FilePath "$workdir\Firefox-Setup.exe" -ArgumentList "/S"
# Wait XX Seconds for the installation to finish
Start-Sleep 30
