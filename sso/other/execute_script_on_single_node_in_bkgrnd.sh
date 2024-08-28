#!/bin/bash
ECHO=/bin/echo
SSH=/usr/bin/ssh
SCP=/usr/bin/scp

if [ $# -lt 2 ]; then
  echo "Usage: `basename $0` : Node to execute script on, name of script to execute, and optional arguments , exiting"
  exit 1
fi

NODE=${1}
SCRIPT=${2}
shift
shift
echo $@

SCRIPT_LOCATION=/var/tmp/

if [ ! -r ${SCRIPT} ]; then
    ${ECHO} "Cant find script ${SCRIPT} to copy to nodes and execute"
fi

for node in ${NODE};
do
   ${SCP} ./${SCRIPT} ${node}:${SCRIPT_LOCATION}
   ${SSH} ${node} "chmod +x ${SCRIPT_LOCATION}${SCRIPT}"
   ${SSH} ${node} "ls -l ${SCRIPT_LOCATION}${SCRIPT}"
  # ${SSH} ${node} "bash ${SCRIPT_LOCATION}${SCRIPT} $@"

  COMMAND="${SSH} ${node} 'nohup ${SCRIPT_LOCATION}${SCRIPT} $@ > /dev/null 2>&1 &'"
  eval ${COMMAND}
  ${SSH} ${node} "ps -ef | grep ${SCRIPT}"
done
