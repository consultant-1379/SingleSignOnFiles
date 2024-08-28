#!/bin/bash
ECHO=/bin/echo

##add check , ensure root when running first

if [ $# -ne 1 ]; then
    ${ECHO} "please provide path/filename of iso"
    ${ECHO} "Example usage : `basename $0` /var/tmp/ERICTor_abc.iso"
    exit 1;
fi

ISO_FILE=$1

RPM_PACKAGES_DIR=/var/tmp/rpms_to_add_to_iso
ISO_DIR=/var/tmp/isorebuild
TARGET_ISO_DIR=/var/tmp/temp_isorebuild/temporary_rpms

#ISO_DIR=/var/tmp/tor/tor_iso
#TARGET_ISO_DIR=/var/tmp/tor/test

if [ ! -f ${ISO_FILE} ]; then
    ${ECHO} "${ISO_FILE} does not exist, exiting"
    exit 1
fi

if [ ! -d ${RPM_PACKAGES_DIR} ]; then
  ${ECHO} "Expected RPM directory does not exist , ${RPM_PACKAGES_DIR} , exiting"
  exit 1
fi

if [ -d ${TARGET_ISO_DIR} ]; then
  ${ECHO} "Deleting old temporary target directory  ${TARGET_ISO_DIR} , creating new one now"
  rm -rf ${TARGET_ISO_DIR}
fi
mkdir -p ${TARGET_ISO_DIR}


cd ${RPM_PACKAGES_DIR}
if [ `ls | wc -l` -eq 0 ]; then
 echo "No new RPM files in Directory ${RPM_PACKAGES_DIR} exiting"
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
   ${ECHO} " ${ISO_DIR} still mounted, unmount it, before reusing mount point, exiting"
   exit 1
fi

if [ -d ${ISO_DIR} ]; then
  ${ECHO} "Expected ISO directory does exist , ${ISO_DIR} , deleteing "
  rm -rf ${ISO_DIR}
fi
  ${ECHO} "Creating new ISO directory ${ISO_DIR} "
  mkdir -p ${ISO_DIR}

echo "mounting $ISO_FILE on ${ISO_DIR}"
mount -o loop $ISO_FILE ${ISO_DIR}/
cd ${ISO_DIR}/products/TOR/
DROP=`ls`
SOURCE_DIR=${ISO_DIR}/products/TOR/${DROP}/
TARGET_DIR=${TARGET_ISO_DIR}/products/TOR/${DROP}
if [ -d ${TARGET_DIR} ]; then
  ${ECHO} "Deleting old temporary target directory  ${TARGET_DIR}"
  rm -rf ${TARGET_DIR}
fi
mkdir -p ${TARGET_DIR}

echo "creating temporary target directory  ${TARGET_DIR}"
mkdir -p ${TARGET_DIR}
echo "Copy all RPMs from ISO to ${TARGET_DIR}"
cp ${SOURCE_DIR}/* ${TARGET_DIR}

${ECHO} "Will attempt to delete the older version from the target directory ${RPM} ${TARGET_DIR}"
cd ${RPM_PACKAGES_DIR}
  for RPM in `ls`; do
    PRODUCT=`echo $RPM | cut -d- -f1`
    echo "Deleting ${PRODUCT} from target directory "
    rm -f ${TARGET_DIR}/${PRODUCT}-*
    echo "Copying ${RPM} to target directory "
    cp ${RPM} ${TARGET_DIR}
  done

cp ${ISO_FILE} ${ISO_FILE}.bak
mkisofs -r -o ${ISO_FILE} ${TARGET_ISO_DIR}
ls -l ${ISO_FILE}
#cp -i $ISO_FILE /var/tmp/tor
#ls -l /var/tmp/tor/*.iso

echo "show mount point for ISO directory"
mount | grep ${ISO_DIR}
#echo "Show packages on file system"
#find / -name "ERICsingle*"
#find / -name "ERICssoapa*"
#find / -name "ERICsecurity*"
#find / -name "ERICssologger*"
#find / -name "ERICps*"

