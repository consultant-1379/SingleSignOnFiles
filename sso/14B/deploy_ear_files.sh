#!/bin/bash
ECHO=/bin/echo

EAR_FILES_DIR=/var/tmp/oasis/ears
DEPLOYED_EARS_FILE=/tmp/deployed_ears.txt
CONTROLLER_IP=`ps -ef | grep Standalone | grep -o jboss.bind.address.management=[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* | head -1 | cut -d= -f2`
CONTROLLER_PORT=`ps -ef | grep Standalone | grep -o jboss.management.native.port=[0-9][0-9]* | head -1 | cut -d= -f2`
echo "Using ${CONTROLLER_IP} and ${CONTROLLER_IP}"

if [ ! -d ${EAR_FILES_DIR} ]; then
  ${ECHO} "Expected EAR file directory does not exist , ${EAR_FILES_DIR} , exiting"
  exit 1
fi
cd ${EAR_FILES_DIR}
if [ `ls | wc -l` -eq 0 ]; then
 echo "No EAR files in Directory ${EAR_FILES_DIR} exiting"
 exit 1
fi

for EAR in `ls`; do
    PRODUCT=`echo ${EAR} | sed 's/\-[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.ear//g'`
    echo "Using ${PRODUCT}, looking for version currently deployed on jboss "

    cd /home/jboss/
    for JBOSS_INSTANCE in `ls`; do
    echo "Checking ${JBOSS_INSTANCE} for ${PRODUCT}"
       if [ `grep -c ${PRODUCT} /home/jboss/${JBOSS_INSTANCE}/standalone/configuration/standalone-core.xml` -eq 1 ]; then
          echo "${PRODUCT} found in ${JBOSS_INSTANCE} /home/jboss/${JBOSS_INSTANCE}/standalone/configuration/standalone-core.xml"
          JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON=${JBOSS_INSTANCE}
          break
       fi
    done
    if [ -z ${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON} ]; then
           echo "**********problem did not find product ear ${PRODUCT} deployed on any Jboss Instance, exiting"
           exit 1
    fi
    /home/jboss/${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON}/bin/jboss-cli.sh controller=${CONTROLLER_IP}:${CONTROLLER_PORT} -c --command="deploy" > ${DEPLOYED_EARS_FILE}
    if [ `grep -c ${PRODUCT} ${DEPLOYED_EARS_FILE}` -ne 1 ]; then
        echo "**********problem did noit find product ear ${PRODUCT} deployed on ${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON}"
        echo "**********even though found in /home/jboss/${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON}/standalone/configuration/standalone-core.xml"
        cat ${DEPLOYED_EARS_FILE}
        exit 1
    fi

    EXISTING_EAR=`grep ${PRODUCT} ${DEPLOYED_EARS_FILE}`
    echo "Attempting to undeploy ${EXISTING_EAR}"
   /home/jboss/${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON}/bin/jboss-cli.sh controller=${CONTROLLER_IP}:${CONTROLLER_PORT} -c --command="undeploy --name=${EXISTING_EAR}"
    echo "Result from jboss-cli.sh is ${?}"

    echo "Attempting to deploy ${EAR}"
    /home/jboss/${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON}/bin/jboss-cli.sh controller=${CONTROLLER_IP}:${CONTROLLER_PORT} -c --command="deploy ${EAR_FILES_DIR}/${EAR}"
    echo "Result from jboss-cli.sh is ${?}"

done
   /home/jboss/${JBOSS_INSTANCE_PRODUCT_DEPLOYED_ON}/bin/jboss-cli.sh controller=${CONTROLLER_IP}:${CONTROLLER_PORT} -c --command="deploy"
