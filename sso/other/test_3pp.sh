#!/bin/bash

EXPECT=/usr/bin/expect
SSH=/usr/bin/ssh

if [ $# -ne 2 ]; then
 echo "Enter <Number of login attempts> <delay between login attempts>, exiting"
 exit 1
fi

NUMBER_TO_EXECUTE=$1
DELAY=$2
echo "Update teh curl command "
exit

echo "Checking have connectivity with the UAS IP address"


TOKEN_FAILURE_COUNT=0;
TOKEN_SUCCESS_COUNT=0;
VALID_USER=ssotor
VALID_PASSWORD=ssotor01

. /ericsson/tor/data/sso/sso.properties

OUTPUT_FILE=/tmp/sso_openam_check
FAILURE_LOG=${OUTPUT_FILE}_failure_log

rm -f ${FAILURE_LOG}
touch ${FAILURE_LOG}

UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`

echo "Starting to test $NUMBER_TO_EXECUTE login attempts"
echo "this could take a while............"
COUNT=0
for (( NUM=1; NUM<=$NUMBER_TO_EXECUTE; NUM++ ))
do
    date
    curl -s "http://sso.${UI_PRES_SERVER}:8080/heimdallr/identity/authenticate?username=${VALID_USER}&password=${VALID_PASSWORD}" > ${OUTPUT_FILE}
    if [ `grep -c "token" ${OUTPUT_FILE}` -ne 1 ]; then
       TOKEN_FAILURE_COUNT=`expr ${TOKEN_FAILURE_COUNT} + 1`
       cat ${OUTPUT_FILE} >> ${FAILURE_LOG}
    else
       TOKEN_SUCCESS_COUNT=`expr ${TOKEN_SUCCESS_COUNT} + 1`
    fi
    sleep ${DELAY}
    COUNT=`expr ${COUNT} + 1`
    if [ `expr ${COUNT} % 100` -eq 0 ]; then
          echo "Every 100 attepts, print the status"
          date
          echo "**********************************************Total tokens fetched ${TOKEN_SUCCESS_COUNT} "
          echo "**********************************************Total tokens not received ${TOKEN_FAILURE_COUNT}"
          COUNT=0
    fi
done

echo "Total tokens fetched ${TOKEN_SUCCESS_COUNT} "
echo "Total tokens not received ${TOKEN_FAILURE_COUNT}"
