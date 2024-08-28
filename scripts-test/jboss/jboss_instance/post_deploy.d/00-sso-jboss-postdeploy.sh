#!/bin/bash

#####################################
#
# Post-deploy steps for JBoss instance
#
# COPYRIGHT Ericsson 2013
#
#####################################
# set -x
# 
# echo "Checking environment parameters"
# set >> /var/tmp/litp_env_settings
# 
# # Script name
SCRIPT_NAME=`basename $0`
# 
# jboss_home=/home/jboss/node1_sso1_sso1
# jboss_cli="$jboss_home/bin/jboss-cli.sh controller=127.0.0.1:26029 -c"
# process_user=litp_jboss
# process_group=litp_jboss
# post_start=/opt/ericsson/sso/resources/jboss/jboss_instance/post_start.d
# post_deploy=/opt/ericsson/sso/resources/jboss/jboss_instance/post_deploy.d
# home_dir=$jboss_home
# #home_dir=$LITP_JEE_CONTAINER_home_dir
# echo "Running $SCRIPT_NAME"
# #echo "Running $SCRIPT_NAME" >> /opt/ericsson/sso/resources/$SCRIPT_NAME-$NOW.log
# 
# RESOURCES_HOME=/opt/ericsson/sso/resources
# MODULE_HOME=$home_dir/modules/sun/jdk/main
# 
# if [ ! -f $RESOURCES_HOME/module.xml ]; then
#         echo "$RESOURCES_HOME/module.xml does not exist. Script cannot continue"
#         exit 1;
# fi
# 
# # chown $process_user:$process_group $RESOURCES_HOME/module.xml
# cp -f $RESOURCES_HOME/module.xml $MODULE_HOME/
# 
# # copy service framework modules
# cp -r $RESOURCES_HOME/service-framework-bundle/com $jboss_home/modules

tmpuser=`id`
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Current user info: $tmpuser"
echo "Running $SCRIPT_NAME from `pwd`"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Skipping jboss conflict checks as JBOSS_HOME/modules/sun/jdk/main/module.xml is updated"
echo "and standalone-sso.xml has relevant subsystems removed"
