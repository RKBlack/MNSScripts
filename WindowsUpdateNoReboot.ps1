[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Confirm:$false -Force
Install-Module -Name PSWindowsUpdate -Confirm:$false -Force
Install-WindowsUpdate -IgnoreReboot -AcceptAll -NotKBArticleID KB5000802, KB5000808