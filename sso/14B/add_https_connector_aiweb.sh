#!/bin/bash

BASENAME=/bin/basename
ECHO="echo -e"
ENV=/bin/env
GREP=/bin/grep
HTTPS_CONNECTOR_FOUND=""
JBOSS_SERVER_CERT_ALIAS="ai-web"
KEY_PASS="changeit"
KEYSTORE=/ericsson/tor/data/certificates/aiweb/ai-web-keystore.jks
TRUSTSTORE=/ericsson/tor/data/certificates/aiweb/ai-web-cacerts
KEYTOOL=/usr/java/default/bin/keytool
LOGGER=/usr/bin/logger
LOGGER_TAG="TOR_AIWEB"
SCRIPT_NAME=$( ${BASENAME} ${0} )
LITP_JEE_DE_PATTERN="ai-web"
container_check=$( ${ENV} | ${GREP} _JEE_DE_name | ${GREP} ${LITP_JEE_DE_PATTERN} > /dev/null 2>&1 )
ret_val=${?}

##
## INFORMATION print
##
info()
{
	if [ ${#} -eq 0 ]; then
		while read data; do
			logger -s -t ${LOGGER_TAG} -p user.notice "INFORMATION ( ${SCRIPT_NAME} ): ${data}"
		done
	else
		logger -s -t ${LOGGER_TAG} -p user.notice "INFORMATION ( ${SCRIPT_NAME} ): $@"
	fi
}

##
## ERROR print
##
error()
{
	if [ ${#} -eq 0 ]; then
		while read data; do
			logger -s -t ${LOGGER_TAG} -p user.err "ERROR ( ${SCRIPT_NAME} ): ${data}"
		done
	else
		logger -s -t ${LOGGER_TAG} -p user.err "ERROR ( ${SCRIPT_NAME} ): $@"
	fi
}

##
## WARN print
##
warn()
{
	if [ ${#} -eq 0 ]; then
		while read data; do
			logger -s -t ${LOGGER_TAG} -p user.warning "WARN ( ${SCRIPT_NAME} ): ${data}"
		done
	else
		logger -s -t ${LOGGER_TAG} -p user.warning "WARN ( ${SCRIPT_NAME} ): $@"
	fi
}

##
## Function to add https connector and configure SSL
## Will use the default keystore presently
##
## Requires certificates to be added in advance (see
## functions update_root_ca and update_keystore)
##
add_https_connector()
{
$JBOSS_CLI << EOF
connect
/subsystem=web/connector=https:add(socket-binding=https,scheme=https,protocol="HTTP/1.1",secure=true)
/subsystem=web/connector=https/ssl=configuration:add(\
name="ssl",\
password="${KEY_PASS}",\
ca-certificate-file="${TRUSTSTORE}",\
certificate-key-file="${KEYSTORE}",\
key-alias="${JBOSS_SERVER_CERT_ALIAS}",\
verify-client="true")
:reload
EOF
	
	sleep 10

	# Confirm connector was added
	HTTPS_CONNECTOR_FOUND=$( ${JBOSS_CLI} -c "/subsystem=web/connector=https:read-resource" | ${GREP} -io "success" )

	info "Result of https web connector check: ${HTTPS_CONNECTOR_FOUND}"
	[ "${HTTPS_CONNECTOR_FOUND}" = "success" ] && return 0 || return 1
}

##
## Clean up function, nothing to do so far
##
cleanup ()
{
	info "No cleanup to be performed"
}

##
## Exit gracfully so as not to break flow
##
graceful_exit ()
{
	[ "${#}" -gt 1 -a "${1}" -eq 0 ] && info "${2}"
	[ "${#}" -gt 1 -a "${1}" -gt 0 ] && error "${2}"
	cleanup
	exit ${1}
}

############
## EXECUTION
############
[ ${ret_val} -ne 0 ] && exit 0 || info "AIWeb Container found, executing script"

info "Attempting to add https connector to AIWeb JBoss instance"
add_https_connector && graceful_exit 0 "Successfully added https connector" || graceful_exit 1 "Could not add https connector to AIWeb JBoss"

exit 0
