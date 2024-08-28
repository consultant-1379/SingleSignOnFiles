#!/bin/bash
ECHO=/bin/echo

UI_JBOSS_IP=`ps -ef | grep UI | grep Xmx | egrep -o  "\-Djboss\.bind\.address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+"|awk -F\= '{print $NF}' | head -1`
if [ -z ${UI_JBOSS_IP} ]; then
  echo "********problem getting IP of JBOSS UI instance, exiting "
  exit 1
fi

UAS_PUBAPP_SUFFIX=MASTERSERVICE

#atrcxb2584
UAS_IP=10.59.132.78
WEB_HOST_DEFAULT=atrcxb2595-2596ossfs.athtem.eei.ericsson.se

#atrcxb2591
UAS_IP=10.59.132.98
WEB_HOST_DEFAULT=atrcxb2597-2598ossfs.athtem.eei.ericsson.se

if [ $# -eq 3 ]; then
  UAS_PUBAPP_SUFFIX=$1
  UAS_IP=$2
  WEB_HOST_DEFAULT=$3
  ${ECHO} "using UAS_PUBAPP_SUFFIX=${UAS_PUBAPP_SUFFIX} , UAS_IP=${UAS_IP}  OSS=${WEB_HOST_DEFAULT}"
else
  ${ECHO} "Enter UAS PUBLISHED APP SUFFIX, UAS IP , OSS Full Qualified Domain name"
  ${ECHO} "Example: $0 ${UAS_PUBAPP_SUFFIX} ${UAS_IP} ${WEB_HOST_DEFAULT}"
  exit
fi


OSS_MONIITORING_WEBHOST=${WEB_HOST_DEFAULT}
ENIQ_EVENT_WEBHOST=${WEB_HOST_DEFAULT}
OSS_WEBHOST=${WEB_HOST_DEFAULT}
APACHE_DNS_NAME_ALIAS=`grep UI_PRES_SERVER /ericsson/tor/data/sso/sso.properties | cut -d= -f2`
ENIQ_STATS_WEBHOST=${WEB_HOST_DEFAULT}
ENIQ_MANAGEMENT_WEBHOST=${WEB_HOST_DEFAULT}
ALEX_URL=cpistore.internal.ericsson.com

curl -s -X GET "http://${UI_JBOSS_IP}:8080/pib/configurationService/updateConfigParameterValue?paramName=PresentationService_icaHost&paramValue=default:${UAS_PUBAPP_SUFFIX},icaHost1:${UAS_PUBAPP_SUFFIX},icaHost2:${UAS_PUBAPP_SUFFIX}&serviceIdentifier=Presentation_Server"
sleep 5
curl -s -X GET "http://${UI_JBOSS_IP}:8080/pib/configurationService/updateConfigParameterValue?paramName=PresentationService_webHost&paramValue=default:${WEB_HOST_DEFAULT},localhost:localhost,ossMonitoringHost:${OSS_MONIITORING_WEBHOST},eniqEventsHost:${ENIQ_EVENT_WEBHOST},ossHost1:${OSS_WEBHOST},eniqStatsHost:${ENIQ_STATS_WEBHOST},eniqManagement:${ENIQ_MANAGEMENT_WEBHOST},logviewer:${APACHE_DNS_NAME_ALIAS},alexHost:${ALEX_URL}&serviceIdentifier=Presentation_Server"
sleep 5
curl -s -X GET "http://${UI_JBOSS_IP}:8080/pib/configurationService/updateConfigParameterValue?paramName=PresentationService_webPort&paramValue=default:443,unsecurePort:80,logviewer:5601,secure:443,appServer:8080,app2:8181,ossPort1:57004,ossPort2:18080,ossMonitoring:57005&serviceIdentifier=Presentation_Server"
sleep 5
curl -s -X GET "http://${UI_JBOSS_IP}:8080/pib/configurationService/updateConfigParameterValue?paramName=PresentationService_webProtocol&paramValue=default:https,secure:https,unsecure:http&serviceIdentifier=Presentation_Server"
sleep 5
curl -s -X GET "http://${UI_JBOSS_IP}:8080/pib/configurationService/updateConfigParameterValue?paramName=PresentationService_icaAddr&paramValue=default:${UAS_IP},icaAddr:${UAS_IP},icaAddr1:${UAS_IP},icaAddr2:${UAS_IP}&serviceIdentifier=Presentation_Server"

