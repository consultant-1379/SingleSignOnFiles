#!/bin/bash
if [ $# -ne 1 ]; then
echo "Enter path to llandscape to restore, exiting"
exit 1;
fi
FILE=$1
if [ ! -f ${FILE} ]; then
echo "${FILE} does not exist"
exit 1
fi
ls -l /var/lib/landscape
ls -l ${FILE}
service landscaped stop
cp ${FILE} /var/lib/landscape
#ssh sc-1 'cmw-partial-backup-restore --no-hostdata cmwbackup1' 
service landscaped start
ls -l /var/lib/landscape
