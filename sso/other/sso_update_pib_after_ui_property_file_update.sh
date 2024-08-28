#!/bin/bash
echo "Attempting to update UI Pib configuration using UI Post install script"

export LITP_JEE_DE_name=presentation-server-ear-get_past_ear_check_in_script
UI_PIB_SCRIPT=/opt/ericsson/nms/litp/etc/jboss/jboss_app/post_deploy.d/PIB_Configuration.sh
UI_PROPERTIES_FILE=/ericsson/tor/data/presentation_server/launcher.properties

if [ ! -f ${UI_PROPERTIES_FILE} ]; then
  echo "*******Problem, UI Server properties file ${UI_PROPERTIES_FILE} missing, ****EXITING***"
  exit 1
fi

if [ ! -f ${UI_PIB_SCRIPT} ]; then
  echo "******** Problem UI PIB script does not exist  ${UI_PIB_SCRIPT} "
  exit 1
fi

echo "Using following properties from ${UI_PROPERTIES_FILE}"
cat ${UI_PROPERTIES_FILE}

echo "Executing ${UI_PIB_SCRIPT} "
${UI_PIB_SCRIPT}
