#!/bin/bash
ECHO=/bin/echo
SSH=/usr/bin/ssh
SCP=/usr/bin/scp

WORKING_DIR=$(/usr/bin/dirname $0)
WORKING_DIR=$(cd ${WORKING_DIR} ; pwd)
PROPERTIES_FILE=${WORKING_DIR}/properties.deploy

if [ ! -f ${PROPERTIES_FILE} ]; then
    echo "problem *********** :  ${PROPERTIES_FILE} is missing, exiting  "
    exit 1
fi
. ${PROPERTIES_FILE}

 if [ -f ${GLOBAL_PROPERTY_FILE} ]; then
     ${ECHO} "Deleing existing properties file  ${GLOBAL_PROPERTY_FILE} "
     rm -f ${GLOBAL_PROPERTY_FILE}
 fi
 ${ECHO} "Creating new Properties file  ${GLOBAL_PROPERTY_FILE}"
 touch ${GLOBAL_PROPERTY_FILE}

cat << EOF >> ${GLOBAL_PROPERTY_FILE}
SSO_COOKIE_DOMAIN=.ericsson.se
COM_INF_LDAP_PORT=636
COM_INF_LDAP_ADMIN_CN="directory manager"
UI_PRES_SERVER=${APACHE_FQDN}
COM_INF_LDAP_HOST_1=${LDAP_HOSTNAME}
COM_INF_LDAP_HOST_2=${LDAP_HOSTNAME}
COM_INF_LDAP_ROOT_SUFFIX=dc=${LDAP_DOMAIN},dc=com
COM_INF_LDAP_ADMIN_ACCESS=${LDAP_PWD}

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
${ECHO} "Copying new Properties file to Peer nodes ${PEER_NODES} ${GLOBAL_PROPERTY_LOCATION_ON_PEER_NODES}"

for node in ${PEER_NODES};
do
   ${SSH} ${node} "mkdir -p ${GLOBAL_PROPERTY_LOCATION_ON_PEER_NODES}"
   ${SCP} ${GLOBAL_PROPERTY_FILE} ${node}:${GLOBAL_PROPERTY_LOCATION_ON_PEER_NODES}
   ${SSH} ${node} "ls -l ${GLOBAL_PROPERTY_LOCATION_ON_PEER_NODES}"
done

