#!/bin/bash

###############################################################################
###############################################################################
###                                                                           #
###                                                                           #
###                                                                           #
###############################################################################
###############################################################################

###############################################################################
#   Script Name         : restore.sh
#   Description         : restore tar.gz archive to db
#                       : store in .dmp file and logs
#
#   Creation Date       : 2024 02 06
#   Author              : Esmaeel
#
#   When this script fail critical error occured!
#
###############################################################################

###############################################################################
#   Global Variables
###############################################################################
#   ORACLE_SID                 : Set ORACLE_SID
#   ORACLE_HOME                : Set ORACLE_HOME environment variable
#   timetag                    : Get current date to use in file name
###############################################################################

# Run
# bash restore.sh 20240204_124111.tar
#

# Unzip file
TARFILE=$1
SOURCE="extract/"

mkdir -p $SOURCE

if [ -z "${TARFILE}" ]; then
    echo "tar file is empty "
    exit 1
fi

echo "now extract ...", $TARFILE, $SOURCE

#Extract files 
tar xvf $TARFILE -C $SOURCE

# load files name to memory
files=$(ls -1U $SOURCE | grep -E "\.gz$" )

for item in ${files}; do
	#echo $item;
  # preserve gz source files.
	yes n | gunzip -k $SOURCE/$item 
	FILENAME="${item%.*}"
	echo $FILENAME
  mariadb --defaults-extra-file=secrets/root@localhost.cnf < $SOURCE/$FILENAME
done
