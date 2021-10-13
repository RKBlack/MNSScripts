$ChromeExists=Test-Path "c:\program files\google\chrome\application"
if ($ChromeExists -eq "True"){
	$ChromeURL = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi"
	$ChromeMSI = "c:\temp\chrome.msi"
	$ChromeLOG = "c:\temp\chrome-msi.log"
	Invoke-WebRequest -Uri $ChromeURL -OutFile $ChromeMSI -ErrorAction SilentlyContinue
	msiexec /q /i $ChromeMSI /L*V $ChromeLOG
	start-sleep -Seconds 300
	Get-Content $ChromeLOG
	Remove-Item -Path $ChromeMSI -Force
}
else { 
	Write-Host "Chrome Not Found"
}
