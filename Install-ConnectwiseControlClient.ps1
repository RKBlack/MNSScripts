$HostName = 'https://rkblack.screenconnect.com/'
$Port = '443'
if ($env:USERDOMAIN -eq 'WORKGROUP') {
    $TenantName = ((Resolve-DnsName $((Invoke-WebRequest ifconfig.me/ip).Content.Trim())).NameHost).Replace(".","")
} elseif ($env:COMPUTERNAME -eq $env:USERDOMAIN) {
    $TenantName = ((Resolve-DnsName $((Invoke-WebRequest ifconfig.me/ip).Content.Trim())).NameHost).Replace(".","")
} else {
    $TenantName = $env:USERDOMAIN
}
$DesiredState = 'Installed'
$CWCPackage = Get-Package -Name 'ScreenConnect Client (cdc0c456f410c9dc)' -ErrorAction SilentlyContinue
$DebugPreference = 'Continue'
$VerbosePreference = 'Continue'

if ($CWCPackage.Version -ge '22.5') {
    Write-Warning 'ConnectWise Control Client is alreay installed'
    $CWCPackage | Format-Table -AutoSize
    exit 0
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-Type -AssemblyName System.Web
Function Get-CWControlServerInfo {
    param([Uri]$Uri)
    $Builder = New-Object 'System.UriBuilder' $Uri
    $Builder.Path = '/Script.ashx'
    $Info = @{}
    $UriString = $Builder.ToString()
    Write-Verbose "Fetching $UriString"
    $Response = Invoke-WebRequest -UseBasicParsing -Uri $UriString
        
    if ($Response.Content -match '\"h"\:\"(.+?)\"') {
        $Info.Host = $matches[1]
    }
    else {
        $Info.Host = $Builder.Host
    }

    if ($Response.Content -match '\"k"\:\"(.+?)\"') {
        $Info.PublicKey = $matches[1]
    }

    if ($Response.Content -match '\"instanceUrlScheme"\:\"sc-(.+?)\"') {
        $Info.InstanceId = $matches[1]
    }

    if ($Response.Content -match '\"p"\:(\d+)') {
        $Info.Port = $matches[1]
    }
    if ($Builder.Host.EndsWith('screenconnect.com')) {
        Write-Verbose "Finding Relay Uri from $Uri"
        $InstanceResponse = Invoke-WebRequest -UseBasicParsing $Uri 
        $InstanceID = $InstanceResponse.RawContent.Substring($InstanceResponse.RawContent.IndexOf('Instance=') + 9, 6)
        $RelayUri = "instance-$InstanceID-relay.screenconnect.com"    
        Write-Verbose $RelayUri
    }
    $Info.RelayUri = $RelayUri
    return (New-Object PSObject -Property $Info)
}

if ($DesiredState -ne 'Uninstalled') {


    $ControlUriBuilder = New-Object 'System.UriBuilder' $HostName
    $ControlUriBuilder.Scheme = 'https'
    if ($Port) {
        $ControlUriBuilder.Port = $Port
    }
    else {
        if ($ControlUriBuilder.Port -eq 80) {
            $ControlUriBuilder.Port = 443
        }
    }
    $ControlUri = $ControlUriBuilder.ToString()
    Write-Warning "ControlUri: $ControlUri"
    $ControlInstanceInfo = Get-CWControlServerInfo -Uri $ControlUri

    $ServiceName = "ScreenConnect Client ($($ControlInstanceInfo.InstanceId))"

    $DesiredParameters = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)

    $DesiredParameters['e'] = 'Access'
    $DesiredParameters['y'] = 'Guest'
    $DesiredParameters['h'] = $ControlInstanceInfo.Host
    if ($ControlInstanceInfo.RelayUri) {
        Write-Host "Replacing Host with RelayUri: $($ControlInstanceInfo.RelayUri)"
        $DesiredParameters['h'] = $ControlInstanceInfo.RelayUri
        $DesiredParameters['t'] = ''
    }
    $DesiredParameters['p'] = $ControlInstanceInfo.Port
    $DesiredParameters['c'] = $TenantName
    $DesiredParameters['k'] = $ControlInstanceInfo.PublicKey
    $Params = $DesiredParameters.ToString();

    if (!$ControlInstanceInfo.PublicKey) {
        Write-Error "Unable to retrieve publickey from $HostName`:$Port"
        return
    }
}



if ($DesiredState -ne 'Uninstalled') {
    $InstallerLogFile = "$env:TEMP\ControlClinet_Install_$(Get-Date -Format yyyyMMddHHmmss)_Log.log"
    $ControlUriBuilder.Path = '/Bin/ConnectWiseControl.ClientSetup.msi'
    $ControlUriBuilder.Query = $Params

    $InstallerUri = $ControlUriBuilder.ToString()
    $InstallerFile = [IO.Path]::ChangeExtension([IO.Path]::GetTempFileName(), '.msi')
    Get-Package "ScreenConnect Client ($($ControlInstanceInfo.InstanceId))" -ErrorAction SilentlyContinue | Select-Object -First 1 | Uninstall-Package
                (New-Object System.Net.WebClient).DownloadFile($InstallerUri, $InstallerFile)
    $Arguments = @"
/c msiexec /i "$InstallerFile" /qn /norestart /l*v "$InstallerLogFile" REBOOT=REALLYSUPPRESS SERVICE_CLIENT_LAUNCH_PARAMETERS="$Params"
"@
    Write-Host "Arguments: $Arguments"
    Write-Host "InstallerLogFile: $InstallerLogFile"        
    $Process = Start-Process -Wait cmd -ArgumentList $Arguments -PassThru
    if ($Process.ExitCode -ne 0) {
        Get-Content $InstallerLogFile -ErrorAction SilentlyContinue | Select-Object -Last 100
    }
    Write-Host "Exit Code: $($Process.ExitCode)";
    $ControlService = Get-Service -Name "$ServiceName"
    if ($ControlService.Status -ne 'Running') {
        $ControlService | Start-Service -PassThru
    }
}
else {
    $ScreenConnectHostName = $ControlInstanceInfo.Host
    'Removing Screenconnect/ConnectwiseControl'
    $ScreenConnectsToRemove = Get-ChildItem "$($env:ALLUSERSPROFILE)\ScreenConnect*\user.config" | ForEach-Object {
        $config = $_
                    
        if (((Get-Content -Path $config | Where-Object { $_ -like "*$ScreenConnectHostName*" } | Measure-Object).Count -gt 0)) {
            Split-Path $config -Parent | Split-Path -Leaf
        }
    }
                
    $UninstallStrings = $ScreenConnectsToRemove | ForEach-Object {
        $SC = $_
        $UninstallString = Get-ChildItem 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*\', 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*\' -ErrorAction SilentlyContinue | Where-Object {
                        (Get-ItemProperty $_.PSPath -Name DisplayName -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -eq $SC } | Measure-Object).Count -gt 0
        } | Get-ItemProperty -Name UninstallString | Select-Object -ExpandProperty UninstallString
        $UninstallString
    }
    $UninstallStrings
    $LogFile = 'c:\scuninstall.log'
    $UninstallStrings | ForEach-Object {
        Start-Process -Wait -NoNewWindow -FilePath cmd -ArgumentList "/c $_ /q /l*v `"$LogFile`""
    }
    Get-Content -Raw $LogFile
}
    



