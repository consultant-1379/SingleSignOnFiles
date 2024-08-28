#!/bin/bash

check_can_ping_server ()
{
if [ $# -ne 1 ]; then 
   echo " Problem No Server supplied, exiting "
   exit
fi

SERVER=$1
echo " Checking have connectivity with the server ${SERVER} "

ping -c 1 ${SERVER}

if [ $? -ne 0 ]; then
 echo "Cant ping that IP address ${SERVER}"
 exit 1
fi
echo "Ping succesful with IP address ${SERVER}
}
