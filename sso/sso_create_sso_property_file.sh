#!/bin/bash -x

WORKING_DIR=$(/usr/bin/dirname $0)
WORKING_DIR=$(cd ${WORKING_DIR} ; pwd)
PROPERTIES_FILE=${WORKING_DIR}/properties.deploy

if [ ! -f ${PROPERTIES_FILE} ]; then
    echo "problem *********** :  ${PROPERTIES_FILE} is missing, exiting  "
    exit 1
fi
. ${PROPERTIES_FILE}
SSO_PARTIAL_PROPERTIES_FILE=${WORKING_DIR}/${SSO_PARTIAL_PROPERTIES_FILE}

if [ -f ${SSO_PROPERTIES_FILE} ]; then
    echo "Deleting existing properties file ${SSO_PROPERTIES_FILE} "
    rm -f ${SSO_PROPERTIES_FILE}
fi

if [ ! -f ${SSO_PARTIAL_PROPERTIES_FILE} ]; then
    echo "Problem ********* properties file ${SSO_PARTIAL_PROPERTIES_FILE} is missing"
    exit 1
fi
echo "using  ${SSO_PARTIAL_PROPERTIES_FILE} to create a SSO properties file"
cat ${SSO_PARTIAL_PROPERTIES_FILE}

echo "UI_PRES_SERVER=${APACHE_FQDN}" > ${SSO_PROPERTIES_FILE}
echo "COM_INF_LDAP_HOST_1=${LDAP_HOSTNAME}"  >> ${SSO_PROPERTIES_FILE}
echo "COM_INF_LDAP_HOST_2=${LDAP_HOSTNAME}"  >> ${SSO_PROPERTIES_FILE}
echo "COM_INF_LDAP_ROOT_SUFFIX=dc=${LDAP_DOMAIN},dc=com" >> ${SSO_PROPERTIES_FILE}
echo "COM_INF_LDAP_ADMIN_ACCESS=${LDAP_PWD}" >> ${SSO_PROPERTIES_FILE}
cat ${SSO_PARTIAL_PROPERTIES_FILE} >> ${SSO_PROPERTIES_FILE}

echo "Properties file ${SSO_PROPERTIES_FILE} contains "
cat ${SSO_PROPERTIES_FILE}

