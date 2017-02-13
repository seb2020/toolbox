# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
    Generate an XML file for PRTG software monitoring tool
.NOTES
    File Name      : monitoring_backupPRTG.ps1
.EXAMPLE
    Example 1

#>

$user = "DOMAIN\test"
$password = "password"

# POST - Authorization
$Auth = @{uri = "http://VEEAMSERVER.domain.tld:9399/api/sessionMngr/?v=v1_2";
                   Method = 'POST'; #(or POST, or whatever)
                   Headers = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($user):$($password)"));
           } #end headers hash table
   } #end $params hash table

$AuthXML = Invoke-WebRequest @Auth

# GET - Session Statistics
$Sessions = @{uri = "http://VEEAMSERVER.domain.tld:9399/api/reports/summary/job_statistics";
                   Method = 'GET';
				   Headers = @{'X-RestSvcSessionId' = $AuthXML.Headers['X-RestSvcSessionId'];
           } #end headers hash table
	}

[xml]$SessionsXML = invoke-restmethod @Sessions

$SuccessfulJobRuns = $SessionsXML.JobStatisticsReportFrame.SuccessfulJobRuns
$WarningsJobRuns = $SessionsXML.JobStatisticsReportFrame.WarningsJobRuns
$FailedJobRuns = $SessionsXML.JobStatisticsReportFrame.FailedJobRuns

# GET - VM Statistics
$VMs = @{uri = "http://VEEAMSERVER.domain.tld:9399/api/reports/summary/vms_overview";
                   Method = 'GET';
				   Headers = @{'X-RestSvcSessionId' = $AuthXML.Headers['X-RestSvcSessionId'];
           } #end headers hash table
	}

[xml]$VMsXML = invoke-restmethod @VMs

$ProtectedVms = $VMsXML.VmsOverviewReportFrame.ProtectedVms
$SourceVmsSize = [Math]::round((($VMsXML.VmsOverviewReportFrame.SourceVmsSize) / 1073741824),0) 

# XML Output for PRTG
Write-Host "<prtg>" 
Write-Host "<result>"
               "<channel>SuccessfulJobRuns</channel>"
               "<value>$SuccessfulJobRuns</value>"
               "<showChart>1</showChart>"
               "<showTable>1</showTable>"
               "</result>"
Write-Host "<result>"
               "<channel>ProtectedVms</channel>"
               "<value>$ProtectedVms</value>"
               "<showChart>1</showChart>"
               "<showTable>1</showTable>"
               "</result>" 
Write-Host "<result>"
               "<channel>SourceVmsSize</channel>"
               "<value>$SourceVmsSize</value>"
               "<unit>Custom</unit>"
               "<customUnit>GB</customUnit>"
               "<showChart>1</showChart>"
               "<showTable>1</showTable>"
               "</result>" 
Write-Host "<result>"
               "<channel>WarningsJobRuns</channel>"
               "<value>$WarningsJobRuns</value>"
               "<showChart>1</showChart>"
               "<showTable>1</showTable>"
               "<LimitMaxWarning>1</LimitMaxWarning>"
               "<LimitMode>1</LimitMode>"
               "</result>" 
Write-Host "<result>"
               "<channel>FailedJobRuns</channel>"
               "<value>$FailedJobRuns</value>"
               "<showChart>1</showChart>"
               "<showTable>1</showTable>"
               "<LimitMaxError>1</LimitMaxError>"
               "<LimitMode>1</LimitMode>"
               "</result>" 
Write-Host "</prtg>" 

