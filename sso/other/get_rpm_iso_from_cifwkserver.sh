#!/bin/bash

if [ $# -ne 2 ]; then 
   echo "Usage $0 <url to iso/rpm on cifwk server> <directory to store it in>"
   exit 1
fi
# if [ ipltables  | grep 8081 ]   checkport is open
LINK=$1
OUTPUT_FILE=`basename ${LINK}`
TARGET_DIR=$2
EXTRA_PACKAGES_DIR=/var/tmp/pkgs_to_install
if [ ! -d ${EXTRA_PACKAGES_DIR} ]; then
   mkdir -p ${EXTRA_PACKAGES_DIR}
fi
if [ ! -d ${TARGET_DIR} ]; then
   mkdir -p ${TARGET_DIR}
fi

service iptables stop
if [ `grep -c eselivm2v238l.lmera.ericsson.se /etc/hosts` -eq 0 ]; then
   echo "updating /etc/hosts with cifwk servers "
   echo "150.132.181.143 eselivm2v238l.lmera.ericsson.se" >> /etc/hosts
   echo "10.45.206.116 cifwk-oss.athtem.eei.ericsson.se" >> /etc/hosts
fi
curl "${LINK}" > ${TARGET_DIR}/${OUTPUT_FILE}
ls -l ${TARGET_DIR}/${OUTPUT_FILE}
service iptables start
