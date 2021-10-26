[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DattoURL = 'https://cf-dl.datto.com/dwa/DattoWindowsAgent.exe'
$DattoPath = 'C:\Temp\DattoWindowsAgent.exe'

#Download and install Datto Agent
Invoke-WebRequest -Uri $DattoURL -OutFile $DattoPath -ErrorAction Continue
Start-Sleep -Seconds 15
Start-Process $DattoPath -ArgumentList '/quiet /norestart'
