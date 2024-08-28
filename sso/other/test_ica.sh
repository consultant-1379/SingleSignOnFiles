#!/bin/bash

EXPECT=/usr/bin/expect
SSH=/usr/bin/ssh

if [ $# -ne 2 ]; then
 echo "Enter <Number of attempts> <delay between attempts>, exiting"
 exit 1
fi

NUMBER_TO_EXECUTE=$1
DELAY=$2

ICA_FAILURE_COUNT=0;
ICA_SUCCESS_COUNT=0;
VALID_USER=ssotor

. /ericsson/tor/data/sso/sso.properties

rm -f /tmp/failure_log
touch /tmp/failure_log

UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`

echo "Starting to test $NUMBER_TO_EXECUTE login attempts"
COUNT=0
for (( NUM=1; NUM<=$NUMBER_TO_EXECUTE; NUM++ ))
do
    date
    curl -s -H "X-Tor-UserID:${VALID_USER}" -H "Content-Type:application/x-ica" http://${UI_JBOSS_IP}:8080/rest/apps/citrix/OSS_Explorer.ica > /tmp/sso_login_check
    if [ `grep -c "ClearPassword=" /tmp/sso_login_check` -ne 1 ]; then
       ICA_FAILURE_COUNT=`expr ${ICA_FAILURE_COUNT} + 1`
       echo "**Problem** Ica feicthing failed!"
       cat /tmp/sso_login_check >> /tmp/failure_log
    else
       ICA_SUCCESS_COUNT=`expr ${ICA_SUCCESS_COUNT} + 1`
       echo "**Success** Ica feicthing ok!"
    fi
    sleep ${DELAY}
    COUNT=`expr ${COUNT} + 1`
    if [ `expr ${COUNT} % 100` -eq 0 ]; then
          date
          echo "**********************************************Total tokens fetched ${ICA_SUCCESS_COUNT} "
          echo "**********************************************Total tokens not received ${ICA_FAILURE_COUNT}"
          COUNT=0
    fi
done

echo "Total tokens fetched ${ICA_SUCCESS_COUNT} "
echo "Total tokens not received ${ICA_FAILURE_COUNT}"

