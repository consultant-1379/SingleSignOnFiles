#!/bin/bash
ECHO=/bin/echo

##add check , ensure root when running first 

if [ $# -ne 1 ]; then
${ECHO} "please provide version of ISO e.g 1.0.14, 1.0.15, 1.0.16 "
${ECHO} "Example usage : `basename $0` 1.0.15 "
exit 1;
fi

TOR_RELEASE=$1
ISO_DIR=/var/tmp/toriso
ISO_RPM_DIR=${ISO_DIR}/products/TOR/${TOR_RELEASE}
TOR_RELEASE_WITH_UNDERSCRORES=`${ECHO} ${TOR_RELEASE} | sed 's/\./_/g'`
LITP_RPM_DIR=/var/www/html/products/TOR/${TOR_RELEASE_WITH_UNDERSCRORES}

umount ${ISO_DIR}

if [ $? -ne 0 ]; then
   ${ECHO} " problem unmounting ${ISO_DIR} , exiting"
   mount
   echo ""
   mount | grep  ${ISO_DIR}
   exit 1
fi

if [ `mount | grep -c ${ISO_DIR}` -gt 0 ]; then
${ECHO} " ${ISO_DIR} still  mounted, unmount it, before reusing mount point"
exit 1
fi


if [ -d ${ISO_RPM_DIR} ]; then
 ${ECHO} " removing ${ISO_RPM_DIR} "
 rm -rf ${ISO_ISO_DIR}/products/TOR/
fi


if [ -d ${LITP_RPM_DIR} ]; then
   ${ECHO} " removing ${LITP_RPM_DIR}"
   rm -rf  ${LITP_RPM_DIR}
fi

STATIC_RPM_DIR=/profiles/node-iso/custom/ 
cd ${STATIC_RPM_DIR}
${ECHO} " removing Static RPMs "
rm -f ERICprescontainer_CXP9030205-*.rpm ERIClauncher_CXP9030204-*.rpm ERIChelp_CXP9030287-*.rpm ERIClogin_CXP9030307-*.rpm ERIClogviewer_CXP9030285-*.rpm ERICdatapath_CXP9030305-*.rpm 

find / -name "ERICsingle*"
find / -name "ERICsso*"
find / -name "ERICsecurity*"
echo "${ISO_DIR}"; ls -l ${ISO_DIR}
echo "Deleting old ISO in ${ISO_DIR}"
rm -f ${ISO_DIR}/*.iso

