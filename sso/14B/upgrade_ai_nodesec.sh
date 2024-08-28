#!/bin/bash
ECHO=/bin/echo

UPGRADE_SOURCE=/var/tmp/oasis/ai_new_upgrade_pkgs
LITP_TOR_DIR=/var/www/html/products/TOR/
UPGRADE_TARGET_DIR=`ls ${LITP_TOR_DIR} | grep -v _`

if [ ! -d ${UPGRADE_SOURCE} ]; then
        ${ECHO} "Put the packages to upgrade to into the ${UPGRADE_SOURCE} directory"
        exit 1
fi

if [ `ls ${UPGRADE_SOURCE} | grep 'ERICaicore\|ERICaiweb\|ERICnodesecurity' | wc -l` -eq 0 ]; then
        ${ECHO} "No packages in ${UPGRADE_SOURCE} directory, exiting, put the packages to upgrade to in ${UPGRADE_SOURCE} directory"
        exit 1
fi

${ECHO} "Copying packages to ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR}"
ls ${UPGRADE_SOURCE}/*
cp -f ${UPGRADE_SOURCE}/* ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR}

if litp /depmgr/upgrade_ai/ show > /dev/null 2>&1; then
        ${ECHO} "Cleaning up previous upgrade_ai plan"
        litp /depmgr/upgrade_ai/ cleanup -f
fi

date=`/bin/date +%Y%m%d_%H%M%S`
${ECHO} "Taking a copy of the LAST_KNOWN_CONFIG copying file to /var/tmp/LAST_KNOWN_CONFIG_${date}"
cp /var/lib/landscape/LAST_KNOWN_CONFIG /var/tmp/LAST_KNOWN_CONFIG_${date} 2>&1 1>/dev/null

cd ${UPGRADE_SOURCE}
PRODUCT_TO_UPGRADE=ERICaicore
if [ `ls ${UPGRADE_SOURCE} | grep -c ${PRODUCT_TO_UPGRADE}` -ne 0 ]; then
      #aicore_svc
      LITP_PRODUCT=`echo ${PRODUCT_TO_UPGRADE} | sed s/ERIC//g`_svc   
      EAR=ai-core
      NEW_VERSION=`ls ${UPGRADE_SOURCE} | grep ${PRODUCT_TO_UPGRADE} | cut -d- -f2 | sed s/.rpm//g`
      INSTALL_SOURCE=/opt/ericsson/com.ericsson.nms.security/${EAR}-ear-${NEW_VERSION}.ear
      
      ${ECHO} -e "Pre-upgrade versions of ${PRODUCT_TO_UPGRADE}"
      ${ECHO} -e " Upgrading ${PRODUCT_TO_UPGRADE} to ${NEW_VERSION} \n"

      litp /definition/tor_sw/${LITP_PRODUCT}/aicore_de/ show
      litp /definition/tor_sw/${LITP_PRODUCT}/aicore_pkg/ show

      litp /definition/tor_sw/${LITP_PRODUCT}/aicore_de/  update version="${NEW_VERSION}" install-source="${INSTALL_SOURCE}" name="${EAR}-ear-${NEW_VERSION}.ear"

      litp /definition/tor_sw/${LITP_PRODUCT}/aicore_pkg/ update version="${NEW_VERSION}"

fi      

PRODUCT_TO_UPGRADE=ERICaiweb
if [ `ls ${UPGRADE_SOURCE} | grep -c ${PRODUCT_TO_UPGRADE}` -ne 0 ]; then
      #aiweb_svc
      LITP_PRODUCT=`echo ${PRODUCT_TO_UPGRADE} | sed s/ERIC//g`_svc   
      EAR=ai-web
      NEW_VERSION=`ls ${UPGRADE_SOURCE} | grep ${PRODUCT_TO_UPGRADE} | cut -d- -f2 | sed s/.rpm//g`
      INSTALL_SOURCE=/opt/ericsson/com.ericsson.nms.security/${EAR}-ear-${NEW_VERSION}.ear

      ${ECHO} -e "Pre-upgrade versions of ${PRODUCT_TO_UPGRADE}"
      ${ECHO} -e " Upgrading ${PRODUCT_TO_UPGRADE} to ${NEW_VERSION} \n"
      
      litp /definition/tor_sw/${LITP_PRODUCT}/aiweb_de/ show
      litp /definition/tor_sw/${LITP_PRODUCT}/aiweb_pkg/ show

      litp /definition/tor_sw/${LITP_PRODUCT}/aiweb_de/  update version="${NEW_VERSION}" install-source="${INSTALL_SOURCE}" name="${EAR}-ear-${NEW_VERSION}.ear"
      litp /definition/tor_sw/${LITP_PRODUCT}/aiweb_pkg/ update version="${NEW_VERSION}"

fi      
 
PRODUCT_TO_UPGRADE=ERICnodesec
if [ `ls ${UPGRADE_SOURCE} | grep -c ${PRODUCT_TO_UPGRADE}` -ne 0 ]; then
      #nodesec_svc
      LITP_PRODUCT=`echo ${PRODUCT_TO_UPGRADE} | sed s/ERIC//g`_svc
      EAR=node-security
      NEW_VERSION=`ls ${UPGRADE_SOURCE} | grep ${PRODUCT_TO_UPGRADE} | cut -d- -f2 | sed s/.rpm//g`
      INSTALL_SOURCE=/opt/ericsson/com.ericsson.nms.security.nscs/${EAR}-ear-${NEW_VERSION}.ear

      ${ECHO} -e "Pre-upgrade versions of ${PRODUCT_TO_UPGRADE}"
      ${ECHO} -e " Upgrading ${PRODUCT_TO_UPGRADE} to ${NEW_VERSION} \n"

      litp /definition/tor_sw/${LITP_PRODUCT}/nodesec_de/ show
      litp /definition/tor_sw/${LITP_PRODUCT}/nodesec_pkg/ show

      litp /definition/tor_sw/${LITP_PRODUCT}/nodesec_de/  update version="${NEW_VERSION}" install-source="${INSTALL_SOURCE}" name="${EAR}-ear-${NEW_VERSION}.ear"
      litp /definition/tor_sw/${LITP_PRODUCT}/nodesec_pkg/ update version="${NEW_VERSION}"

fi

${ECHO} -e "Prepare and plan the Upgrade\n"
litp /depmgr prepare upgrade_ai scope=/inventory
litp /depmgr/upgrade_ai/ plan

${ECHO} -e "Here is the plan for Upgrade\n"
litp /depmgr/upgrade_ai/ show plan -v

${ECHO} -e "Delete Verify and LVM snapshot tasks as not needed"
#litp /depmgr/upgrade_ai/upgrade_plan/task_00/ delete
#litp /depmgr/upgrade_ai/upgrade_plan/task_20/ delete
#litp /depmgr/upgrade_ai/upgrade_plan/task_30/ delete
#litp /depmgr/upgrade_ai/upgrade_plan/task_40/ delete
#litp /depmgr/upgrade_ai/upgrade_plan/task_50/ delete

${ECHO} -e "Here is the updated plan for Upgrade\n"
litp /depmgr/upgrade_ai/ show plan -v

${ECHO} -e "Delete all verify, feedback and sanity checks from the plan to speed up upgrade"
${ECHO} -e "Then run this command - litp /depmgr/upgrade_ai/ start"
exit 0

${ECHO} -e "Starting the Upgrade...\n"
litp /depmgr/upgrade_ai/ start


PRODUCT_TO_UPGRADE=ERICaicore
LITP_PRODUCT=`echo ${PRODUCT_TO_UPGRADE} | sed s/ERIC//g`_svc   
${ECHO} -e "Post-upgrade versions of ${PRODUCT_TO_UPGRADE}"
litp /definition/tor_sw/${LITP_PRODUCT}/aicore_de/ show
litp /definition/tor_sw/${LITP_PRODUCT}/aicore_pkg/ show

PRODUCT_TO_UPGRADE=ERICaiweb
LITP_PRODUCT=`echo ${PRODUCT_TO_UPGRADE} | sed s/ERIC//g`_svc   
${ECHO} -e "Post-upgrade versions of ${PRODUCT_TO_UPGRADE}"
litp /definition/tor_sw/${LITP_PRODUCT}/aiweb_de/ show
litp /definition/tor_sw/${LITP_PRODUCT}/aiweb_pkg/ show

PRODUCT_TO_UPGRADE=ERICnodesec
LITP_PRODUCT=`echo ${PRODUCT_TO_UPGRADE} | sed s/ERIC//g`_svc   
${ECHO} -e "Post-upgrade versions of ${PRODUCT_TO_UPGRADE}"
litp /definition/tor_sw/${LITP_PRODUCT}/nodesec_de/ show
litp /definition/tor_sw/${LITP_PRODUCT}/nodesec_pkg/ show
