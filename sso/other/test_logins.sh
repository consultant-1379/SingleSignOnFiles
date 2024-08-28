#!/bin/bash

EXPECT=/usr/bin/expect
SSH=/usr/bin/ssh

if [ $# -ne 5 ]; then
 echo "Enter <IP address of UAS> <Number of login attempts> <delay between login attempts> <userid> <password>, exiting"
 exit 1
fi

UAS_SERVER_IP=$1
NUMBER_TO_EXECUTE=$2
DELAY=$3
VALID_USER=$4
VALID_PASSWORD=$5

echo "Checking have connectivity with the UAS IP address"

ping -c 1 ${UAS_SERVER_IP}

if [ $? -ne 0 ]; then
 echo "Cant ping  ${UAS_SERVER_IP}"
 exit 1
fi


use_expect()
{
COMMAND=$1
PASSWD=$2
$EXPECT - <<EOF
        set force_conservative 1
        set timeout -1
        set prompt ".*(%|#|\\$|>):? $"
        spawn -noecho $COMMAND
        while {"1" == "1"} {
                expect {
                        "assword: " {
                                send_user "sending password $PASSWD"
                                send "$PASSWD\r"
                        }
                        "Are you sure" {
                                send "yes\r"
                        }
                        timeout {
                                send_user "expect timed out, exiting"
                                exit 1
                        }
                        -re \$prompt {
                                send "ls\r"
                        }
                        eof {
                                break
                        }
                }
        }
EOF
}

TOKEN_FAILURE_COUNT=0;
TOKEN_SUCCESS_COUNT=0;

. /ericsson/tor/data/sso/sso.properties

rm -f /tmp/failure_log
touch /tmp/failure_log

UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`

echo "Starting to test $NUMBER_TO_EXECUTE login attempts"
TIME=`expr $NUMBER_TO_EXECUTE \* ${DELAY}`
echo "this could take a while............${TIME} seconds in total"
COUNT=0
for (( NUM=1; NUM<=$NUMBER_TO_EXECUTE; NUM++ ))
do
    date
    curl -s -H "X-Tor-UserID:${VALID_USER}" -H "Content-Type:application/x-ica" http://${UI_JBOSS_IP}:8080/rest/apps/citrix/OSS_Explorer.ica > /tmp/sso_login_check
    if [ `grep -c "ClearPassword=" /tmp/sso_login_check` -ne 1 ]; then
       TOKEN_FAILURE_COUNT=`expr ${TOKEN_FAILURE_COUNT} + 1`
       cat /tmp/sso_login_check >> /tmp/failure_log
    else
       TOKEN_SUCCESS_COUNT=`expr ${TOKEN_SUCCESS_COUNT} + 1`
       TOKEN_PASSSWD=`grep ClearPassword= /tmp/sso_login_check | cut -d= -f2-`
       use_expect "$SSH -l ${VALID_USER} ${UAS_SERVER_IP} hostname" $TOKEN_PASSSWD
       #use_expect "$SSH -l ${VALID_USER} ${UAS_SERVER_IP} hostname" $VALID_PASSWORD
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

