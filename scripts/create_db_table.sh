#!/bin/bash

###############################################################################
###############################################################################
###                                                                           #
###                                                                           #
###                                                                           #
###############################################################################
###############################################################################

###############################################################################
#   Script Name         : create_db_table.sh
#   Description         : Create db and table inside it 
#                       : store in .dmp file and logs
#
#   Creation Date       : 2024 02 05
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


while IFS="" read -r p || [ -n "$p" ]
do
    # $p: file name in full path   
    # get file_name and date

    db_name=$(basename "${p}")
    # echo dbname is: $db_name

    mariadb --defaults-extra-file=connection.cnf -e "CREATE DATABASE IF NOT EXISTS $db_name"  
     
    # check return value 
    retVal=$? 
    if [ $retVal -ne 0 ]; then
    	echo "Error Create Database" $db_name
    	exit $retVal
    fi

    mariadb --defaults-extra-file=connection.cnf $db_name < create_tables.sql
   
    # check return value 
    retVal=$? 
    if [ $retVal -ne 0 ]; then
    	echo "Error Create Table inside" $db_name
    	exit $retVal
    fi

done < db_names.txt
