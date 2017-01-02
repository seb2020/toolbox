# This script send mail when a enventid is triggered
# sgir / 02.01.2017
#
# Exemple with an eventid related to AD CS

$event = get-eventlog -LogName Security -InstanceId 4887 -newest 1

$PCName = $env:COMPUTERNAME
$EmailBody = $event.Message
$EmailFrom = "Sender <$PCName@domain.ch>"
$EmailTo = "user@domain.ch" 
$EmailSubject = "Event 4887 : Certificate Services approved a certificate request and issued a certificate."
$SMTPServer = "relay.domain.lan"
Write-host "Sending Email"
Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer
