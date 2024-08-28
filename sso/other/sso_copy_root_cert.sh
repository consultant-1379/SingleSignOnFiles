#!/bin/bash
if [ $# -ne 2 ]; then
    echo "Enter path to directory where certs will be written and the LDAP hostname, exiting"
    exit 1
fi
CERTS_HOME=${1}
LDAP=${2}

if [ ! -f rootca.cer.${LDAP} ]; then
    echo " missing rootca.cer file  rootca.cer.${LDAP}"
    exit 1
fi
cp rootca.cer.${LDAP} ${CERTS_HOME}/rootca.cer

