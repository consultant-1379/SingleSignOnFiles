#!/bin/bash

check_file_exists()
{
FILE=$1
if [ ! -r ${FILE} ]; then
	echo "PROBLEM: File ${FILE} does not exist, exiting "
	exit 1
fi
}

delete_file_if_exists()
{
FILE=$1
if [ -r ${FILE} ]; then
	rm -f ${FILE} 
fi
}
##########################################################################################

#MAIN SCRIPT

##########################################################################################

WORKING_DIR=$(/usr/bin/dirname $0)
WORKING_DIR=$(cd ${WORKING_DIR} ; pwd)
PROPERTIES_FILE=${WORKING_DIR}/../properties.deploy.1_0_18

SCRIPT_NAME=`basename $0`

check_file_exists ${PROPERTIES_FILE}
. ${PROPERTIES_FILE}

echo "Creatiing single properties file "
/opt/ericsson/nms/litp/bin/deployment/sso/sso_create_sso_property_file_1_0_18.sh
/opt/ericsson/nms/litp/bin/deployment/sso/sso_create_ui_property_file_1_0_18.sh

check_file_exists ${SSO_PROPERTIES_FILE}

echo "Copying Properties files to ${SSO_PROPERTIES_LOCATION_ON_PEER_NODES}"

for node in ${PEER_NODES};
do
	ssh ${node} "mkdir -p ${CERT_LOCATION_ON_PEER_NODES}"  
	ssh ${node} "mkdir -p ${SSO_PROPERTIES_LOCATION_ON_PEER_NODES}"
	scp ${SSO_PROPERTIES_FILE} ${node}:${SSO_PROPERTIES_LOCATION_ON_PEER_NODES}
done
