Invoke-WebRequest -Uri "https://github.com/RKBlack/MNSScripts/releases/download/Duo/DuoWindowsLogon64.msi" -OutFile C:\Windows\Temp\DuoWindowsLogon64.msi
$args = @"
/i "C:\Windows\Temp\DuoWindowsLogon64.msi" IKEY="DIBY2MHAW0F69ANPCURZ" SKEY="0iHYyGarUFMx27LZgIElmaxJ7MPVDqN2migGmNxA" HOST="api-4fad82bb.duosecurity.com" AUTOPUSH="#1" FAILOPEN="#0" SMARTCARD="#0" RDPONLY="#0" /qn
"@
Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList $args
