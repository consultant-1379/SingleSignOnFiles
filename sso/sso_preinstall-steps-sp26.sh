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
PROPERTIES_FILE=${WORKING_DIR}/properties.deploy

SCRIPT_NAME=`basename $0`

check_file_exists ${PROPERTIES_FILE}
. ${PROPERTIES_FILE}

check_file_exists ${CONFIG_FILE}
. ${CONFIG_FILE}

check_file_exists ${SSO_PROPERTIES_FILE}

for CERT_FILE in ${LIST_OF_CERT_FILES}
do  
  check_file_exists ${CERT_DIR}/${CERT_FILE}
done

echo "Copying Properties files to ${SSO_PROPERTIES_LOCATION_ON_PEER_NODES}"
echo "Copying Cert files to ${CERT_LOCATION_ON_PEER_NODES} peer nodes and importing into keystore "

for node in ${PEER_NODES};
do
   ssh ${node} "mkdir -p ${CERT_LOCATION_ON_PEER_NODES}"  
   ssh ${node} "mkdir -p ${SSO_PROPERTIES_LOCATION_ON_PEER_NODES}"
   scp ${SSO_PROPERTIES_FILE} ${node}:${SSO_PROPERTIES_LOCATION_ON_PEER_NODES}

   for CERT_FILE in ${LIST_OF_CERT_FILES}
    do
      scp ${CERT_DIR}/${CERT_FILE} ${node}:${CERT_LOCATION_ON_PEER_NODES}
    done

   SSH_KEYTOOL_CMD="ssh ${node} '/usr/java/default/bin/keytool -import -noprompt -alias sso -storepass changeit -keystore /usr/java/default/jre/lib/security/cacerts -file ${CERT_LOCATION_ON_PEER_NODES}rootca.cer'"
   eval $SSH_KEYTOOL_CMD
   SSH_KEYTOOL_CMD="ssh ${node} '/usr/java/default/bin/keytool -importkeystore -srckeystore ${CERT_LOCATION_ON_PEER_NODES}/ssoserverjboss.p12 -destkeystore /usr/java/default/jre/lib/security/cacerts -srcstorepass changeit -deststorepass changeit -srcstoretype PKCS12 -deststoretype JKS'"
   eval $SSH_KEYTOOL_CMD
   SSH_KEYTOOL_CMD="ssh ${node} '/usr/java/default/bin/keytool -importkeystore -srckeystore ${CERT_LOCATION_ON_PEER_NODES}/ssoserverapache.p12 -destkeystore /usr/java/default/jre/lib/security/cacerts -srcstorepass changeit -deststorepass changeit -srcstoretype PKCS12 -deststoretype JKS'"
   eval $SSH_KEYTOOL_CMD
done

echo "Updating /etc/hosts file on peer nodes "

PEER1_COMMAND="ssh ${PEER1} 'echo -e \"${httpd_instance_0_ip}      ${APACHE_FQDN}\n${sso_instance_0_ip}    ${JBOSS_SSO_ALIAS}\n${LDAP_IP}   ${LDAP_HOSTNAME}\n${LDAP_IP}   ldap1\n${LDAP_IP}   ldap2\n${LDAP_IP}   ${LDAP_HOSTNAME}\" >> /etc/hosts'"
PEER2_COMMAND="ssh ${PEER2} 'echo -e \"${httpd_instance_0_ip}      ${APACHE_FQDN}\n${sso_instance_1_ip}    ${JBOSS_SSO_ALIAS}\n${LDAP_IP}   ${LDAP_HOSTNAME}\n${LDAP_IP}   ldap1\n${LDAP_IP}   ldap2\n${LDAP_IP}   ${LDAP_HOSTNAME}\" >> /etc/hosts'"

eval ${PEER1_COMMAND}
eval ${PEER2_COMMAND}

for node in ${PEER_NODES};
do
  echo "${node}"   
  ssh ${node} "cat /etc/hosts"
done

