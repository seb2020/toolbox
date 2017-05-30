<#
	
	On Null Email Addresses

		If the user has no email address specififed the script will check extensionAttribute6 for an 
		email address. If extensionAttribute6 is null $DefaultTo will be used instead.

		You should place an email address in extensionAttribute6 for service accounts and admin accounts 
		that do not have their own email address.

#>

#########################################################################
# User Variables
#########################################################################
# Days out from expiry on which to send emails as an array.
# ie, (5, 2, 1) will send emails if the password is set to expire in 5 days, 2 days, or 1 day.
$SendEmails = @(10,5,4,3,2,1)

# Email Variables
$MailFrom = "passwords@company.com" # Send email from
$MailSMTPServer = "10.25.25.25" # Send email via
$DefaultTo = "itteam@company.com" # Send email here if user has no email address and extensionAttribute6 is null or an invalid address.

# Subject and Body - {0} replaces with number of days, {1} replaces with the user's full name.
$MailSubject = "Your Password is Set to Expire in {0} Days"

$MailBody = @"
Good Morning,

The network password for {1} will expire in {0} days. Please change your password as soon as possible using the instructions below.

From a computer on our network:
1. Press Ctrl+Alt+Delete on your keyboard.
2. Select "Change Password" from the menu.
3. Enter your old password in the top box.
4. Enter and confirm your new password.
5. Click "Change."

Complexity requirements:
- Your password must be at least 15 characters in length.
- Your password must contain three of the following four types of characters: lowercase letters, uppercase letters, numbers, and special characters (i.e. $, @, *, !)
- Your password may not be one of the last 5 passwords you have used.
- Your password may not contain your first name, last name, or username.

Regards,
IT Support
"@

#########################################################################
# Static Variables - Do Not Change
#########################################################################
# $ExpireDays is the highest number found in $SendEmails.
$ExpireDays = $($SendEmails | Measure-Object -Maximum).Maximum

# Create the output aaray.
$Output = @()

#########################################################################
# Script Logic
#########################################################################
# Send email function.
function Send-ExpireEmail ($To, $From, $SMTPServer, $Subject, $Body, $Days, $Name)
{
	$FinalBody = $Body -f $Days, $Name
	if ($Days -eq "1")
	{
		$FinalBody = $FinalBody -ireplace "Days", "Day"
	}
	$FinalSubject = $Subject -f $Days, $Name
	if ($Days -eq "1")
	{
		$FinalSubject = $FinalSubject -ireplace "Days", "Day"
	}
	
	Send-MailMessage -To $To -Subject $FinalSubject -Body $FinalBody -SmtpServer $SMTPServer -From $From
}

# Find expiring users that match criteria.
## Retrieve relevant properties from objects.
$ADProperties = @(
	'PasswordLastSet',
	'PasswordNeverExpires',
	'extensionAttribute6',
	'Mail',
	'msDS-UserPasswordExpiryTimeComputed'
)

## Select relevant properties from query.
$ADSelect = @(
	'Name',
	'Mail',
	'extensionAttribute6',
	'PasswordLastSet',
	@{n = 'PasswordExpirationDate'; e = {[datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed')}},
	@{n = 'PasswordDaysToExpired'; e = {(New-Timespan -End ([datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed'))).Days}}
)

## User Query
$Users = Get-ADUser -Properties $ADProperties -Filter {(PasswordNeverExpires -eq $False) -and (Enabled -eq $true)} | Select-Object $ADSelect | Where-Object {($_.PasswordDaysToExpired -le $ExpireDays) -and ($_.PasswordDaysToExpired -ge 0)}

# Determine attributes and whether or not to send email based on $SendEmail
foreach ($User in $Users)
{
	$Span = $User.PasswordDaysToExpired
	
	if ($Span -in $SendEmails)
	{
		
		if ($User.Mail -eq $null -and $User.extensionAttribute6 -eq $null)
		{
			$MailTo = $DefaultTo
		}
		elseif ($User.Mail -eq $null -and $User.extensionAttribute6 -match "^(?("")("".+?""@)|(([0-9a-zA-Z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-zA-Z])@))(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,6}))$")
		{
			$MailTo = $User.extensionAttribute6
		}
		else
		{
			$MailTo = $User.Mail
		}
		
		$Output += New-Object -TypeName PSObject -Property @{
			Name = $User.Name
			Email = $MailTo
			Expires = $User.PasswordExpirationDate
			Span = $Span
		}
	}
}
# Per-user that meets criteria: send emails.
foreach ($ExpiringUser in $Output)
{
	#Call Send-ExpireEmail
#	Send-ExpireEmail -To $($ExpiringUser.Email) -From $MailFrom -SMTPServer $MailSMTPServer -Subject $MailSubject -Body $MailBody -Days $($ExpiringUser.Span) -Name $($ExpiringUser.Name)
}

# Use for testing
# Comment out foreach loop above to supress emails while testing.
 $Output | Sort-Object span | Format-Table