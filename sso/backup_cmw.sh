#!/bin/bash
if [ $# -ne 2 ]; then
   echo " Enter start number and end number of backups to take , exiting"
   exit 1
fi

WORKING_DIR=$(/usr/bin/dirname $0)
WORKING_DIR=$(cd ${WORKING_DIR} ; pwd)
PROPERTIES_FILE=${WORKING_DIR}/properties.deploy

if [ ! -f ${PROPERTIES_FILE} ]; then
    echo "problem *********** :  ${PROPERTIES_FILE} is missing, exiting  "
    exit 1
fi
. ${PROPERTIES_FILE}

echo "Attempting to create backups cmwbackup${START} to cmwbackup${END} on ${PEER1}"

START=$1
END=$2

echo "Following backups already exist"
ssh ${PEER1} 'cmw-partial-backup-list'

for (( NUM=${START}; NUM<=${END}; NUM++ ))
do
       echo  "ssh ${PEER1} cmw-partial-backup-create --no-hostdata cmwbackup${NUM} "
       ssh ${PEER1} "cmw-partial-backup-create --no-hostdata cmwbackup${NUM}"
done

ssh ${PEER1} 'cmw-partial-backup-list'
