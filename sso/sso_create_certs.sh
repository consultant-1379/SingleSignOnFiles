#!/bin/bash

WORKING_DIR=$(/usr/bin/dirname $0)
WORKING_DIR=$(cd ${WORKING_DIR} ; pwd)
PROPERTIES_FILE=${WORKING_DIR}/properties.deploy

if [ ! -f ${PROPERTIES_FILE} ]; then
    echo "problem *********** :  ${PROPERTIES_FILE} is missing, exiting  "
    exit 1
fi
. ${PROPERTIES_FILE} 

ROOT_CERT=${WORKING_DIR}/${ROOT_CERT}

if [ ! -d ${CERT_DIR} ]; then
    echo "Making directory ${CERT_DIR} "
    mkdir -p ${CERT_DIR}
fi

for CERT_FILE in ${LIST_OF_CERT_FILES}
do
  if [ -f ${CERT_DIR}/${CERT_FILE} ]; then
    echo "Deleting existing file ${CERT_DIR}/${ERT_FILE} "
    rm -f ${CERT_DIR}/${CERT_FILE}
  fi
done

if [ ! -f ${ROOT_CERT} ]; then
    echo " missing rootca.cer file ${ROOT_CERT} exiting"
    exit 1
fi

echo "Using ${ROOT_CERT} from ${LDAP} as rootca.cer file"
cp ${ROOT_CERT} ${CERT_DIR}/rootca.cer

echo "Creating new cert and key files "

##
## Function to generate private keys and certificate signing requests
##

# Generate keys and certificate signing requests
openssl req -nodes \
        -sha256 \
        -newkey rsa:2048 \
        -keyout ${CERT_DIR}/ssoserverjboss.key \
        -out ${CERT_DIR}/ssoserverjboss.csr \
        -subj "/C=/ST=/L=/O=/CN=sso.${APACHE_FQDN}"

openssl req -nodes \
        -sha256 \
        -newkey rsa:2048 \
        -keyout ${CERT_DIR}/ssoserverapache.key \
        -out ${CERT_DIR}/ssoserverapache.csr \
        -subj "/C=/ST=/L=/O=/CN=${APACHE_FQDN}"

# Generating Self-Signed Certificates
openssl x509 -req \
        -sha256 \
        -days 365 \
        -in ${CERT_DIR}/ssoserverjboss.csr \
        -signkey ${CERT_DIR}/ssoserverjboss.key \
        -out ${CERT_DIR}/ssoserverjboss.crt

openssl x509 -req \
        -sha256 \
        -days 365 \
        -in ${CERT_DIR}/ssoserverapache.csr \
        -signkey ${CERT_DIR}/ssoserverapache.key \
        -out ${CERT_DIR}/ssoserverapache.crt

# Create a temp parsable PKCS12 key store that contains the private key and the certificate:
openssl pkcs12 -export \
        -in ${CERT_DIR}/ssoserverjboss.crt \
        -name sso-server \
        -inkey ${CERT_DIR}/ssoserverjboss.key \
        -passout pass:changeit \
        -out ${CERT_DIR}/ssoserverjboss.p12

openssl pkcs12 -export \
        -in ${CERT_DIR}/ssoserverapache.crt \
        -name apache-server \
        -inkey ${CERT_DIR}/ssoserverapache.key \
        -passout pass:changeit \
        -out ${CERT_DIR}/ssoserverapache.p12

for CERT_FILE in ${LIST_OF_CERT_FILES}
do
 if [ ! -f ${CERT_DIR}/${CERT_FILE} ]; then
   echo "********* Problem, Not all files generated !!! ${CERT_DIR}/${CERT_FILE} missing, exiting"
   exit 1
 fi
done
chmod 400 ${CERT_DIR}/ssoserverapache.key
chmod 400 ${CERT_DIR}/ssoserverapache.crt

echo " All Cert and Key files generated !!! "
ls -l ${CERT_DIR}

