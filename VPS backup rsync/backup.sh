#!/bin/sh

# ..######.
# .##....##
# .##......
# ..######.
# .......##
# .##....##
# ..######.

#################################################################################
#
# Script: /scripts/backup.sh
# Purpose : Backup to rsync remote location with rsync on port 2222
#
################################################################################

date=`date +%d%m%y%H%M`
home_user="ovhbackup"
home_userpwd="XXXX"
home_ip="X.X.X.X"
home_path="/volume1/data/ovhbackup/"
mail_from="backup@domain.ch"
mail_to="user@domain.ch"
mail_subject="[Backup] Backup report"
err=0

#Get start date
time_start="$(date)"

#Rsync the /opt/ folder to home
sshpass -p $home_userpwd rsync -aRvz -e 'ssh -p 2222' /opt $home_user@$home_ip:$home_path
if [ $? -ne 0 ]
then
	err=1
fi

#Start seafile service
sh service seafile-server start

time_end="$(date)"
if [ $err -ne 0 ]
then
        mail_subject="[Backup] Backup report : ERROR !"
else
        mail_subject="[Backup] Backup report : Success"
fi

echo -e "Script started at : $time_start \nScript ended at : $time_end " | mail -s "$mail_subject" $mail_to

   
