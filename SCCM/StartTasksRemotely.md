# Start a SCCM tasks remotely

```
$WMIPath = "\\" + $CompName + "\root\ccm:SMS_Client"
$SMSwmi = [wmiclass] $WMIPath
    [Void]$SMSwmi.TriggerSchedule($strAction)
```

* Supported actions for $strAction are:
* Application Deployment Evaluation Cycle: {00000000-0000-0000-0000-000000000121}
* Discovery Data Collection Cycle: {00000000-0000-0000-0000-000000000003}
* Hardware Inventory Cycle: {00000000-0000-0000-0000-000000000001}
* Machine Policy Retrieval and Evaluation Cycle: {00000000-0000-0000-0000-000000000021}
* Software Inventory Cycle: {00000000-0000-0000-0000-000000000002}
* Software Metering Usage Report Cycle: {00000000-0000-0000-0000-000000000031}
* Software Updates Deployment Evaluation Cycle: {00000000-0000-0000-0000-000000000108}
* Software Updates Scan Cycle: {00000000-0000-0000-0000-000000000113}
* Windows Installer Source List Update Cycle: {00000000-0000-0000-0000-000000000032}