#!/bin/bash
echo "Backing up the landscape before calling runtime"
if [ $# -ne 2 ]; then
    echo "Enter file to backup and path/filename to copy it to, exiting"
    exit 1
fi
FILE_TO_BACKUP=$1
BACKUP_FILE=$2

#BACKUP_DIR=/var/tmp/LAST_KNOWN_CONFIG
#FILE_TO_BACKUP=/var/lib/landscape/LAST_KNOWN_CONFIG

if [ ! -f ${FILE_TO_BACKUP} ]; then
  echo "  problem : ${FILE_TO_BACKUP} does not exist, exiting "
  exit 1
fi

#\ use unaliased version of cp (dont want cp -i) from alias
\cp ${FILE_TO_BACKUP} ${BACKUP_FILE}
if [ $? -eq 0 ]; then
   echo "${FILE_TO_BACKUP} copied to ${BACKUP_FILE}"
   ls -l ${BACKUP_FILE}
   exit 0
else
    echo "problem copying ${FILE_TO_BACKUP}, return code from cp not zero , exiting "
    exit 1
fi

