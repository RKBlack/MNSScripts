$KBBlacklist = "KB5000802, KB5000808"
$PSUpdateLog = "C:\Windows\PSWindowsUpdate.log"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Confirm:$false -Force
Install-Module -Name PSWindowsUpdate -Confirm:$false -Force
Install-WindowsUpdate -IgnoreReboot -AcceptAll -NotKBArticleID $KBBlacklist | Out-File $PSUpdateLog -Confirm:$false -Verbose
