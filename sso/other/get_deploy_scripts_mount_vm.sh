#!/bin/bash

if [ $# -ne 1 ]; then
   echo "Usage $0 <url to iso/rpm on cifwk server> "
   exit 1
fi
LINK=$1
OUTPUT_FILE=`basename ${LINK}`
OUTPUT_DIR=/opt/ericsson/nms/litp/bin/deployment
service iptables stop
if [ `grep -c eselivm2v238l.lmera.ericsson.se /etc/hosts` -eq 0 ]; then
   echo "updating /etc/hosts with cifwk servers "
   echo "150.132.181.143 eselivm2v238l.lmera.ericsson.se" >> /etc/hosts
   echo "10.45.206.116 cifwk-oss.athtem.eei.ericsson.se" >> /etc/hosts
fi
mkdir -p ${OUTPUT_DIR}
curl "${LINK}" > ${OUTPUT_DIR}/${OUTPUT_FILE}
if [ -f ${OUTPUT_DIR}/${OUTPUT_FILE} ]; then
  cd ${OUTPUT_DIR}
  ls -l ${OUTPUT_DIR}/${OUTPUT_FILE}
  gtar -xvf ${OUTPUT_FILE}
else
  echo "Problem ${OUTPUT_DIR}/${OUTPUT_FILE} not found"
  exit 1
fi
mkdir -p ${OUTPUT_DIR}/sso
if [ `mount | grep -c ${OUTPUT_DIR}/sso` -gt 0 ]; then
   echo "directory already mounted ${OUTPUT_DIR}/sso"
else
mount -t nfs 10.45.18.219:/var/tmp/eeidwn_git_repo/SingleSignOnFiles/sso ${OUTPUT_DIR}/sso
fi
cd ${OUTPUT_DIR}/sso
ls
service iptables start
