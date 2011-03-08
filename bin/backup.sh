#!/bin/bash

#Version 2.0
#Converting to functions
#Authored by DT
#Edited by DT
#License: GPL v3

#First sync all remote machines to our backup and create the backup log
FILE=`date +%d%m%y`
FILE2=`date  --date='1 week ago' '+%d%m%y'`
TIME=`date`
RSYNCPATH="/usr/bin/rsync"
TARPATH="/bin/tar"
RMPATH="/bin/rm"
MVPATH="/bin/mv"
BACKUPPATH="/home/backup/"
TAPE="sdc1"
PORT="22"
SCRIPTCOMMENCE=`date +'%H:%M:%S - %d-%m-%Y'`
TODAY=`date +%d`
MONTH=`date +%b`
MONTH2=`date --date='1 month ago' '+%b'`
#Global Args
KEY="-e \"ssh -p$PORT -i $BACKUPPATH.ssh/backup.key\""
BACKUPFILE=$BACKUPPATH"logs/backup.$FILE"
GLOBALARGS="-Carvz --ignore-errors"
#"-rvvlpgoDzI"
GLOBALEXCLUDES="--exclude=\"*.bash_history\" --exclude=\"*.php.A5HeYg\" --exclude=\"pd/*\" --exclude=\"*svn*\" --exclude=\"cvs\" --exclude=\"CVS\" --exclude=\"private*\" --exclude=\".ssh*\" --exclude=\"*access_log.processed*\" --exclude=
\"*log\" --exclude=\"*log\" --exclude=\"*.elinks\" --exclude=\"*.subversion\" --exclude=\"*.lesshst\" --exclude=\"*.mysql_history\" --exclude=\"*.viminfo*\" "

SRC=
DEST=
LOCALEXCLUDES=
LOCALARGS=
HOST=
HOST2=
USER="backup@"
IP=
APACHEPATH="/etc/httpd/"
VHOSTSPATH="/var/www/"
NAMEDPATH="/var/named/"
HOMEVHPATH="/home/vhosts/"
#SVNPATH="/svn/"

#eval is to deal with passing spaces
function start_host() {
        eval "echo $HOST `date` >> $BACKUPFILE"
}
function rsync_bu() {
        eval "$RSYNCPATH $LOCALARGS $KEY $LOCALEXCLUDES $SRC $DEST >> $BACKUPFILE"
} #end rsync_bu

function tar_dir() {
        eval "$TARPATH -czf $HOST2-$FILE.tar.gz $HOST2"
        if [ $TODAY == '01' ]; then
                eval "$MVPATH $HOST2-$FILE.tar.gz $HOST2-$MONTH.tar.gz"
        fi
} # end tar_bu

function rmtar_dir() {
         if [ $TODAY == '01' ]; then
                eval "$RMPATH -f $BACKUPPATH$HOST2-$MONTH2.tar.gz"
                eval "$RMPATH -f $BACKUPPATH$HOST2-$FILE2.tar.gz"
        else
                eval "$RMPATH -f $BACKUPPATH$HOST2-$FILE2.tar.gz"
        fi
} # end untar_bu

function rsync_tape() {
        #Backup to external drive connected
        eval "mount /dev/$TAPE /mnt"
        LOCALMOUNT="/mnt"
        $RSYNCPATH $GLOBALARGS $BATHUPPATH $LOCALMOUNT
        eval "umount $LOCALMOUNT"
}


echo "RSync start at $TIME" > $BACKUPFILE

#Host Main Server
HOST="Host Main Server"
HOST2=`eval "echo $HOST | sed -e 's/ //g'"` #Strip space
IP="127.0.0.1"
PORT="22"
SRC=$USER$IP":"$APACHEPATH"*"
DEST=$BACKUPPATH$HOST2$APACHEPATH
LOCALEXCLUDES=$GLOBALEXCLUDES" --exclude=\"httpd.pem*\" "
LOCALARGS=$GLOBALARGS" "
start_host
rsync_bu

SRC=$USER$IP":"$VHOSTSPATH"*"
DEST=$BACKUPPATH$HOST2$VHOSTSPATH
LOCALEXCLUDES=$GLOBALEXCLUDES" "
LOCALARGS=$GLOBALARGS" "
rsync_bu
tar_dir
rmtar_dir

#Reset SSH Port
KEY="-e \"ssh -p$PORT -i /home/backup/.ssh/backup.key\""

#Host Second Server
HOST="Host Second Server"
HOST2=`eval "echo $HOST | sed -e 's/ //g'"` #Strip space
IP="127.0.0.1"
SRC=$USER$IP":"$APACHEPATH"*"
DEST=$BACKUPPATH$HOST2$APACHEPATH
LOCALEXCLUDES=$GLOBALEXCLUDES" --exclude=\"httpd.pem*\" "
LOCALARGS=$GLOBALARGS" "
start_host
rsync_bu

SRC=$USER$IP":"$VHOSTSPATH"*"
DEST=$BACKUPPATH$HOST2$VHOSTSPATH
LOCALEXCLUDES=$GLOBALEXCLUDES" --exclude=\"*vhosts*\" "
LOCALARGS=$GLOBALARGS" "
rsync_bu

SRC=$USER$IP":"$NAMEDPATH"*"
DEST=$BACKUPPATH$HOST2$NAMEDPATH
LOCALEXCLUDES=$GLOBALEXCLUDES" "
LOCALARGS=$GLOBALARGS" --exclude=\"*dev*\" --exclude=\"*proc*\" --exclude=\"*saved_by_psa*\" "
rsync_bu

SRC=$USER$IP":"$HOMEVHPATH"*"
DEST=$BACKUPPATH$HOST2$VHOSTSPATH"vhosts/"
LOCALEXCLUDES=$GLOBALEXCLUDES" "
LOCALARGS=$GLOBALARGS" "
rsync_bu

####### SVN if required #######

#SRC=$USER$IP":"$SVNPATH"*"
#DEST=$BACKUPPATH$HOST2$SVNPATH
#LOCALEXCLUDES=$GLOBALEXCLUDES" "
#LOCALARGS=$GLOBALARGS" "
#rsync_bu

#Fnished the RSync
TIME=`date`
RSYNCFINISH=`date +'%H:%M:%S - %d-%m-%Y'`
# Insert rsync commands to insert key config files into the backed up tree.
echo "RSync finish at $TIME" >> $BACKUPFILE
TIME=`date`
TARSTART==`date +'%H:%M:%S - %d-%m-%Y'`
echo "Tar start at $TIME" >> $BACKUPFILE
echo "Tar started" >> $BACKUPFILE

tar_dir
rmtar_dir

TIME=`date`
echo "Tar finish at $TIME" >> $BACKUPFILE
BACKUPSIZE=`du -sh $BACKUPPATH`

gzip $BACKUPFILE


SCRIPTFINISH==`date +'%H:%M:%S - %d-%m-%Y'`
#Eject the tape

#Now email any errors to admin account??? - need to script
# Send an email to administrator
admin="dthorne@contemporaryfusion.co.uk"
cat <<EOF |/usr/lib/sendmail -t -oi
To: $admin
Reply-to: $admin
From: backup@contemporaryfusion.co.uk
Subject: Backup Notification

Note that this is an automated email,
and replying to it will get no response
The backup script has finished running.

Please note:
Script start: $SCRIPTCOMMENCE
Rsync finish:  $RSYNCFINISH
Tar Start: $TARSTART
Script finish: $SCRIPTFINISH
The Tape backedup: $BACKUPSIZE

Please check the logs in the /home/backup/logs/backup.$FILE.gz
on Backup Server for full details.
EOF
