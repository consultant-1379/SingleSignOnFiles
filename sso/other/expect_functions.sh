#!/bin/bash -x


#####################################################################################################
#
#                                          VARIABLE ASSIGNMENTS
#
######################################################################################################


EXPECT=/usr/bin/expect
SSH=/usr/bin/ssh
SCP=/usr/bin/scp
SFTP=/usr/bin/sftp

######################################################################################################
#
#                                          functions
#
######################################################################################################

check_file_exists()
{
FILE=$1
if [ ! -r ${FILE} ]; then

        if [ $# -eq 2 ]; then
        MESSAGE=$2
        else
        MESSAGE="PROBLEM: File ${FILE} does not exist, exiting"
        fi
        echo $MESSAGE
        exit 1
fi
}

check_directory_exists()
{

DIR=$1
if [ ! -d ${DIR} ]; then
  echo "PROBLEM: directory ${DIR} does not exist, exiting "
  exit 1
fi
}

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

execute_command_or_script_on_remote_server()
{

SERVER=$1
USER=$2
PASSWD=$3
CMD_SCRIPT="$4"

if [ $# -eq 5 ]; then
 SSH=$VIRTUAL_SSH
fi

use_expect "$SSH -l $USER ${SERVER}.athtem.eei.ericsson.se ${CMD_SCRIPT}" $PASSWD
}

copy_file_to_remote_server()
{

SERVER=$1
USER=$2
PASSWD=$3
LOCAL_FILE=$4
LOCATION=$5

if [ $# -eq 6 ]; then
 SCP=$VIRTUAL_SCP
fi

use_expect "$SCP ${LOCAL_FILE} ${USER}@${SERVER}.athtem.eei.ericsson.se:${LOCATION}" $PASSWD

}

copy_file_from_remote_server()
{

SERVER=$1
USER=$2
PASSWD=$3
REMOTE_FILE=$4
LOCAL_FILE=$5

if [ $# -eq 6 ]; then
 SCP=$VIRTUAL_SCP
fi

use_expect "$SCP ${USER}@${SERVER}.athtem.eei.ericsson.se:${REMOTE_FILE} ${LOCAL_FILE}" $PASSWD

}

