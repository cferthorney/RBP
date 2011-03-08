#!/bin/bash

# Echoes name of month - day, as Jan-01.
DATE=`date '+%b-%d'`

DATE2=`date  --date='1 week ago' '+%b-%d'`
# States the folder where to place database dumps.
DUMPDIR=/home/backup/databasedumps/dumps

#Creates a dump of all databases in a file in /var/www/vhosts/databasedumps/dumps/
#Password needs update
mysqldump -u crondbu -pAPASSWORD --all-databases >$DUMPDIR/$DATE.sql
gzip $DUMPDIR/$DATE.sql

#Removes any file which is not the backup from today.
rm -f "$DUMPDIR/$DATE2.sql.gz"
