#!/bin/bash

#####################################
#
# Post-deploy steps for JBoss "app":
#
# Initial OpenAM configuration:
#       - Declaring the home directory of OpenAM
#       - Defining the LDAP details
#
# COPYRIGHT Ericsson 2013
#
#####################################
set -x
# Script name
SCRIPT_NAME=`basename $0`
echo "Running $SCRIPT_NAME"
tmpuser=`id`
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "Current user info: $tmpuser"
echo "Running $SCRIPT_NAME from `pwd`"
echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

. /opt/ericsson/sso/resources/conf/site-configuration.conf
# Use common LITP variables
. /opt/ericsson/sso/resources/conf/litp-vars.conf

# use common global variables
. /opt/ericsson/sso/resources/conf/env-vars.conf

# Set the JAVA_HOME variable to jre 1.6 - this is installed
# in it's own directory that we will reference explicitly
SSO_INSTALL_JAVA_HOME=$SSO_HOME/resources/jre

# The OpenAM auto-config script needs a conf file
SSO_CONFIGURATOR_OPTIONS=$SSO_HOME/resources/conf/configurator.conf

# Where the configurator tool lives
SSO_CONFIGURATOR_HOME=$SSO_HOME/resources/openam-tools/config

# Set the password - NEEDS SECURITY AUDIT!
PASSWD=h31md477R

echo $PASSWD > $SSO_HOME/resources/pass.txt
chmod 400 $SSO_HOME/resources/pass.txt

# Define the configurator options
cat << EOF > $SSO_CONFIGURATOR_OPTIONS
# Server properties, AM_ENC_KEY="" means generate random key
SERVER_URL=$AM_SERVER_URL
DEPLOYMENT_URI=$SSO_NAME-1.1.1
BASE_DIR=$SSO_FULL_SYMLINK
locale=en_US
PLATFORM_LOCALE=en_US
AM_ENC_KEY=
ADMIN_PWD=$PASSWD
AMLDAPUSERPASSWD=p071cyh31md477R
COOKIE_DOMAIN=$SSO_COOKIE_DOMAIN

# Embedded configuration data store
DATA_STORE=embedded
DIRECTORY_SSL=SIMPLE
DIRECTORY_SERVER=$SSO_MACHINE_NAME
DIRECTORY_PORT=51389
DIRECTORY_ADMIN_PORT=4445
DIRECTORY_JMX_PORT=1699
ROOT_SUFFIX=dc=opensso,dc=java,dc=net
DS_DIRMGRDN=cn=Directory Manager
DS_DIRMGRPASSWD=c0nf1gh31md477R
EOF
cat $SSO_CONFIGURATOR_OPTIONS

# echo "Waiting"
# sleep 2
# run the command

# Hack loop to make sure the war is fully deployed
# STATUS_CMD=$jboss_cli --commands="cd deployment,cd heimdallr-1.1.1.war, read-attribute status"
# TIME_WAITING=0
# LOOP_INVARIANT=5
# printf "Waiting for war to deploy."
# until [ `$STATUS_CMD` = "OK" ]
# 	do
# 		sleep $LOOP_INVARIANT
# 		TIME_WAITING=`expr $TIME_WAITING + $LOOP_INVARIANT`
# 		printf "."
# 	done
# printf "done\n"

echo "Running $SSO_INSTALL_JAVA_HOME/bin/java -jar $SSO_CONFIGURATOR_HOME/configurator.jar -f $SSO_CONFIGURATOR_OPTIONS"
$SSO_INSTALL_JAVA_HOME/bin/java -jar $SSO_CONFIGURATOR_HOME/configurator.jar -f $SSO_CONFIGURATOR_OPTIONS
echo "Done running $SSO_INSTALL_JAVA_HOME/bin/java -jar $SSO_CONFIGURATOR_HOME/configurator.jar -f $SSO_CONFIGURATOR_OPTIONS"





##############################
#
# Main configuration of OpenAM
#
##############################
set -x
# . ../../../conf/site-configuration.conf
# # Use common LITP variables
# . ../../../conf/litp-vars.conf
# 
# # use common global variables
# . ../../../conf/env-vars.conf

# Set up JAVA_HOME
export JAVA_HOME=$SSO_HOME/resources/jre

# Location of the admin tool
SSO_SSOADM_HOME=$SSO_HOME/resources/openam-tools/admin

echo "Setting up ssoadm tool"
cd $SSO_SSOADM_HOME
./setup -p $SSO_FULL_SYMLINK -d $SSO_SSOADM_HOME/debug -l $SSO_SSOADM_HOME/log

echo "Running ssoadm batch commands"
$SSO_SSOADM_HOME/heimdallr-1.1.1/bin/ssoadm do-batch -u amadmin -f $SSO_HOME/resources/pass.txt -Z $SSO_SSOADM_HOME/openam-batch.conf --batchstatus $SSO_SSOADM_HOME/openam-batch.log --continue

echo "$SSO_SSOADM_HOME/openam-batch.log:"
cat $SSO_SSOADM_HOME/openam-batch.log

echo "Running extra 'create-agent' command"
$SSO_SSOADM_HOME/heimdallr-1.1.1/bin/ssoadm create-agent -e FREJA \
        -u amadmin \
        -f $SSO_HOME/resources/pass.txt \
        -b $AGENT_NAME \
        -t WebAgent \
        -s $AM_SERVER_URL/heimdallr-1.1.1 \
        -g $AGENT_SERVER_URL \
        -a userpassword=$SSO_AGENT_PASSWORD


######################################################
#
# install ploicy agent on Apache
#
#######################################################


##### ensuring SSO is deployed ###############
echo "Waiting"
sleep 2
# run the command

# Hack loop to make sure the war is fully deployed
STATUS_CMD="curl -Ls $AM_SERVER_URL/heimdallr-1.1.1"

TIME_WAITING=0
LOOP_INVARIANT=2
printf "Waiting for war to deploy."
until $STATUS_CMD | grep top.location.replace 2>&1 > /dev/null
	do
		sleep $LOOP_INVARIANT
		TIME_WAITING=`expr $TIME_WAITING + 1`
		printf "."
	done
printf "done\n"

############### ensure the apache is shutdown######################

if service httpd status; then
	# TODO: improve this message
	echo "Apache Webserver is running, this needs to be stopped to install policy agent"
	echo "Stopping Puppet to enable Apache to stop...."
	service puppet stop;
	echo "Stopping Apache...."
	service httpd stop;
else
	echo "################################################################################################################################################################"
	echo "Apache appears to be offline, this is not expected, continuing installation of Policy Agent anyway...."
	echo "This was not an expected scenario, Apache should have been running, other system errors may be present, installation is continuing but please check logs.." 
	echo "################################################################################################################################################################"
	
fi


#install the policyagent using parameters defined in policyAgentSettings.conf
# script assumes that webagent will be unzipped to /opt
RESPONSE_FILE=$SSO_HOME/resources/conf/policy-agent.conf
echo "Policy Agent Respoonse file location: $RESPONSE_FILE"

# Password file (PLAINTEXT!!)
echo $SSO_AGENT_PASSWORD > $SSO_HOME/resources/agent-pass.txt

cat << EOF > $RESPONSE_FILE
CONFIG_DIR= /etc/httpd/conf
AM_SERVER_URL= $AM_SERVER_URL
AGENT_URL= $AGENT_SERVER_URL
AGENT_PROFILE_NAME= $SSO_AGENT_NAME
AGENT_PASSWORD_FILE= $SSO_HOME/resources/agent-pass.txt
EOF

/opt/web_agents/apache22_agent/bin/agentAdmin --install --useResponses $RESPONSE_FILE

# restart Apache and puppet
echo "Restarting Apache..."
service httpd start
echo "Restarting Puppet..."
service puppet start
