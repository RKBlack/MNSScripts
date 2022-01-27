New-Item -ItemType Directory -Path C:\Temp -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri https://github.com/RKBlack/MNSScripts/blob/de89bab97e7fa0de7988536bcef74a4b1b8b9d07/Parrish%20DeVaughn/MDMJOIN.ppkg -OutFile C:\Temp\MDMJOIN.ppkg
Install-ProvisioningPackage -PackagePath C:\Temp\MDMJOIN.pkg -QuietInstall -ForceInstall
