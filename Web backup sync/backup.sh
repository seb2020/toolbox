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
# Script: Add in Synology -> Scheduler -> Scheduled – User-defined script
# Purpose : Backup to rsync remote location with rsync on port 2222
#
# It mirrors current structure of the ftp server as found.
# If rerun it compares the content in current folder on Synology with content on ftp and only redownloads the differences.
# It backups current state after the backup is made into dated archive so one can go back in time without much effort. 
#
################################################################################

wget -m ftp://user:password@webhosting.ch/* -P /volume1/data/website
tar -zcvf /volume1/data/website/backup-$(date +%Y-%m-%d-%H-%M-%S).tar.gz /volume1/data/website/rhea.website.ch/