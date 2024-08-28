#!/bin/bash
ECHO=/bin/echo
SSH=/usr/bin/ssh
SCP=/usr/bin/scp

if [ $# -lt 1 ]; then
  echo "Usage: `basename $0` : name of scrip to execute, and optional arguments , exiting"
  exit 1
fi

SCRIPT=${1}
shift
echo $@

SCRIPT_LOCATION=/var/tmp/
TARGET_SCRIPT=${SCRIPT_LOCATION}`basename ${SCRIPT}`

if [ ! -r ${SCRIPT} ]; then
    ${ECHO} "Cant find script ${SCRIPT} to copy to nodes and execute"
fi

for node in SC-1 SC-2;
do
   ${SCP} ${SCRIPT} ${node}:${SCRIPT_LOCATION}
   ${SSH} ${node} "chmod +x ${TARGET_SCRIPT}"
   ${SSH} ${node} "ls -l ${TARGET_SCRIPT}"
   COMMAND="${SSH} ${node} 'bash ${TARGET_SCRIPT} $@'"
   eval ${COMMAND}
done
