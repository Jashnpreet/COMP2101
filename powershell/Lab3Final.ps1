get-ciminstance win32_networkadapterconfiguration |
where { $_.ipenabled -eq "true" } |
Format-Table -AutoSize Description, Index,
IPAddress, IPSubnet, DNSDomain, DNSServerSearchOrder