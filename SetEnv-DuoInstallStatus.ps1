$duofile = Test-Path - 'C:\Program Files\Duo Security\WindowsLogon\Winlogon-Diag.ps1'
if ($duofile){
[Environment]::SetEnvironmentVariable("DUO_SECURITY_INSTALLED", "TRUE", "Machine")
}
