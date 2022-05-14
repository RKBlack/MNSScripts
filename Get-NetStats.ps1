$connections = Get-NetTCPConnection
$results = foreach ($connection in $connections) {
  $dnsname = Resolve-DnsName -Name $connection.RemoteAddress -ErrorAction SilentlyContinue
  $procname = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
  New-Object -TypeName psobject -Property @{
    Address = $connection.RemoteAddress
    DNSName = $dnsname.Namehost
    ProcessName = $procname.Processname
    PortNumber = $connection.RemotePort
    State = $connection.State
  }
}
$results | Sort-Object -Property DNSName | Format-Table -Property DNSName,PortNumber,ProcessName,Address,State
