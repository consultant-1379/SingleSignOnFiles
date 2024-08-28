#!/bin/bash
ECHO=/bin/echo
SSH=/usr/bin/ssh
SCP=/usr/bin/scp

WORKING_DIR=$(/usr/bin/dirname $0)
WORKING_DIR=$(cd ${WORKING_DIR} ; pwd)
PROPERTIES_FILE=${WORKING_DIR}/properties.deploy.1_0_18

if [ ! -f ${PROPERTIES_FILE} ]; then
    echo "problem *********** :  ${PROPERTIES_FILE} is missing, exiting  "
    exit 1
fi
. ${PROPERTIES_FILE}

 if [ -f ${UI_PROPERTY_FILE} ]; then
     ${ECHO} "Deleing existing properties file  ${UI_PROPERTY_FILE} "
     rm -f ${UI_PROPERTY_FILE}
 fi
 ${ECHO} "Creating new Properties file  ${UI_PROPERTY_FILE}"
 touch ${UI_PROPERTY_FILE}

cat << EOF >> ${UI_PROPERTY_FILE}

#CITRIX_ADDRS_START
icaAddr=${PIB_UAS_IP}
icaAddr1=${PIB_UAS_IP}
icaAddr2=${PIB_UAS_IP}
icaAddr3=${PIB_UAS_IP}
#CITRIX_ADDRS_END

#CITRIX_IDENTIFIERS_START
default=${PIB_PUBLISHED_APP_SUFFIX}
icaHost=${PIB_PUBLISHED_APP_SUFFIX}
#CITRIX_IDENTIFIERS_END

#WEB_HOSTS_START
default=${APACHE_FQDN}
ossMonitoringHost=NOT_USED
eniqEventsHost=NOT_USED
eniqStatsHost=NOT_USED
eniqManagement=NOT_USED
eniqBusinessHost=NOT_USED
alexHost=NOT_USED
#WEB_HOSTS_END 

#WEB_PORTS_START
default=443
unsecurePort=80
securePort=443
appServer=8080
ossMonitoring=57005
eniqEventsPort=18080
#WEB_PORTS_END

#WEB_PROTOCOLS_START
default=https
secure=https
unsecure=http
#WEB_PROTOCOLS_END 
EOF

${ECHO} "Contents of new Properties file"
cat ${UI_PROPERTY_FILE}

${ECHO} "Copying new Properties file to Peer nodes ${PEER_NODES} ${UI_PROPERTY_FILE_LOCATION}"

for node in ${PEER_NODES};
do
   ${SSH} ${node} "mkdir -p ${UI_PROPERTY_FILE_LOCATION}"
   ${SCP} ${UI_PROPERTY_FILE} ${node}:${UI_PROPERTY_FILE_LOCATION} 
   ${SSH} ${node} "ls -l ${UI_PROPERTY_FILE_LOCATION}" 
done

