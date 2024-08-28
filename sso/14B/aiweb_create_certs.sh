#!/bin/bash

BASEDIR=$(/usr/bin/dirname $0)
CERT_DIR=/var/tmp/oasis/aiweb_certs
CERT_FILES_BASENAME="aiweb"
CSR_FILE=${CERT_DIR}/${CERT_FILES_BASENAME}.csr
KEY_FILE=${CERT_DIR}/${CERT_FILES_BASENAME}.key
CERT_FILE=${CERT_DIR}/${CERT_FILES_BASENAME}.crt
KEYSTORE_FILE=${CERT_DIR}/${CERT_FILES_BASENAME}.p12
SSL_CONF_FILE=${CERT_DIR}/openssl.cnf
COMMON_NAME=""
PASSPHRASE=mypassphrase
LIST_OF_CERT_FILES="${KEY_FILE} ${CSR_FILE} ${CERT_FILE} ${KEYSTORE_FILE} ${SSL_CONF_FILE}"
CERT_LOCATION_ON_NODES=/ericsson/tor/data
CHECK_CERTS_CMD="ssh sc-1 'ls -l ${CERT_LOCATION_ON_NODES}'"
AIWEB_ALIAS="aiweb"

if [ ! -d ${CERT_DIR} ]; then
    echo "Making directory ${CERT_DIR} "
    mkdir -p ${CERT_DIR}
fi

for FILE in ${LIST_OF_CERT_FILES}
do
  if [ -f ${FILE} ]; then
    echo "Deleting existing file ${FILE} "
    rm -f ${FILE}
  fi
done

cat << EOF > ${SSL_CONF_FILE}
[ req ]
distinguished_name  = req_distinguished_name
x509_extensions     = v3_ca_req

[ req_distinguished_name ]

[ v3_ca_req ]
extendedKeyUsage=clientAuth,serverAuth
basicConstraints=CA:FALSE
keyUsage=digitalSignature,keyEncipherment
EOF

echo "Creating new cert and key files "

# Generate keys and certificate signing requests
openssl req -nodes \
        -sha256 \
        -newkey rsa:2048 \
        -keyout ${KEY_FILE} \
        -out ${CSR_FILE} \
        -subj "/C=/ST=/L=/O=/CN=${COMMON_NAME}"
	-extensions v3_ca_req \
	-config ${SSL_CONF_FILE}

# Remove the passphrase
openssl rsa -in ${KEY_FILE} \
	-passin pass:${PASSPHRASE} \
	-out ${KEY_FILE}

# Generating Self-Signed Certificates
openssl x509 -req \
        -sha256 \
        -days 365 \
        -in ${CSR_FILE} \
        -signkey ${KEY_FILE} \
        -out ${CERT_FILE}

# Create a temp parsable PKCS12 key store that contains the private key and the certificate:
openssl pkcs12 -export \
        -in ${CERT_FILE} \
        -name ${AIWEB_ALIAS} \
        -inkey ${KEY_FILE} \
        -passout pass:changeit \
        -out ${KEYSTORE_FILE}

for THIS_CERT_FILE in ${LIST_OF_CERT_FILES}
do
 if [ ! -f ${THIS_CERT_FILE} ]; then
   echo "********* Problem, Not all files generated !!! ${THIS_CERT_FILE} missing, exiting"
   exit 1
 fi
done

echo " All Cert and Key files generated !!! "
ls -l ${CERT_DIR}

# Copy the cert files to a node
scp ${CERT_DIR}/*.{crt,key,p12} sc-1:${CERT_LOCATION_ON_NODES}

[ $? -eq 0 ] && echo "Cert files copied to nodes" || ( echo "Problem copying files to node"; exit 1 )

eval ${CHECK_CERTS_CMD}

