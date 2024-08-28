#!/bin/bash
#This script is for helping troubleshooting SSO after install.
#It is not part of the product, or documented for use by customers so no TR Reports or bugs reports will be accepted on this scripts"

if [ $# -ne 2 ]; then
     echo "Enter a valid user and a valid user password for the OSS/Ldap connected to, exiting"
     echo "Usage $0 user user_password"
     exit 1
fi
VALID_USER=$1
VALID_PASSWORD=$2

if [ ! -f /ericsson/tor/data/sso/sso.properties ]; then
  echo "*******Problem, SSO properties file /ericsson/tor/data/sso/sso.properties  missing, ****EXITING***"
  exit 1
fi

. /ericsson/tor/data/sso/sso.properties

HOSTNAME=`hostname`

print() {
TEXT=$1
sleep 2
echo -e "\n\n"
echo "###########################################"
echo "### ${HOSTNAME} ${TEXT} ${HOSTNAME}"
echo "###########################################"
echo -e "\n\n"
}
check_ping() {
if [ $# -ne 1 ]; then
   echo " Problem No Server supplied, exiting "
   exit
fi
SERVER=$1
echo " Checking have connectivity with the server ${SERVER} "
ping -c 1 ${SERVER}
if [ $? -ne 0 ]; then
 echo "Cant ping server ${SERVER}"
 exit 1
fi
echo "Ping succesful with IP address ${SERVER}"
}


print "Check which NTP server being used on TOR baldes, check the same is being used on the OSS UAS /usr/sbin/ntpq -p so they are time sycnhronised"
/usr/sbin/ntpq -p

print "Manually Check Contents of /ericsson/tor/data/sso/sso.properties"
cat /ericsson/tor/data/sso/sso.properties

CERT_DIR=/ericsson/tor/data/certificates/sso/
LIST_OF_SECURITY_FILES="rootca.cer ssoserverjboss.key ssoserverjboss.csr ssoserverjboss.crt ssoserverjboss.p12 ssoserverapache.key ssoserverapache.csr  ssoserverapache.crt  ssoserverapache.p12"
print "Check certificates are available that are required in ${CERT_DIR}"
for SEC_FILE in ${LIST_OF_SECURITY_FILES}
 do
  if [ ! -f ${CERT_DIR}${SEC_FILE} ]; then
    echo "***************Problem ${CERT_DIR}${SEC_FILE} is missing, exiting"
    exit 1
  fi
done
echo "All Certs and Keys required are available in ${CERT_DIR}"

print "Check contents of /etc/hosts"
cat /etc/hosts
if [ `grep -c ${UI_PRES_SERVER} /etc/hosts` -ne 2 ]; then
    echo ""
    echo "***************Problem with /etc/hosts , not configured as needed for SSO installation, apache FQDN from DNS missing or sso alias missing"
    cat /etc/hosts
    exit 1
fi
print "Check can ping ${UI_PRES_SERVER}"
check_ping ${UI_PRES_SERVER}

print "Check Campaign Status"
cmw-repository-list --campaign | xargs cmw-campaign-status
if [ `cmw-repository-list --campaign | xargs cmw-campaign-status | grep -v COMMITTED | wc -l` -ne 0 ]; then
  echo " ******* Problem with Campaigns***********"
  exit 1
fi

print "Check Single SignOn and UI RPMs installed"
rpm -qa | grep 'ERICsingle\|ERICssoapa\|ERICsecurity\|ERICssolog\|ERICps'

print "Check if Apache httpd service is running on this node"
service httpd status

print "Check for SSO Apache Module dsame is loaded"
if [ `httpd -M | grep -c dsame` -eq 0 ]; then
  echo "******* Problem SSO Apache Module dsame is not loaded, exiting"
  exit 1
fi
httpd -M | grep dsame
echo "SSO Apache Module dsame is loaded  "

print "Check SSO installation logs in /var/log/messages"
if [ `grep TOR_SSO /var/log/messages | grep -ic "Installation complete"` -ne 2 ]; then
    echo "******* Problem with SSO instalation logs in /var/log/messages , exiting"
    echo " use command : grep TOR_SSO /var/log/messages to see SSO entires in install logs relevant to SSO"
    exit 1
fi
echo "/var/log/messages contains both indicators SSO installed correctly "
grep TOR_SSO /var/log/messages | grep -i "Installation complete"

print "Check port 8666 and 23364 are open"

if [ `iptables -L | grep -c '23364\|8666'` -ne 4 ]; then
    echo "*******Problem Ports not open that are needed for Launcher, 23364 + 8666 exiting"
    exit 1
fi
echo " Ports are open that are needed for Launcher, 23364 + 8666 + 1699 + 4445 + 10389"
iptables -L | grep '23364\|8666\|1699\|4445\|10389'

#print "Checking SSO instalation logs in /var/log/messages"
#grep TOR_SSO /var/log/messages

print "Check sso status"
/opt/ericsson/sso/bin/sso.sh status
if [ $? -ne 0 ]; then 
   echo "Problem with SSO , further investigation needed, /opt/ericsson/sso/bin/sso.sh returning non zero exit code"
   exit 1
fi

print "Check state of Apache Service Units as seen by CMW"
amf-state su all | grep -i 'httpd' -A 4
if  [ `amf-state su all | grep -i 'httpd\|Apache' -A 4 | grep -c =INSTANTIATED` -ne 1 ]; then
 echo "*******Problem with  Apache Service Units, amf-state su all | grep -i 'httpd' -A 4"
exit 1
fi

print "Check state of SSO Service Units as seen by CMW"
amf-state su all | grep -i 'sso' -A 4
if  [ `amf-state su all | grep -i 'sso' -A 4 | grep -c =INSTANTIATED` -ne 2 ]; then
echo "*******Problem with SSO Service Units, amf-state su all | grep -i 'sso' -A 4"
exit 1
fi


print "Check can talk to the SSO 3pp (openAM)) directly using the url of the Jboss instance and it replies to rest call"
curl -s http://sso.${UI_PRES_SERVER}:8080/heimdallr/isAlive.jsp | grep -i "alive" > /tmp/ssopostinstall_check
if [ `grep -c "ALIVE" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with  SSO 3pp (openAM), exiting "
exit 1
fi
cat /tmp/ssopostinstall_check

print "Check openAm does not uthenticate unknown user going directly to the SSO Jboss instance"
curl -s "http://sso.${UI_PRES_SERVER}:8080/heimdallr/identity/authenticate?username=invalidusername&password=notthere" > /tmp/ssopostinstall_check
if [ `grep -c "InvalidCredentials" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with  SSO 3pp (openAM), allowing unknown users to authenticate, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check

print "Check openAm does not authenticate known user with incorrect password going directly to the SSO Jboss instance"
curl -s "http://sso.${UI_PRES_SERVER}:8080/heimdallr/identity/authenticate?username=${VALID_USER}&password=rubbishpw" > /tmp/ssopostinstall_check
if [ `grep -c "InvalidPassword" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with  SSO 3pp (openAM), allowing user with faulty password to authenticate, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check

print "Check openAm ##does## authenticate known user with correct password going directly to the SSO Jboss instance"
curl -s "http://sso.${UI_PRES_SERVER}:8080/heimdallr/identity/authenticate?username=${VALID_USER}&password=${VALID_PASSWORD}" > /tmp/ssopostinstall_check
if [ `grep -c "token" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with  SSO 3pp (openAM), not allowing user with valid password to authenticate, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check

print "Verifying SSL and Apache working and rewrite rules are in use , Check can talk to the SSO 3pp (openAM) through Apcahe RP first using the url of Apache and it replies to rest call"
curl -k -s https://${UI_PRES_SERVER}/heimdallr/isAlive.jsp | grep -i "alive" > /tmp/ssopostinstall_check
if [ `grep -c "ALIVE" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with APACHE / SSO 3pp (openAM), exiting "
exit 1
fi
cat /tmp/ssopostinstall_check


print "Check using SSL that openAm does not uthenticate unknown user via Apache Reverse Proxy"
curl -k -s "https://${UI_PRES_SERVER}/heimdallr/identity/authenticate?username=invalidusername&password=notthere"  > /tmp/ssopostinstall_check
if [ `grep -c "InvalidCredentials" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with APACHE / SSO 3pp (openAM), allowing unknown users to authenticate, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check


print "Check using SSL that openAm does not authenticate known user with incorrect password via Apache Reverse Proxy"
curl -k -s "https://${UI_PRES_SERVER}/heimdallr/identity/authenticate?username=${VALID_USER}&password=rubbishpw"  > /tmp/ssopostinstall_check
if [ `grep -c "InvalidPassword" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with APACHE / SSO 3pp (openAM), allowing user with faulty password to authenticate, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check


print "Check using SSL openAm ##does## authenticate known user with correct password via Apache Reverse Proxy"
curl -k -s "https://${UI_PRES_SERVER}/heimdallr/identity/authenticate?username=${VALID_USER}&password=${VALID_PASSWORD}" > /tmp/ssopostinstall_check
#curl -k -s "https://${UI_PRES_SERVER}/heimdallr/identity/authenticate?username=ssouser&password=ssouser01" > /tmp/ssopostinstall_check
if [ `grep -c "token" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with  SSO 3pp (openAM), not allowing user with valid password to authenticate, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check


print "Check Apache Configuration does not allow http requests and redirects to secure login using Policy agent rules "
curl -s "http://${UI_PRES_SERVER}/heimdallr/identity/authenticate?username=${VALID_USER}&password=${VALID_PASSWORD}" > /tmp/ssopostinstall_check
if [ `grep -c "The document has moved" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with SSO policy agent or SSL configuration , not redirecting to secure login page , exiting "
cat /tmp/ssopostinstall_check
exit 1
fi
grep "The document has moved" /tmp/ssopostinstall_check


print "Check can retrieve list of Applications from UI server Jboss instance"
OSS_APPLICATION_TO_LOOK_FOR=OSS_Explorer
UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`                                      
curl -s -H "X-Tor-UserID:${VALID_USER}" "http://${UI_JBOSS_IP}:8080/rest/apps" > /tmp/ssopostinstall_check
if [ `grep -c "${OSS_APPLICATION_TO_LOOK_FOR}" /tmp/ssopostinstall_check` -eq 0 ]; then
echo "**********problem with retrieving list of applications from UI server ${OSS_APPLICATION_TO_LOOK_FOR} not found"
exit 1
fi
cat /tmp/ssopostinstall_check

print "Check get redirected to login page by Policy Agent Rules"
curl -k "https://${UI_PRES_SERVER}" -I -s | grep Location > /tmp/ssopostinstall_check
if [ `grep -c "Location" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with  SSO 3pp (openAM), not redirecting to login page, exiting "
exit 1
fi
cat /tmp/ssopostinstall_check

print "Check can user login via TOR launcher "
curl -s -iL -k -d "IDToken1=${VALID_USER}&IDToken2=${VALID_PASSWORD}&goto=http://www.google.com&gotoOnFail=http://www.yahoo.com" https://${UI_PRES_SERVER}/login  > /tmp/ssopostinstall_check
if [ `grep -c "www.google.com" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with login mechanism, provided correct user and password via launcher mechanism and did not get expected result"
cat /tmp/ssopostinstall_check
exit 1
fi
echo "Check passed"
                                                      
print "Check attempt to login with invalid credentials via TOR launcher mechanism results in redirect to correct expected place"
curl -s -iL -k -d "IDToken1=${VALID_USER}&IDToken2=rubbishpwd&goto=http://www.google.com&gotoOnFail=http://www.yahoo.com" https://${UI_PRES_SERVER}/login  > /tmp/ssopostinstall_check
if [ `grep -c "www.yahoo.com" /tmp/ssopostinstall_check` -ne 1 ]; then
echo "**********problem with login mechanism, provided incorrect password via launcher mechanism and did not get expected result"
cat /tmp/ssopostinstall_check
exit 1
fi
echo "Check passed"

print "Check certificates imported into keystore correctly"
/usr/java/default/bin/keytool -list -alias sso-server -keystore /usr/java/default/jre/lib/security/cacerts -storepass changeit
/usr/java/default/bin/keytool -list -alias apache-server -keystore /usr/java/default/jre/lib/security/cacerts -storepass changeit
/usr/java/default/bin/keytool -list -alias sso -keystore /usr/java/default/jre/lib/security/cacerts -storepass changeit

print "Check SSO sanity check"
/opt/ericsson/sso/bin/sanity-check.sh

print "check PIB properties for UI are set, Ensure these values match your UAS and published application names"
/opt/ericsson/PlatformIntegrationBridge/etc/config.py read --all --service_identifier=Presentation_Server
