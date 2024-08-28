#!/bin/bash
AWK=/bin/awk
SSH=/usr/bin/ssh
SCP=/usr/bin/scp
ECHO=/bin/echo

BASEDIR=$(/usr/bin/dirname $0)
PEER_NODES="SC-1 SC-2"
SCRIPT=cleanup_logs.sh

SCRIPT_LOCAL_PATH=${BASEDIR}/${SCRIPT}
SCRIPT_PEER_PATH=/var/tmp/${SCRIPT}

TEMP_CRONTAB_FILE=/var/tmp/crontab.update

for node in ${PEER_NODES};
do

$SCP ${SCRIPT_LOCAL_PATH} ${node}:${SCRIPT_PEER_PATH}
$SSH ${node} "chmod +x ${SCRIPT_PEER_PATH};crontab -l > ${TEMP_CRONTAB_FILE}"
$SSH ${node} "echo 0 \* \* \* \* ${SCRIPT_PEER_PATH} >> ${TEMP_CRONTAB_FILE}"
$SSH ${node} "crontab ${TEMP_CRONTAB_FILE};crontab -l"

done

 
