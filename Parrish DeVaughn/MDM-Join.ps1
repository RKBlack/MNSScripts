New-Item -ItemType Directory -Path C:\Temp -ErrorAction SilentlyContinue
Invoke-WebRequest -Uri https://github.com/RKBlack/MNSScripts/blob/cda79095f13947dd9c17be63a2177a6652a86b49/MDMJOIN.ppkg -OutFile C:\Temp\MDMJOIN.ppkg
Install-ProvisioningPackage -PackagePath C:\Temp\MDMJOIN.pkg -QuietInstall -ForceInstall
