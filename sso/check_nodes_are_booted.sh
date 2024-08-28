#!/bin/bash

# Create a definition for a single node deployment consisting of SC1 and SC2
# Find my current dir

BASEDIR=$(/usr/bin/dirname $0)
# NOTE: This behaviour relies on shell builtins for cd and pwd
BASEDIR=$(cd ${BASEDIR}/.. ; pwd)
[ -f ${BASEDIR}/etc/global.env ] && . ${BASEDIR}/etc/global.env
initLogging landscape_runtime.log
. ${BASEDIR}/etc/runtime_functions.sh

###############################################################################
## Wait for LITP
###############################################################################
wait_for_litp_to_be_ready
