# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

<#
.SYNOPSIS
   This script send mail when a enventid is triggered by Tasks Scheduler
.DESCRIPTION
     Exemple with an eventid related to AD CS
.NOTES
    File Name      : SendEmailEventLog.ps1

#>

$event = get-eventlog -LogName Security -InstanceId 4887 -newest 1

$PCName = $env:COMPUTERNAME
$EmailBody = $event.Message
$EmailFrom = "Sender <$PCName@domain.ch>"
$EmailTo = "user@domain.ch" 
$EmailSubject = "Event 4887 : Certificate Services approved a certificate request and issued a certificate."
$SMTPServer = "relay.domain.lan"
Write-host "Sending Email"
Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer
