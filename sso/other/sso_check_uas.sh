#!/bin/bash


print() {
TEXT=$1
sleep 2
echo -e "\n\n"
echo "###########################################"
echo "###  ${TEXT}"
echo "###########################################"
echo -e "\n\n"
}


HOSTNAME=`hostname`
UPPERCASE_HOSTNAME=`echo ${HOSTNAME} | tr '[:lower:]' '[:upper:]'`

print "Check what ntp server being used , Ensure same one is used on TOR server"
/usr/sbin/ntpq -p

print "checking for error messages related to PAM in /var/adm/messages"
grep auth.error /var/adm/messages | tail -10 > /tmp/authmessages
if [ `cat /tmp/authmessages | wc -l` -gt 0 ]; then
  echo -e "\n********WARNING******** Possible Issues with PAM, ceck and investigate contents of /var/adm/messages\n"
  cat /tmp/authmessages
else
  echo "No auth.error entries in  /var/adm/messages "
fi

APP=SHELL_TOOL
CHECK_FILE=/tmp/sso_uas_check
/opt/CTXSmf/bin/ctxqserver app > ${CHECK_FILE}

print "Checking what published applications SUFFIX is used on this UAS, Ensure to use a Unique one when configuring PIB on TOR Peer Nodes"
echo "You can have issues with citrix session being directed to servers in other farms with same published App name if citrix settings not correct"

if [ `grep -c ${UPPERCASE_HOSTNAME} ${CHECK_FILE}` -eq 0 ]; then
  echo "PROBLEM : *****************   No applications published for this server ${UPPERCASE_HOSTNAME} ";
  echo "/opt/CTXSmf/bin/ctxqserver app"
  cat /tmp/sso_uas_check
  exit 1
fi

if [ `grep ${UPPERCASE_HOSTNAME} ${CHECK_FILE} | grep -c ${APP}` -lt 1 ]; then
  echo -e "\nWARNING : *****************   Check xre all applications published ${APP} is missing\n ";
  echo "Use ??? to publish the aaplications"
  echo " /opt/CTXSmf/bin/ctxqserver app "
  cat /tmp/sso_uas_check
  exit 1
fi

if [ `grep ${UPPERCASE_HOSTNAME} ${CHECK_FILE} | grep ${APP} | awk '{print $1}' | cut -d_ -f3 | wc -l` -gt 1 ]; then
   echo "This server has multiple Published Application Suffixs, Ensure you configure the Unique/Correct one in PIB for UI on the TOR Peer servers"
   grep ${UPPERCASE_HOSTNAME} ${CHECK_FILE} | grep ${APP}
   echo -e "\nPublished Application Suffixs found\n"
   grep ${UPPERCASE_HOSTNAME} ${CHECK_FILE} | grep ${APP} | awk '{print $1}' | cut -d_ -f3
   echo "Assuming published app name is HOSTNAME of UAS ${UPPERCASE_HOSTNAME} "
   PIB_NAME_PUBLISHED_APP_SUFFIX=${UPPERCASE_HOSTNAME}
else
  PIB_NAME_PUBLISHED_APP_SUFFIX=`grep ${UPPERCASE_HOSTNAME} ${CHECK_FILE} | grep ${APP} | awk '{print $1}' | cut -d_ -f3`
  echo "This UAS is using just one Published App Suffix ${PIB_NAME_PUBLISHED_APP_SUFFIX} , Ensure you configure this in PIB for UI on the TOR Peer servers"
fi

print "Checkng SSO PAM Module install/loaded on this UAS"
if [ `grep -c libpam_eric_sso /etc/pam.conf` -eq 0 ]; then
  echo "SSO Pam module not loaded on this UAS, Install correct sw version on UAS";
  exit 1
else
     echo "SSO Pam module is loaded";
     grep libpam_eric_sso /etc/pam.conf
fi

print "Checking SSO required files on this **********UAS**********"

FILE=/var/tmp/masterkey

if [ ! -f ${FILE} ]; then
  echo "PROBLEM : *****************   Master Key file missing ${FILE}"
  exit 1
fi
echo "Required File found ${FILE}"
cat ${FILE}

FILE=/var/tmp/counter
if [ ! -f ${FILE} ]; then
  echo "PROBLEM : *****************   counter file missing ${FILE}"
  exit 1
fi
echo "Required File found ${FILE}"
cat ${FILE}

print "Checking order of modules in /etc/pam.conf"

SLO_LINE_NUMBER=`grep -n pam_slo_auth.so.1 /etc/pam.conf | cut -d: -f1`
SSO_LINE_NUMBER=`grep -n libpam_eric_sso.so /etc/pam.conf | cut -d: -f1`

egrep 'pam_slo_auth.so.1|libpam_eric_sso.so' /etc/pam.conf

if [ ${SLO_LINE_NUMBER} -ne `expr ${SSO_LINE_NUMBER} - 1` ]; then
   echo "Problem with ordering of PAM modules, sso should be on line after after slo_auth"
   exit 1
fi
echo -e "\nCheck passed: PAM module ordering of pam_slo_auth.so.1 and libpam_eric_sso.so OK"

print "Checking EC version for ERICspam"
pkginfo -l ERICspam

print "Check which other UAS this UAS can see and which is Master"
/opt/CTXSmf/bin/ctxqserver

print "Log onto these UASs and confirm browser setting is set to ip address of the UAS with /opt/CTXSmf/sbin/ctxbrcfg -b list"
echo "/opt/CTXSmf/sbin/ctxbrcfg -b list"
/opt/CTXSmf/sbin/ctxbrcfg -b list
echo "If binding is not set then may have issues in Test environment where session are being directed to other UAS where same published application name i
s used"

print "Check Citrix sessions currently in use on this UAS"
/opt/CTXSmf/bin/ctxqsession

print "Check Citrix Farm on this UAS"
/opt/CTXSmf/sbin/ctxfarm -l

print "Check Server settings"
echo "/opt/CTXSmf/sbin/ctxbrcfg -m list"
/opt/CTXSmf/sbin/ctxbrcfg -m list
if [ `/opt/CTXSmf/sbin/ctxbrcfg -m list | grep -c never` -eq 0 ]; then
echo "*********Potential problem with UAS setting"
echo "If this is not set to never then may have issues in Test environment where session are being directed to other UAS where same published application name is used"
fi

print "Check the Citrix settings for ???"
echo "/opt/CTXSmf/sbin/ctxbrcfg -r list"
/opt/CTXSmf/sbin/ctxbrcfg -r list

print "Check what ##other UAS# published applications can be seen by this UAS, showing first 20"
grep -i atrc ${CHECK_FILE} | grep -v ${UPPERCASE_HOSTNAME} | awk '{print $3}' | sort -u | head -20

print "Check what published applications on other UAS are using same PIB SUFFIX and can also be seen by this UAS"
if [ `grep ${PIB_NAME_PUBLISHED_APP_SUFFIX} ${CHECK_FILE} | grep -v ${UPPERCASE_HOSTNAME} | wc -l` -eq 0 ]; then
  echo "no other UASs using Published App Suffix ${PIB_NAME_PUBLISHED_APP_SUFFIX}"
else
  echo "These UAS are using the same Published App Suffix ${PIB_NAME_PUBLISHED_APP_SUFFIX}, likely to be proplems "
  grep ${PIB_NAME_PUBLISHED_APP_SUFFIX} ${CHECK_FILE} | grep -v ${UPPERCASE_HOSTNAME}
fi

print "Check which users have citrix sessions open on this UAS"
echo "/opt/CTXSmf/bin/ctxquser"
/opt/CTXSmf/bin/ctxquser

print "Check Citrix sessions currently in use on this UAS"
echo "/opt/CTXSmf/bin/ctxqsession"
/opt/CTXSmf/bin/ctxqsession

#print "check users defined on this server"
#cat /etc/passwd



exit

print "Check SSO required files on this **********Infra**********"

 pkginfo -l ERICcaas
 pkginfo -l ERICsls

FILE=/opt/ericsson/sls/conf/masterkey
if [ ! -f ${FILE} ]; then
  echo "PROBLEM : *****************   Master Key file missing ${FILE}";
  exit 1
fi
echo "Required File found ${FILE}"

FILE=/opt/ericsson/sls/conf/counter
if [ ! -f ${FILE} ]; then
  echo "PROBLEM : *****************   counter file missing ${FILE}";
  exit 1
fi
echo "Required File found ${FILE}"


exit

##OMSAS##
print "Check EC versions required for SSO on this **********OMSAS**********"
pkginfo -l ERICcadm

print "Check SSO required files on this **********OMSAS**********"
#####




exit

print "Check SSO required files on this **********Infra**********"

 pkginfo -l ERICcaas
 pkginfo -l ERICsls

FILE=/opt/ericsson/sls/conf/masterkey
if [ ! -f ${FILE} ]; then
  echo "PROBLEM : *****************   Master Key file missing ${FILE}";
  exit 1
fi
echo "Required File found ${FILE}"
cat ${FILE}
FILE=/opt/ericsson/sls/conf/counter
if [ ! -f ${FILE} ]; then
  echo "PROBLEM : *****************   counter file missing ${FILE}";
  exit 1
fi
echo "Required File found ${FILE}"
cat ${FILE}

exit

##OMSAS##
print "Check EC versions required for SSO on this **********OMSAS**********"
pkginfo -l ERICcadm
#check the rootca.cer file 
print "Check SSO required files on this **********OMSAS**********"
#####

