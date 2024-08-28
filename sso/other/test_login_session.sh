#!/bin/bash

EXPECT=/usr/bin/expect
SSH=/usr/bin/ssh

if [ $# -ne 3 ]; then
 echo "Enter <IP address of UAS> , <valid username> and another <valid username> defined on the infra/UAS, exiting"
 exit 1
fi

UAS_SERVER_IP=$1
VALID_USER=$2
OTHER_USER=$3

echo "Checking have connectivity with the UAS IP address"
ping -c 1 ${UAS_SERVER_IP}
if [ $? -ne 0 ]; then
 echo "Problem: Cant ping that Ip address ${UAS_SERVER_IP}"
 exit 1
fi
echo "Success: Have connectivity with the UAS IP address"

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

       UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`     

       echo "testing get a different token per user"
       curl -s -H "X-Tor-UserID:${VALID_USER}" -H "Content-Type:application/x-ica" http://${UI_JBOSS_IP}:8080/rest/apps/citrix/OSS_Explorer.ica > /tmp/sso_login_check
       echo ${VALID_USER}
       grep ClearPassword= /tmp/sso_login_check
       curl -s -H "X-Tor-UserID:${OTHER_USER}" -H "Content-Type:application/x-ica" http://${UI_JBOSS_IP}:8080/rest/apps/citrix/OSS_Explorer.ica > /tmp/sso_login_check
       echo ${OTHER_USER}
       grep ClearPassword= /tmp/sso_login_check
        
 
       echo "testing token cannot be used by different user"
       echo "Getting a token for ${VALID_USER}"
       curl -s -H "X-Tor-UserID:${VALID_USER}" -H "Content-Type:application/x-ica" http://${UI_JBOSS_IP}:8080/rest/apps/citrix/OSS_Explorer.ica > /tmp/sso_login_check
       TOKEN_PASSSWD=`grep ClearPassword= /tmp/sso_login_check | cut -d= -f2-`
       echo "Using user ${VALID_USER} : Expect to see the hostname of the UAS if login with token was successful"    
        use_expect "$SSH -l ${VALID_USER} ${UAS_SERVER_IP} hostname" $TOKEN_PASSSWD
       echo "Using user ${OTHER_USER} : Expect to see permission denied if login with token was unsuccessful" 
       use_expect "$SSH -l ${OTHER_USER} ${UAS_SERVER_IP} hostname" $TOKEN_PASSSWD

       echo "testing token expires after a short period of time, 90-120 seconds"

       curl -s -H "X-Tor-UserID:${VALID_USER}" -H "Content-Type:application/x-ica" http://${UI_JBOSS_IP}:8080/rest/apps/citrix/OSS_Explorer.ica > /tmp/sso_login_check
       TOKEN_PASSSWD=`grep ClearPassword= /tmp/sso_login_check | cut -d= -f2-`

       NUMBER_TO_EXECUTE=12
       DELAY=10
       for (( NUM=1; NUM<=$NUMBER_TO_EXECUTE; NUM++ ))
        do
          date 
          use_expect "$SSH -l ${VALID_USER} ${UAS_SERVER_IP} hostname" $TOKEN_PASSSWD
          sleep ${DELAY} 
        done

