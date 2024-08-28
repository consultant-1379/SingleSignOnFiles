#!/bin/bash
ECHO=/bin/echo

##add check , ensure root when running first

if [ $# -ne 1 ]; then
    ${ECHO} "please provide path/filename of iso"
    ${ECHO} "Example usage : `basename $0` /var/tmp/ERICTor_abc.iso"
    exit 1;
fi

ISO_FILE=$1

EXTRA_PACKAGES_DIR=/var/tmp/pkgs_to_install
PREVIOUS_PACKAGES_DIR=/var/tmp/pkgs_to_install_old
PACKAGES_FROM_ISO_NOT_USED=/var/tmp/pkgs_from_iso_not_used

ISO_DIR=/var/tmp/toriso
LITP_TOR_DIR=/var/www/html/products/TOR/
STATIC_RPM_DIR=/profiles/node-iso/custom/

if [ ! -f ${ISO_FILE} ]; then
    ${ECHO} "${ISO_FILE} does not exist, exiting"
    exit 1
fi

if [ `mount | grep -c ${ISO_DIR}` -gt 0 ]; then
 ${ECHO} "${ISO_DIR} already mounted, unmounting it, before reusing mount point with latest ISO ${ISO_FILE}"
 umount ${ISO_DIR}
 if [ $? -ne 0 ]; then
   ${ECHO} " problem unmounting ${ISO_DIR} , exiting"
   mount | grep  ${ISO_DIR}
   exit 1
   fi
fi
if [ `mount | grep -c ${ISO_DIR}` -gt 0 ]; then
   ${ECHO} " ${ISO_DIR} still  mounted, unmount it, before reusing mount point, exiting"
   exit 1
fi

if [ -d ${LITP_TOR_DIR} ]; then
cd ${LITP_TOR_DIR}
EXISTING_TOR_RELEASE=`ls`
rm -rf ${LITP_TOR_DIR}/${EXISTING_TOR_RELEASE} 
fi

if [ ! -d ${ISO_DIR} ]; then
  ${ECHO} "Eexpected ISO directory does not exist , ${ISO_DIR} , creating now"
  mkdir -p ${ISO_DIR}
fi

echo "Deleting any existing ISOs and copying in new one into ${ISO_DIR}"
rm -f ${ISO_DIR}/*.iso
cp ${ISO_FILE} ${ISO_DIR}
ls -l ${ISO_DIR}

cd ${ISO_DIR}
if [ `ls -l | wc -l` -eq 0 ]; then
 echo "No iso files in Directory ${ISO_DIR} exiting"
 exit 1
fi

ISO=`ls *.iso`
${ECHO} "${ISO} found in ${ISO_DIR} "

echo "mounting the iso now with mount ${ISO} ${ISO_DIR} -o loop"
mount ${ISO} ${ISO_DIR} -o loop

echo "running litp import now litp /depmgr import ${ISO_DIR}"
litp /depmgr import ${ISO_DIR}

cd ${LITP_TOR_DIR}
TOR_RELEASE=`ls`
TOR_RELEASE_WITH_UNDERSCRORES=`${ECHO} ${TOR_RELEASE} | sed 's/\./_/g'`

#Update the TOR ISO Version to replace the "." with "_"
mv ${TOR_RELEASE} ${TOR_RELEASE_WITH_UNDERSCRORES}

#Add and packages in ${EXTRA_PACKAGES_DIR} to the onces just mounted
if [ -d ${EXTRA_PACKAGES_DIR} ]; then
cd ${EXTRA_PACKAGES_DIR}
  if [ `ls -l | wc -l` -gt 0 ]; then
   mkdir -p ${PACKAGES_FROM_ISO_NOT_USED}
   for RPM in `ls`; do
    ${ECHO} "Adding ${RPM} to ${LITP_TOR_DIR}/${TOR_RELEASE_WITH_UNDERSCRORES} for deployment "
    
    PRODUCT=`echo $RPM | cut -d- -f1`
    #move old package out
    mv ${LITP_TOR_DIR}/${TOR_RELEASE_WITH_UNDERSCRORES}/${PRODUCT}-* ${PACKAGES_FROM_ISO_NOT_USED}
    #copy new package in
    cp ${RPM} ${LITP_TOR_DIR}/${TOR_RELEASE_WITH_UNDERSCRORES} 
   done 
  fi
fi

cd ${LITP_TOR_DIR}/${TOR_RELEASE_WITH_UNDERSCRORES}
echo "copying Static content to  ${STATIC_RPM_DIR}"
cp ERICprescontainer_CXP9030205-*.rpm ERIClauncher_CXP9030204-*.rpm ERIChelp_CXP9030287-*.rpm ERIClogin_CXP9030307-*.rpm ERIClogviewer_CXP9030285-*.rpm ERICdatapath_CXP9030305-*.rpm ${STATIC_RPM_DIR}

cd ${STATIC_RPM_DIR}
ls -ltr ${STATIC_RPM_DIR} | tail -10
echo "creating repo"
createrepo .
echo "show mount point for ISO directory"
mount | grep ${ISO_DIR}
echo "Show SSO packages on file system"
find / -name "ERICsingle*"
find / -name "ERICssoapa*"
find / -name "ERICsecurity*"
find / -name "ERICssologger*"
find / -name "ERICps*"


