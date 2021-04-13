function Set-WakeEnabled
{
<#
.SYNOPSIS
Set WoL on nic
Author: Jan-Henrik Damaschke (@jandamaschke)
License: BSD 3-Clause
Required Dependencies: None
Optional Dependencies: None
.DESCRIPTION
Set Wake on Lan (WOL) settings for specific network interface card
.PARAMETER InterfaceName
Specifies the name of the interface where WoL setting should be changed
.PARAMETER WakeEnabled
Specifies if WoL should be enabled or disabled
.EXAMPLE
PS C:\> Set-WakeEnabled -InterfaceName Ethernet -WakeEnabled $true
.LINK
http://itinsights.org/
#>

[CmdletBinding()] Param(
        [Parameter(Mandatory = $True, ParameterSetName="InterfaceName")]
        [String]
        $InterfaceName,

        [Parameter(Mandatory = $True)]
        [String]
        $WakeEnabled,

        [Parameter(Mandatory = $True, ParameterSetName="ConnectionID")]
        [String]
        $NetConnectionID
)

    If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
        Break
    }

    $nicsWakeEnabled = Get-CimInstance -ClassName MSPower_DeviceWakeEnable -Namespace root/wmi
    $nics = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object NetEnabled -eq $true

    if ($InterfaceName){
        $nic = $nics | Where-Object Name -eq $InterfaceName
    }
    else {
        $nic = $nics | Where-Object NetConnectionID -eq $NetConnectionID
    }

    $nicWakeEnabled = $nicsWakeEnabled | Where-Object InstanceName -like "*$($nic.PNPDeviceID)*"
    
    $enabled = $nicWakeEnabled.Enable

    if (!($enabled -and $WakeEnabled)){
        Set-CimInstance $nicWakeEnabled -Property @{Enable=$enabled}
    }
}