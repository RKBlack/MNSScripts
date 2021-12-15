#
# Creates a Domain Admin account in AD
#
# Example:
# New-DomainAdmin -ADUsername john.doe -ADPassword Sup3r$eC^r3P@s$w0r4!
#

Import-Module ActiveDirectory
function New-DomainAdmin ([string] $ADPassword, [string] $ADUsername)
{
    $env:ADROOT=(Get-ADDomain | select dnsroot -ExpandProperty dnsroot)
    $env:ADDUPN=$ADUsername + "@" + $env:ADROOT
    $SecurePass=ConvertTo-SecureString $ADPassword -AsPlainText -Force
    New-ADUser -Name $ADUsername -SamAccountName $ADUsername -UserPrincipalName $env:ADDUPN -AccountPassword $SecurePass -Enabled $true
    Add-ADGroupMember "Domain Admins" $env:ADSAMN
}
