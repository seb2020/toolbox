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
# Script: backup.sh
# Purpose : Backup PostgreSQL Database
# Example :  backup_db.sh 2>&1 | tee output.txt | mail -s "Backup DB" mail@domain.ch
#
################################################################################

backupdir='/nfs/db/dev';
day=`date +"%d%m%Y_%H%M%S"`;
mkdir -p $backupdir/$day;

echo "PostgreSQL Backup for $HOSTNAME";
echo ""
echo "================================="
echo ""
echo `date`;
echo ""
for database in `/u01/app/postgres/product/95/db_2/bin/psql -U postgres -lt | awk '{print $1}' | grep -vE '\||^$|template0'`;
    do
    printf "Exporting $database...";
    /u01/app/postgres/product/95/db_2/bin/pg_dump -U postgres -c $database | gzip -c > $backupdir/$day/$database.sql.gz;
    /bin/chmod 600 $backupdir/$day/$database.sql.gz;
    printf "done\n";
done
echo ""
echo `date`;
echo;
exit 0;