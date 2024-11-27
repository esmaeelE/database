#!/bin/bash

###############################################################################
###############################################################################
###                                                                           #
###                     This is product                                       #
###                                                                           #
###############################################################################
###############################################################################

###############################################################################
#   Script Name         : backup_mariadb.sh
#   Description         : Create backup from database
#                       : store in separate .gz file and logs
#
#                       Scheduled to run with crontab
#                       see with: crontab -l
#   Creation Date       : 2024 02 04
#   Author              : Esmaeel
#
###############################################################################
## crontab -l
# 15 00 * * * bash /opt/scripts/run/backup_mariadb.sh 1 >> /opt/scripts/logs/log_backup_mariaddb  2>> /opt/scripts/logs/error_backup_mariaddb


###############################################################################
#   Global Variables
###############################################################################
#   DATE                       : USE CURRENT DATE 
#   DESTINATION                : Set DEST_PATH to store files
#   
###############################################################################

DATE=$(date +%Y%m%d_%H%M%S)
DEST_PATH="/home/BACKUP/ARCHIVE/"
DESTINATION="$DEST_PATH/archive"
SEND="$DEST_PATH/send"
SECRET="/opt/scripts/run/secrets/root@localhost.cnf"
BACKUP_DIR="/home/BACKUP/ARCHIVE/send"

KEEP_DAY=10

###############################################################################
#   NAME          : LOGGER
#   ARGUMENTS     : Read all arguments inside with $@
#   WORK          : PRINT $DATE BEFORE ANY MESSAGE
#   USAGE         : LOGGER this is test message
#   OUTPUT        : 20230515 10:20:27 -- this is test message
###############################################################################
function LOGGER {

    echo "$(/usr/bin/date +%Y%m%d_%H%M%S)" "$@";
    #echo $@ | awk '{ printf strftime ("[%Y-%m-%d %H:%M:%S] ")}'
    #errcho $(date +%Y%m%d" "%H:%M:%S) -- $@
}


LOGGER "START RUNNIG BACKUP PROCEDURE ..." ${DESTINATION}, ${SEND}, ${SECRET}

/usr/bin/mkdir -p $DESTINATION $SEND

LOGGER running dump database ...

# Create backup with mariadb-dump and zip output
/usr/bin/mariadb --defaults-extra-file=$SECRET -N -e 'show databases'  | \
while read dbname; do 
LOGGER  dumpping  "$dbname" ; 
/usr/bin/mariadb-dump \
			--defaults-extra-file=$SECRET \
			--complete-insert --routines --triggers --single-transaction \
			--databases "$dbname" | \
/usr/bin/gzip -c -9 > "$DESTINATION/$dbname"_"$DATE".sql.gz;
done

LOGGER "END running dump database ..."
LOGGER "Creating tar archive from separated .gz dumps ..."

# dont preserve directory structure and remove source files 
/usr/bin/tar -cvf $SEND/$DATE.tar -C $DESTINATION/ --remove-files .

LOGGER "Sending $DATE.tar to remote server ..."

# copy archive file to remote server
/usr/bin/scp $SEND/$DATE.tar user@1.1.1.1:/var/archive/tar

# extract files
# tar xvf 20240204_110754.tar -C extract/

LOGGER "***END BACKUP PROCEDURE***"

# Delete old backups
# /usr/bin/find $BACKUP_DIR -mtime +$KEEP_DAY -delete


