#!/bin/bash
ECHO=/bin/echo


if [ $# -ne 1 ]; then
   ${ECHO} "please provide path/filename of the config file"
   ${ECHO} "Example usage : `basename $0` /var/tmp/single_node.cfg"
   exit 1;
fi

CONFIG_FILE=$1

if [ ! -f ${CONFIG_FILE} ]; then
    ${ECHO} "${CONFIG_FILE} does not exist, exiting"
    exit 1
fi
grep TOR_REL ${CONFIG_FILE}

NUMBER_OF_OCCURENCES_IN_LINE=`grep TOR_REL= ${CONFIG_FILE} | cut -d= -f2 | grep -c _`

if [ ${NUMBER_OF_OCCURENCES_IN_LINE} -gt 0 ]; then
    
    TOR_RELEASE=`grep TOR_REL= ${CONFIG_FILE} | cut -d= -f2`
    TOR_RELEASE_WITH_UNDERSCRORES=`${ECHO} ${TOR_RELEASE} | sed 's/\./_/g'`
    echo "Replacing ${TOR_RELEASE} with /${TOR_RELEASE_WITH_UNDERSCRORES}"
    
    cp ${CONFIG_FILE} ${CONFIG_FILE}.bak.$$
    cat ${CONFIG_FILE} | sed s/${TOR_RELEASE}/${TOR_RELEASE_WITH_UNDERSCRORES}/g > ${CONFIG_FILE}.new
    mv ${CONFIG_FILE}.new ${CONFIG_FILE}
fi

grep TOR_REL ${CONFIG_FILE}

