#!/bin/bash

#
# This sample script contains the commands used for a LITP installation applying
# to the landscape the boot manager part for the following configuration:
#
# Type: Single-Blade
#

# Find my current dir
BASEDIR=$(/usr/bin/dirname $0)
# NOTE: This behaviour relies on shell builtins for cd and pwd
BASEDIR=$(cd ${BASEDIR}/.. ; pwd)
[ -f ${BASEDIR}/etc/global.env ] && . ${BASEDIR}/etc/global.env
initLogging deploy.log

# Execute the definition

${BASEDIR}/bin/definition.sh $* || error "Failed to execute definition"
# Execute the inventory
${BASEDIR}/bin/inventory.sh $* || error "Failed to execute the inventory"

# Execute the boot manager
${BASEDIR}/bin/boot.sh $* || error "Failed to run boot manager"
if [ -z "${NAS_SERVER_IP}" ] ; then
   # Apply single-node VCS script for extra NICs
    ${BASEDIR}/bin/single-node-vcs.sh $* || error " failed to add extra VCS NICs"
fi
echo "Please allow ~40 minutes, for the Peer Nodes to boot and install"
# Execute runtime script
${BASEDIR}/sso/backup_landscape.sh /var/lib/landscape/LAST_KNOWN_CONFIG /var/tmp/LAST_KNOWN_CONFIG
${BASEDIR}/bin/runtime.sh $* || error "Failed to execute runtime"
echo "Waiting for user to update packages and continue with runtime scripts"
exit

echo "adding log cleanup to crontab on peer nodes"
${BASEDIR}/sso/add_cleanup_logs_to_crontab.sh || error "Failed to update crontab on peer nodes"
echo "create certs for nodes using Apache FQDN"
${BASEDIR}/sso/sso_create_certs.sh || error "Failed to create gather all needed certs"
echo "create sso properties file"
${BASEDIR}/sso/sso_create_sso_property_file_1_0_18.sh || error "Failed to create sso properties file"
echo " Executing SSO environment script"
${BASEDIR}/sso/sso_preinstall-steps-sp27.sh || error "Failed to execute SSO environment script"
echo "configure aliases and vim colours"
${BASEDIR}/sso/setup.sh nodes
echo "backing up cmw"
${BASEDIR}/sso/backup_cmw.sh 1 4
echo "creating UI Property file for this infra,uas we are using and copying to peer nodes"
${BASEDIR}/sso/sso_create_ui_property_file_1_0_18.sh

${BASEDIR}/bin/campaign_generation.sh $* || error "Failed to execute campaign Generation"
echo "DEPLOYMENT COMPLETE"

echo "running post install checks on nodes"
${BASEDIR}/sso/execute_script_on_nodes.sh ${BASEDIR}/sso/sso_post_install_check.sh ssouser ssouser01
