# Hyper-V Tips and tricks

## Get status of running VM

```powershell
Get-VM | where {$_.state -eq 'running'} | sort Uptime | select Name,Uptime,@{N="MemoryMB";E={$_.MemoryAssigned/1MB}},Status

Name                          Uptime                                             MemoryMB Status
----                          ------                                             -------- ------
SRVLNXMGNT-01                 08:21:03                                               4096 Operating normally
SRVAD-01                      15:10:04                                               2048 Operating normally
SRVFILE-01                    4.04:16:36                                             2048 Operating normally
```

## Get Snapshot 

```powershell
Get-VMSnapshot *

VMName         Name                       SnapshotType CreationTime         ParentSnapshotName
------         ----                       ------------ ------------         ------------------
TPL_W2012R2_01 Before update                Standard     3/8/2016 4:22:36 PM
```

## Get IP

```powershell
Get-VM | where { $_.state -eq 'running'} | get-vmnetworkadapter | Select VMName,SwitchName,@{Name="IP";Expression={$_.IPAddresses }} | Sort VMName

VMName                                  SwitchName                              IP
------                                  ----------                              --
SRVAD-01                                VM-103                                  {10.10.10.3, fe80::d8a9:4540:97b...
SRVDB-01                                VM-103                                  {10.20.10.4, fe80::215:5dff:fe65...
``