$apps = Get-WindowsCapability -Online -Name “*QuickAssist*”
foreach($app in $apps)
{
    Remove-WindowsCapability -Online -Name $app.Name
}
