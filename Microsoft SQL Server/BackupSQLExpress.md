# Backup SQL Express


```bak
REM Backup all database from instanceID and keep only the last 5 days

forfiles -p "D:\Backup\SQL" -s -m *.bak -d -5 -c "cmd /c del @file"

sqlcmd -S .\InstanceID -E -Q "EXEC sp_BackupDatabases @backupLocation='D:\Backup\SQL\', @backupType='F'"
```