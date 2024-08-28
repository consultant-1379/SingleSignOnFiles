#!/bin/bash
ECHO=/bin/echo

##add check , ensure root when running first

RPM_PACKAGES_DIR=/var/tmp/oasis/rpms
EAR_FILES_DIR=/var/tmp/oasis/ears

if [ ! -d ${RPM_PACKAGES_DIR} ]; then
  ${ECHO} "Expected RPM directory does not exist , ${RPM_PACKAGES_DIR} , exiting"
  exit 1
fi
cd ${RPM_PACKAGES_DIR}
if [ `ls | wc -l` -eq 0 ]; then
 echo "No RPM files in Directory ${RPM_PACKAGES_DIR} exiting"
 exit 1
fi

if [ -d ${EAR_FILES_DIR} ]; then
  ${ECHO} "Deleting existing RPM directory for extracted files , ${EAR_FILES_DIR}"
  rm -rf ${EAR_FILES_DIR}
fi
${ECHO} "Creating RPM directory for extracted files , ${EAR_FILES_DIR}"
mkdir -p ${EAR_FILES_DIR}

echo "Copying RPMs into ${EAR_FILES_DIR} from ${RPM_PACKAGES_DIR}"
echo ${RPM_PACKAGES_DIR}
ls -l ${RPM_PACKAGES_DIR}
cp ${RPM_PACKAGES_DIR}/* ${EAR_FILES_DIR}
echo ${EAR_FILES_DIR}
ls -l ${EAR_FILES_DIR}
cd ${EAR_FILES_DIR}

echo "Extracting EAR file from RPM"
for RPM in `ls`; do
    PRODUCT=`echo $RPM | cut -d- -f1`
    echo "Creating ${PRODUCT} directory "
    mkdir ${PRODUCT}
    mv ${RPM} ${PRODUCT}
    cd ${PRODUCT}
    /usr/bin/rpm2cpio ${RPM} | /bin/cpio -idmv
    EAR=`/bin/find . -name *.ear`
    echo "Found EAR file ${EAR}, copying to ${EAR_FILES_DIR}"
    cp ${EAR} ${EAR_FILES_DIR}
    cd ${EAR_FILES_DIR}
    echo "deleting temporary extracted files directory ${PRODUCT}"
    rm -rf ${PRODUCT}
done

SSH=/usr/bin/ssh
SCP=/usr/bin/scp

cd ${EAR_FILES_DIR}

for node in SC-1 SC-2;
do
   ${SSH} ${node} "mkdir -p ${EAR_FILES_DIR}"
   ${SCP} ${EAR_FILES_DIR}/*.ear ${node}:${EAR_FILES_DIR} 
   echo "EAR files on $node "
   ${SSH} ${node} "ls -l ${EAR_FILES_DIR}"
done
