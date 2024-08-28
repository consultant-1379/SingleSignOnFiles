#####################################
#
# Post-start steps for JBoss
#
# COPYRIGHT Ericsson 2013
#
#####################################

# Script name
SCRIPT_NAME=`basename $0`
echo "Running $SCRIPT_NAME"
# # NOW=`date "+%F-%H%M%S"`
# # 
# # jboss_home=/home/jboss/node1_sso1_sso1
# # jboss_cli="/home/jboss/node1_sso1_sso1/bin/jboss-cli.sh controller=127.0.0.1:26029 -c"
# # process_user=litp_jboss
# # process_group=litp_jboss
# # post_start=/opt/ericsson/sso/resources/jboss/jboss_instance/post_start.d
# # post_deploy=/opt/ericsson/sso/resources/jboss/jboss_instance/post_deploy.d
# # 
# # echo "Running $SCRIPT_NAME"
# # #echo "Changing permissions of $post_start to $process_user:$process_group"
# # #chown $process_user:$process_group $post_start -R
# # #echo "Running $SCRIPT_NAME" >> /opt/ericsson/sso/resources/$SCRIPT_NAME-$NOW.log
# # 
# # echo "Checking JBoss subsystems for conflicts"
# # echo "JBoss command is $jboss_cli"
# # 
# # # SUBSYSTEMS_EXIST=`$jboss_cli --connect --command="ls subsystem" | grep -e 'jaxrs\|webservices'`
# # #echo "running /home/jboss/node1_sso1_sso1/bin/jboss-cli.sh controller=127.0.0.1:26029 -c --command=\"ls subsystem\""
# # #/home/jboss/node1_sso1_sso1/bin/jboss-cli.sh controller=127.0.0.1:26029 -c --command="ls subsystem"
# # 
# # echo "Waiting for jboss to allow cli connections"
# # 
# # sleep 10
# # 
# # SUBSYSTEMS_EXIST=`/home/jboss/node1_sso1_sso1/bin/jboss-cli.sh controller=127.0.0.1:26029 -c --command="ls subsystem" | grep -e 'jaxrs\|webservices'`
# # 
# # 
# # if [ -n "$SUBSYSTEMS_EXIST" ]; then
# #         echo "Removing susbsystems jaxrs and webservices"
# #         $jboss_cli --command="/subsystem=jaxrs : remove"
# #         $jboss_cli --command="/extension=org.jboss.as.jaxrs : remove"
# #         $jboss_cli --command="/subsystem=webservices : remove"
# #         $jboss_cli --commands="/extension=org.jboss.as.webservices : remove"
# #         # dummy pause
# #         echo "Waiting for subsytems to be removed"
# #         sleep 30
# #         echo "calling reload command"
# #         $jboss_cli --command=":reload"
# #         echo "done reloading"
# # else
# #         echo "No JBoss subsystem conflicts exist"
# # fi
# # 
# # echo "Done checking JBoss subsystems for conflicts"
tmpuser=`id`
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Current user info: $tmpuser"
echo "Running $SCRIPT_NAME from `pwd`"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Skipping jboss conflict checks as JBOSS_HOME/modules/sun/jdk/main/module.xml is updated"
echo "and standalone-sso.xml has relevant subsystems removed"
