#!/bin/bash

set -x

. /opt/ericsson/sso/resources/conf/site-configuration.conf
# Use common LITP variables
. /opt/ericsson/sso/resources/conf/litp-vars.conf

# use common global variables
. /opt/ericsson/sso/resources/conf/env-vars.conf

# Set up JAVA_HOME
export JAVA_HOME=$SSO_HOME/resources/jre

######################################################
#
# install ploicy agent on Apache
#
#######################################################

# Some vars
AGENT_HOME=$SSO_HOME/resources/web_agents/apache22_agent

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
	service puppet stop
	echo "Stopping Apache...."
	service httpd stop
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
AM_SERVER_URL= $AM_SERVER_URL/heimdallr-1.1.1
AGENT_URL= $AGENT_SERVER_URL
AGENT_PROFILE_NAME= $SSO_AGENT_NAME
AGENT_PASSWORD_FILE= $SSO_HOME/resources/agent-pass.txt
EOF

cat $RESPONSE_FILE

# We have to pretend that we have already installed an agent, therefore
# we will not be prompted to agree to the license agreement
echo $USER=`date +"%m/%d/%Y %H\:%M\:%S %Z"` > $AGENT_HOME/data/license.log



# The main command
$SSO_HOME/resources/web_agents/apache22_agent/bin/agentadmin --install --useResponse $RESPONSE_FILE




#######################################################
#
# SELinux configuration - httpd has new modules to load
# from a non /etc/httpd/modules directory
#
#######################################################

# Get the name of the latest Agent_ install directory, in case
# there was a filed installation earlier
CURRENT_AGENT_DIR=`awk '/Agent_/{print $2}' $SSO_HOME/resources/web_agents/apache22_agent/data/.amAgentLookup`

# Change the security context of the modules
chcon -u system_u -t httpd_modules_t $AGENT_HOME/lib/*

# Change the security context for the config files
chcon -u system_u -t httpd_config_t $AGENT_HOME/$CURRENT_AGENT_DIR/config/*

# Change the security context for the log files
chcon -R -t httpd_log_t $AGENT_HOME/$CURRENT_AGENT_DIR/logs

# Edit the properties file to point to our Realm
#
# Find the pattern matching a space, followed by forward slash, followed by end-of-line
# replace it with  a space, a forward slash, and the realm name = $REALM_NAME
# Keep a backup of the poperties file
sed -i.bak "s:\ /$:\ /${REALM_NAME}:g" $AGENT_HOME/$CURRENT_AGENT_DIR/config/OpenSSOAgentBootstrap.properties

# Quick test
grep com.sun.identity.agents.config.organization.name $AGENT_HOME/$CURRENT_AGENT_DIR/config/OpenSSOAgentBootstrap.properties

# Bug fix for agent 3.04
export NSS_STRICT_NOFORK="DISABLED" 
export NSS_STRICT_SHUTDOWN=""

# restart Apache and puppet
echo "Restarting Apache..."
service httpd start
echo "Restarting Puppet..."
service puppet start
