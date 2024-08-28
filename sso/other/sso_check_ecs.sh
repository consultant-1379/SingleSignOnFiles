#!/bin/bash
echo "Checking versions of SW needed for SSO"

SOME_DIRECTORY_ONLY_ON_INFRA=/opt/CTXSls
if [ -d ${SOME_DIRECTORY_ONLY_ON_INFRA} ]; then

   echo "Running check on Infra/O&M Services"

   echo "Checking version of ERICcaas"
   pkginfo -l ERICcaas  | grep DESC
   pkginfo -l ERICcaas  | grep VERSION

   echo "Checking version of ERICsls"
   pkginfo -l ERICsls   | grep DESC
   pkginfo -l ERICsls   | grep VERSION
   
   echo "Checking version of ERICsinst"
   pkginfo -l ERICsinst | grep DESC
   pkginfo -l ERICsinst | grep VERSION

fi

SOME_DIRECTORY_ONLY_ON_UAS=/opt/CTXSmf

if [ -d ${SOME_DIRECTORY_ONLY_ON_UAS} ]; then
   echo "Running check on UAS"
   echo "Checking version of ERICspam"
   pkginfo -l ERICspam   | grep DESC
   pkginfo -l ERICspam   | grep VERSION

   if [ ! -d /var/tmp/SSO_PAM_Module ]; then
   echo "problem directory containing SSO_PAM_Module is missing"

   ls -l  /var/tmp/SSO_PAM_Module | grep 19089

   echo "Checkng SSO PAM Module install/loaded on this UAS"
      if [ `grep -c libpam_eric_sso /etc/pam.conf` -eq 0 ]; then
           echo "SSO Pam module not loaded on this UAS, Install correct sw version on UAS";
           exit 1
      else
           echo "SSO Pam module is loaded";
           grep libpam_eric_sso /etc/pam.conf
      fi
   fi
fi

SOME_DIRECTORY_ONLY_ON_OMSAS=/opt/ericsson/cadm
if [ -d ${SOME_DIRECTORY_ONLY_ON_OMSAS} ]; then
  echo "Running check on OMSAS"
      echo "Checking version of ERICcadm"
   pkginfo -l ERICcadm   | grep DESC
   pkginfo -l ERICcadm   | grep VERSION
fi
