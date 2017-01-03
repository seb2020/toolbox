# SQL
select  all SMS_R_SYSTEM.ItemKey,SMS_R_SYSTEM.DiscArchKey,SMS_R_SYSTEM.Name0,SMS_R_SYSTEM.SMS_Unique_Identifier0,SMS_R_SYSTEM.Resource_Domain_OR_Workgr0,SMS_R_SYSTEM.Client0 from vSMS_R_System AS sms_r_system INNER JOIN fn_ListUpdateComplianceStatus(0) AS SMS_UpdateComplianceStatus ON SMS_UpdateComplianceStatus.MachineID = sms_r_system.ItemKey   where SMS_UpdateComplianceStatus.LastEnforcementMessageID = 9

# WQL
SELECT SMS_R_SYSTEM.ResourceID, SMS_R_SYSTEM.ResourceType, SMS_R_SYSTEM.Name, SMS_R_SYSTEM.SMSUniqueIdentifier, SMS_R_SYSTEM.ResourceDomainORWorkgroup, SMS_R_SYSTEM.Client FROM sms_r_system inner join SMS_UpdateComplianceStatus ON SMS_UpdateComplianceStatus.machineid=sms_r_system.resourceid WHERE SMS_UpdateComplianceStatus.LastEnforcementMessageID = 9

There are several other enforcement states you can use instead by changing the number after ‘LastEnforcementMessage ID =’ at the end of the query.
* 1 – Enforcement started
* 3 – Waiting for another installation to complete
* 6 – General failure
* 8 – Installing update
* 9 – Pending system restart
* 10 – Successfully installed update
* 11 – Failed to install update
* 12 – Downloading update
* 13 – Downloaded update