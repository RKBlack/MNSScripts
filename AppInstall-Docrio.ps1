# Path for the workdir
$workdir = "c:\Temp\"
# Check if work directory exists if not create it
If (Test-Path -Path $workdir -PathType Container)
ELSE
{ New-Item -Path $workdir  -ItemType directory }
# Download the installer
$source = "https://one-click-edit-application-build-bucket.s3.amazonaws.com/Docrio%20Edit%20Setup%202.6.8.exe"
$destination = "$workdir\Docrio Edit Setup 2.6.8.exe"
Invoke-WebRequest $source -OutFile $destination
# Start the installation
Start-Process -FilePath "$workdir\Docrio Edit Setup 2.6.8.exe"
# Wait XX Seconds for the installation to finish
Start-Sleep 30
