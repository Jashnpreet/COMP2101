function get-hardwareinfo
{
 Write-host "System Hardware Description"
 get-wmiobject -class Win32_ComputerSystem | fl Description
}




function get-osinfo
{
 Write-host "Operating System Description"
 get-wmiobject -class Win32_OperatingSystem | fl Name, Version
}



function get-cpuinfo
{
 Write-host "System Processor Description"
 get-wmiobject -class win32_processor | fl Description, CurrentClockSpeed, NumberOfCores, @{n="L1CacheSize";e={switch($_.L1CacheSize){$null{$empty="data unavailable"}};$empty}}, L2CacheSize, L3CacheSize
}

                                                                                                                                                                          


function get-raminfo
{
Write-host "RAM Description"
$sum = 0
get-wmiobject -class win32_physicalmemory |
  foreach { 
    New-Object -TypeName psObject -Property @{ 
      Vendor = $_.Manufacturer
      Description = $_.Description
     "Size(GB)" = $_.Capacity/1gb
     "Speed(Mhz)" = $_.ConfiguredClockSpeed
      Bank = $_.BankLabel
      Slot = $_.DeviceLocator
      }
      $sum += $_.capacity/1gb
      }|
ft Vendor, Description, "Size(GB)", "Speed(Mhz)", Bank, Slot
"Total RAM: ${sum}GB"}




function get-diskinfo
{
write-host "Disk Drive Description"
$diskdrives = Get-CimInstance -class CIM_diskdrive
foreach ($disk in $diskdrives) {
    $partitions = $disk|get-cimassociatedinstance -resultclassname CIM_diskpartition
    foreach ($partition in $partitions) {
          $logicaldisks = $partition | get-cimassociatedinstance -resultclassname CIM_logicaldisk
          foreach ($logicaldisk in $logicaldisks) {
             new-object -typename psobject -property @{
               Vendor = $disk.Manufacturer
               Model = $disk.Model
               Drive = $logicaldisk.deviceid
               "Size(GB)" = $logicaldisk.size / 1gb -as [int]
               "freeSpace(GB)" = $logicaldisk.freespace/1gb -as [int]
               "freeSpace(%)" = ([string]((($logicalDisk.FreeSpace / $logicalDisk.Size) * 100) -as [int]) + '%')} | ft Drive, Vendor, Model, "Size(GB)", "freespace(GB)", "freeSpace(%)"
           }
      }
  }
}




function get-adapterinfo
{
  Write-host "Network Adapter Description"
  get-wmiobject -class win32_networkadapterconfiguration |
  ft Index, IPAddress, IPSubnet, Description,
  @{n="DNSDomain";e={switch($_.DNSDomain){$null{$empty="data unavailable";$empty}};if($null -ne $_.DNSDomain){$_.DNSDomain}}},
  @{n="DNSServerSearchOrder";e={switch($_.DNSServerSearchOrder){$null{$empty="data unavailable";$empty}};if($null -ne $_.DNSServerSearchOrder){$_.DNSServerSearchOrder}}}
}



function get-gpu
{
  Write-host "Graphics Card Description"
  $hpixels = (get-wmiobject -class Win32_videocontroller).CurrentHorizontalResolution -as [String]
  $vpixels = (gwmi -classNAME win32_videocontroller).CurrentVerticalresolution -as [string]
  $resolution = $hpixels + " x " + $vpixels
  gwmi -classNAME win32_videocontroller| fl @{n = "Video Card Vendor"; e={$_.AdapterCompatibility}}, Description, @{n="Screen Resolution"; e={$resolution -as [string]}}
}

get-hardwareinfo
get-osinfo
get-cpuinfo
get-raminfo
get-diskinfo
get-adapterinfo
get-gpu