#!/bin/bash
ECHO=/bin/echo

##add check , ensure root when running first

UPGRADE_SOURCE=/var/tmp/sso_upgrade_pkgs

LITP_TOR_DIR=/var/www/html/products/TOR/
UPGRADE_TARGET_DIR=`ls ${LITP_TOR_DIR}`

if [ ! -d ${UPGRADE_SOURCE} ]; then
        ${ECHO} "Put the packages to upgrade to into the ${UPGRADE_SOURCE} directory"
        exit 1
fi

if [ `ls ${UPGRADE_SOURCE} | grep 'ERICsecurity\|ERICsso\|ERICsingle' | wc -l` -eq 0 ]; then
        ${ECHO} "No SSO packages in ${UPGRADE_SOURCE} directory, exiting, put the packages to upgrade to in ${UPGRADE_SOURCE} directory"
        exit 1
fi

${ECHO} "Copying SSO packages to ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR}"
ls ${UPGRADE_SOURCE}/*
cp -f ${UPGRADE_SOURCE}/* ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR}



#if [[ `litp /depmgr/upgrade_sso/ show > /dev/null 2>&1` == 0 ]]; then
if litp /depmgr/upgrade_sso/ show > /dev/null 2>&1; then
        ${ECHO} "Cleaning up previous upgrade_sso plan"
        litp /depmgr/upgrade_sso/ cleanup -f
fi

if [ `ls ${UPGRADE_SOURCE} | grep -c ERICsecurity` -ne 0 ]; then

  NEW_SECURITY_SERVICE_VERSION=`ls ${UPGRADE_SOURCE} | grep ERICsecurity | cut -d- -f2 | sed s/.rpm//g`
  ${ECHO} -e "Pre-upgrade versions of Security Service"
  litp /definition/security_svc/de/ show
  litp /definition/security_svc/pkg/ show
  ${ECHO} -e "Upgrading Security Service to ${NEW_SECURITY_SERVICE_VERSION} \n"
  litp /definition/security_svc/de/ update version="${NEW_SECURITY_SERVICE_VERSION}" install-source="/opt/ericsson/com.ericsson.nms.services/SecurityService-ear-${NEW_SECURITY_SERVICE_VERSION}.ear" name="SecurityService-ear-${NEW_SECURITY_SERVICE_VERSION}.ear"
  litp /definition/security_svc/pkg/ update version="${NEW_SECURITY_SERVICE_VERSION}"

fi

if [ `ls ${UPGRADE_SOURCE} | grep -c ERICssoapa` -ne 0 ]; then

  NEW_POLICY_AGENT_VERSION=`ls ${UPGRADE_SOURCE} | grep ERICssoapa | cut -d- -f2 | sed s/.rpm//g`
  ${ECHO} -e "Pre-upgrade version Policy Agent\n"
  litp /definition/httpd_comp/sso_pa_pkg/ show
  ${ECHO} -e "Upgrading Policy Agent to ${NEW_POLICY_AGENT_VERSION} \n"
  litp /definition/httpd_comp/sso_pa_pkg/ update version="${NEW_POLICY_AGENT_VERSION}"

fi

if [ `ls ${UPGRADE_SOURCE} | grep -c ERICsingle` -ne 0 ]; then

  NEW_SINGLE_SIGN_ON_VERSION=`ls ${UPGRADE_SOURCE} | grep ERICsingle | cut -d- -f2 | sed s/.rpm//g`
  ${ECHO} -e "Pre-upgrade versions of SSO\n"
  litp /definition/sso/pkg/ show
  litp /definition/sso/de/ show
  ${ECHO} -e "Upgrading Single Sign to ${NEW_SINGLE_SIGN_ON_VERSION} \n"
  litp /definition/sso/pkg/ update version="${NEW_SINGLE_SIGN_ON_VERSION}"
  litp /definition/sso/de/ update version="${NEW_SINGLE_SIGN_ON_VERSION}"
fi

if [ `ls ${UPGRADE_SOURCE} | grep -c ERICssologger` -ne 0 ]; then

  NEW_LOGGER_VERSION=`ls ${UPGRADE_SOURCE} | grep ERICssologger | cut -d- -f2 | sed s/.rpm//g`
  ${ECHO} -e "Pre-upgrade version of SSO Logger\n"
  litp /definition/ssologger/ssologger_pkg/ show
  ${ECHO} -e "Upgrading SSO logger to ${NEW_LOGGER_VERSION} \n"
  litp /definition/ssologger/ssologger_pkg/ update version="${NEW_LOGGER_VERSION}"

fi

${ECHO} -e "Prepare and plan the SSO Upgrade\n"
litp /depmgr prepare upgrade_sso scope=/inventory
litp /depmgr/upgrade_sso/ plan

${ECHO} -e "Here is the plan for SSO Upgrade\n"
litp /depmgr/upgrade_sso/ show plan -v

${ECHO} -e "Delete Verify and LVM snapshot tasks as not needed"
litp /depmgr/upgrade_sso/upgrade_plan/task_00/ delete
litp /depmgr/upgrade_sso/upgrade_plan/task_10/ delete
litp /depmgr/upgrade_sso/upgrade_plan/task_20/ delete
litp /depmgr/upgrade_sso/upgrade_plan/task_30/ delete

${ECHO} -e "Here is the updated plan for SSO Upgrade\n"
litp /depmgr/upgrade_sso/ show plan -v


${ECHO} -e "Starting the Upgrade...\n"
litp /depmgr/upgrade_sso/ start

${ECHO} -e "Post-upgrade versions of Security Service"
litp /definition/security_svc/de/ show
litp /definition/security_svc/pkg/ show

${ECHO} -e "Post-upgrade version Policy Agent\n"
litp /definition/httpd_comp/sso_pa_pkg/ show

${ECHO} -e "Post-upgrade version of SSO Logger\n"
litp /definition/ssologger/ssologger_pkg/ show

${ECHO} -e "Post-upgrade versions of SSO\n"
litp /definition/sso/pkg/ show
litp /definition/sso/de/ show
