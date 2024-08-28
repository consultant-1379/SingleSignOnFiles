#!/bin/bash

#
# This sample script contains the commands used for a LITP installation creating
# the definition part for the following configuration:
#
# Type: Virtual-Environment
#
# Config:	MS (Management Server)
#			2 SC Nodes (Service Control Nodes)
#			2 PL Nodes (Pay Load Nodes)
#			MS functions as NFS server
#
# Hardware:	5 Virtual Machines - Peer Servers will need to be manually PXE booted.
#
# Campaigns: Jboss
#
# Target built: SP18
#
# If your LITP hardware configuration differs from this, you will need to
# modify script to suit your own requirements.
#
# Various settings used in this sample script are environment specific,
# these include IP addresses, MAC addresses, netid, TIPC addresses,
# serial numbers, usernames, passwords etc and may also need to be
# modified to suit your requirements.
#
# For more details, please visit the documentation site here:
# https://team.ammeon.com/confluence/display/LITPExt/Landscape+Installation
#


# 
# Helper function for debugging purpose. 
# ----------------------------------------
# Reduces the clutter on the script's output while saving everything in 
# landscape.log file in the user's current directory. Can safely be removed 
# if not needed.

STEP=0
LOGDIR="logs"
if [ ! -d "$LOGDIR" ]; then
    mkdir $LOGDIR
fi
LOGFILE="${LOGDIR}/landscape_definition.log"
if [ -f "${LOGFILE}" ]; then
    mod_date=$(date +%Y%m%d_%H%M%S -r "$LOGFILE")
    NEWLOG="${LOGFILE%.log}-${mod_date}.log"

    if [ -f "${NEWLOG}" ]; then  # in case ntp has reset time and log exists
        NEWLOG="${LOGFILE%.log}-${mod_date}_1.log"
    fi
    cp "$LOGFILE" "${NEWLOG}"
fi

> "$LOGFILE"
function litp() {
        STEP=$(( ${STEP} + 1 ))
        printf "Step %03d: litp %s\n" $STEP "$*" | tee -a "$LOGFILE"
        
        result=$(command litp "$@" | tee -a "$LOGFILE")
        if echo "$result" | grep -i error; then
                exit 1;
        fi
}

# ---------------------------------------------
# DEFINITION STARTS HERE
# ---------------------------------------------

#
# Please refer to documentation for naming conventions (we should create it)
# https://team.ammeon.com/confluence/display/LITPExt/Naming+Conventions
# E.g. the URI part cannot contain dashes (-)
#

# ---------------------------------------------
# CREATE SITE AND CLUSTER DEFINITIONS
# ---------------------------------------------

#
# Create the site definition where our cluster will be hosted
#
litp /definition/deployment1 create deployment-def

# 
# Create the cluster and add all the nodes in it.
# Names sc1, sc2, etc are inticative for the node's role and not the hostname
#
# STORY-2094 Remove cmw-cluster-def
litp /definition/deployment1/cluster1 create cluster-def
litp /definition/deployment1/cluster1/node1 create node-def nodetype=control primarynode=true
litp /definition/deployment1/cluster1/node2 create node-def nodetype=control

# MS1 shouldn't be part of the cluster as it's the server managing the cluster
# This is a workaround for the known bug LITP-xxxx
litp /definition/deployment1/ms1 create node-def nodetype="management"

# Create CMW Cluster Config
litp /definition/cmw_cluster_config create cmw-cluster-config-def
litp /definition/deployment1/cluster1/cmw_cluster_config create component-ref component=cmw_cluster_config
litp /definition/cmw_cluster_config/etf_generator/ create cmw-etf-generator-def
litp /definition/cmw_cluster_config/campaign_generator/ create cmw-campaign-generator-def

# VCS Cluster Config
litp /definition/vcsr create vcs-component-def
litp /definition/vcs_config create vcs-cluster-config-def
litp /definition/deployment1/cluster1/vcs_config create component-ref component=vcs_config
litp /definition/deployment1/cluster1/node1/vcsr create component-ref component=vcsr
litp /definition/deployment1/cluster1/node2/vcsr create component-ref component=vcsr

# Define Components
# Component 1
litp /definition/jee_container create component-def name=jee_container version=1.0.0
litp /definition/jee_container/rpm create package-def name="3PP-jboss-eap_CXP9022745" ensure="installed" repository="Ammeon_Custom"
litp /definition/jee_container/instance create jee-container-def name=jboss instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/jboss_data' home-dir='/home/jboss/{rdni}' messaging-group-address='231.7.7.7' default-multicast='231.7.7.7' messaging-group-port='12342' process-user=litp_jboss  process-group=litp_jboss public-listener='{ip.address}' public-port-base=8080 management-listener='{ip.address}' management-port-base=9990 management-port-native=9999 management-user=admin management-password=passw0rd port-offset=0 command-line-options="-Djgroups.uuid_cache.max_age=5000" jgroups-bind-addr='127.0.0.1' jgroups-mping-mcast-addr='230.0.0.147' jgroups-mping-mcast-port='45831' jgroups-udp-mcast-addr='230.0.0.147' jgroups-udp-mcast-port='45843'
litp /definition/jee_container/instance/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=true
litp /definition/jee_container/instance/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=300
#litp /definition/jee_container/instance/mount create mount-def MountPoint="/jboss_data" BlockDevice="ms1:/exports/comp1_data" FSType="nfs"
litp /definition/jee_container/instance/ip create ip-address-def pool=network net_name=mgmt

# Component 2
litp /definition/example_app create component-def name=example_app version=1.0.0
litp /definition/example_app/pkg create package-def name="jbossExampleApp" ensure="installed" repository="Ammeon_Custom"
litp /definition/example_app/de create deployable-entity-def name=jboss-as-helloworld version=1.1.1 install-source=/opt/jboss-eap/standalone/deployments/jboss-as-helloworld-1.1.1.war app-type=war service=jboss
litp /definition/example_app/de/jee_users create jee-property-def property=max-users value=10
litp /definition/example_app/de/jee_queue create jms-queue-def name=queue101  jndi=myqueue
litp /definition/example_app/de/jee_topic create jms-topic-def name=topic101,second/path  jndi=mytopic
litp /definition/example_app/de/jee_datasource create jee-datasource-def name=datasource driver_name=h2 connection_url=jdbc:oracle:thin:@server1:11521:orcl username=jimmy jndi_name=jboss/TestO123RCL password=passw0rd
litp /definition/example_app/depends create depends-def name=jee_container min-version=1.0.0 scope=service-instance


# Define Service groups
litp /definition/deployment1/cluster1/sg1 create service-group-def node_list="node1,node2" availability_model="nway" version="1.0.1"
litp /definition/deployment1/cluster1/sg1/si create service-instance-def active-count=1 version="1.1.1"
litp /definition/deployment1/cluster1/sg1/si/jee_container create component-ref component="jee_container"
litp /definition/deployment1/cluster1/sg1/si/example_app create component-ref component="example_app"

# ---------------------------------------------
# DEFINE EXTERNAL NTP SERVER
# ---------------------------------------------
litp /definition/deployment1/ntp_1 create ntp-service-def name=ntp_1 external="True"

# ---------------------------------------------
# DEFINE YUM REPOSITORIES  
# ---------------------------------------------

#
# YUM repositories reside on the Management Server, with hostname MS1
#
litp /definition/deployment1/yum_repo1 create repository-service-def name="site_yum_repo_litp" uri="/var/www/html/litp" protocol="file" external="True"
litp /definition/deployment1/yum_repo2 create repository-service-def name="site_yum_repo_custom" uri="/var/www/html/custom" protocol="file" external="True"
litp /definition/deployment1/yum_repo3 create repository-service-def name="site_yum_repo_rhel" uri="/var/www/html/rhel" protocol="file" external="True"

# ---------------------------------------------
# DEFINE OPERATING SYSTEM ROLE(S)
# ---------------------------------------------

#
# Define an OS role with a reference to the distro that will be added to 
# Cobbler (e.g. 'node-iso-x86_64')
#
litp /definition/os create rhel-component-def profile='linux' topo_framework='off'
litp /definition/os/rhel create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/ip create ip-address-def pool=network net_name=mgmt
litp /definition/os/system create generic-system-def pool=systems
litp /definition/os/ks create kickstart-def
litp /definition/os/osms create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/osms/ntp1 create ntp-client-def service=ntp_1

litp /definition/os/ossc create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/ossc/ntp1 create ntp-client-def service=ntp_1
litp /definition/os/ossc/ntp_l2 create ntp-service-def name=ntp_l2


# ---------------------------------------------
# DEFINE A BOOT MANAGER ROLE
# ---------------------------------------------

#
# Define a boot manager (Cobbler Service) and the Kickstart manager running on 
# the MS.
#
litp /definition/cobbler create component-def
litp /definition/cobbler/bootservice create cobbler-service-def name="bootservice"
litp /definition/cobbler/ksmanager create kickstart-manager-def


#
# Assign the boot manager to the Management Server (MS), by creating a role
# reference.
#
litp /definition/deployment1/ms1/ms_boot create component-ref component=cobbler

# ---------------------------------------------
# DEFINE TROUBLESHOOTING TOOLS ROLE
# ---------------------------------------------

#
# Create Troubleshooting Tools role
#
litp /definition/troubleshooting create component-def
litp /definition/troubleshooting/tool1 create package-def name="sysstat" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool2 create package-def name="procps" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool3 create package-def name="bind-utils" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool4 create package-def name="lsof" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool5 create package-def name="ltrace" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool6 create package-def name="screen" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool7 create package-def name="strace" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool8 create package-def name="tcpdump" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool9 create package-def name="traceroute" ensure="installed" repository="RHEL_6.2"
litp /definition/troubleshooting/tool10 create package-def name="vim-enhanced" ensure="installed" repository="RHEL_6.2"

litp /definition/troubleshooting/perm1 create file-def path="/usr/bin/dig" mode="700"
litp /definition/troubleshooting/perm2 create file-def path="/usr/bin/host" mode="700"
litp /definition/troubleshooting/perm3 create file-def path="/usr/sbin/lsof" mode="700"
litp /definition/troubleshooting/perm4 create file-def path="/usr/bin/ltrace" mode="700"
litp /definition/troubleshooting/perm5 create file-def path="/usr/bin/sar" mode="700"
litp /definition/troubleshooting/perm6 create file-def path="/usr/bin/screen" mode="700"
litp /definition/troubleshooting/perm7 create file-def path="/usr/bin/strace" mode="700"
litp /definition/troubleshooting/perm8 create file-def path="/usr/sbin/tcpdump" mode="700"
litp /definition/troubleshooting/perm9 create file-def path="/bin/traceroute" mode="700"
litp /definition/troubleshooting/perm10 create file-def path="/usr/bin/vim" mode="700"


#
# Create a reference to the "troubleshooting role" for each node.
#
litp /definition/deployment1/ms1/troubleshooting create component-ref component=troubleshooting
litp /definition/deployment1/cluster1/node1/troubleshooting create component-ref component=troubleshooting
litp /definition/deployment1/cluster1/node2/troubleshooting create component-ref component=troubleshooting

# ---------------------------------------------
# DEFINE A MYSQL SERVER ROLE
# ---------------------------------------------

#
# Create mysql-server role
#
litp /definition/mysqlserver create component-def
litp /definition/mysqlserver/config create mysql-server-def

#
# Create a reference to the "mysql-server role" for the MS node.
#
litp /definition/deployment1/ms1/mysqlserver create component-ref component=mysqlserver


# ---------------------------------------------
# DEFINE JBOSS ROLES
# ---------------------------------------------

#litp /definition/jboss_source create component-def
#litp /definition/jboss_source/jboss_rpm create package-def name="3PP-jboss-eap_CXP9022745" ensure="installed" repository="Ammeon_Custom"
#litp /definition/jboss_example_app create component-def
#litp /definition/jboss_example_app/example_app create package-def name="jbossExampleApp" ensure="installed" repository="Ammeon_Custom"

#litp /definition/jee1_container create component-def name=jee_container version=1.0.0
#litp /definition/jee1_container/jee1 create jee-container-def name=jee1 instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/var/lib/jboss/{rdni}' home-dir='/home/jboss/{rdni}' messaging-group-address='231.7.7.7' default-multicast='231.7.7.7' messaging-group-port='12342' process-user=litp_jboss  process-group=litp_jboss public-listener='0.0.0.0' public-port-base=8080 management-listener='0.0.0.0' management-port-base=9990 management-port-native=9999 management-user=admin management-password=passw0rd port-offset=200 command-line-options="-Djgroups.uuid_cache.max_age=5000" jgroups-bind-addr='127.0.0.1' jgroups-mping-mcast-addr='230.0.0.147' jgroups-mping-mcast-port='45831' jgroups-udp-mcast-addr='230.0.0.147' jgroups-udp-mcast-port='45843'
#litp /definition/jee1_container/jee1/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=true
#litp /definition/jee1_container/jee1/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=300
#litp /definition/jee1_container/jee1/fw_jee1 create firewalls-def name="006 jee1" dport="8280,10190,10199"

#litp /definition/jee2_container create component-def name=jee_container version=1.0.0
#litp /definition/jee2_container/jee2 create jee-container-def name=jee2 instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/var/lib/jboss/{rdni}' home-dir='/home/jboss/{rdni}' messaging-group-address='231.7.7.7' default-multicast='231.7.7.7' messaging-group-port='12352' process-user=litp_jboss  process-group=litp_jboss public-listener='0.0.0.0' public-port-base=8180 management-listener='0.0.0.0' management-port-base=9890 management-port-native=9899 management-user=admin management-password=passw0rd port-offset=0 command-line-options="-Djgroups.uuid_cache.max_age=5000" jgroups-bind-addr='127.0.0.1' jgroups-mping-mcast-addr='230.0.0.147' jgroups-mping-mcast-port='45831' jgroups-udp-mcast-addr='230.0.0.147' jgroups-udp-mcast-port='45843'
#litp /definition/jee2_container/jee2/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=false
#litp /definition/jee2_container/jee2/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=500
#litp /definition/jee2_container/jee2/fw_jee2 create firewalls-def name="006 jee2" dport="8180,9890,9899"

#litp /definition/example_app1 create component-def
#litp /definition/example_app1/de1 create deployable-entity-def name=jboss-as-helloworld version=1.1.1 install-source=/opt/jboss-eap/standalone/deployments/jboss-as-helloworld-1.1.1.war app-type=war service=jee1 
#litp /definition/example_app1/de1/jee_users create jee-property-def property=max-users value=10
#litp /definition/example_app1/de1/jee_queue create jms-queue-def name=queue101  jndi=myqueue
#litp /definition/example_app1/de1/jee_topic create jms-topic-def name=topic101,second/path  jndi=mytopic
#litp /definition/example_app1/de1/jee_datasource create jee-datasource-def name=datasource driver_name=h2 connection_url=jdbc:oracle:thin:@server1:11521:orcl username=jimmy jndi_name=jboss/TestO123RCL password=passw0rd

#litp /definition/example_app2 create component-def
#litp /definition/example_app2/de2 create deployable-entity-def name=jboss-as-helloworld version=1.1.1 install-source=/opt/jboss-eap/standalone/deployments/jboss-as-helloworld-1.1.1.war app-type=war service=jee2

#
# Create a reference to the "jee role" for node1.
#
#litp /definition/deployment1/cluster1/node1/jboss_source create component-ref component=jboss_source
#litp /definition/deployment1/cluster1/node1/jboss_example_app create component-ref component=jboss_example_app

#litp /definition/deployment1/cluster1/node1/jee1 create component-ref component=jee1_container
#litp /definition/deployment1/cluster1/node1/jee2 create component-ref component=jee2_container

#litp /definition/deployment1/cluster1/node1/example_app1 create component-ref component=example_app1
#litp /definition/deployment1/cluster1/node1/example_app2 create component-ref component=example_app2



# ---------------------------------------------
# DEFINE APACHE ROLE
# ---------------------------------------------

#litp /definition/httpd_comp create component-def
#litp /definition/httpd_comp/httpd_service create lsb-service-def name="httpd" require="apache_pkg"
#litp /definition/httpd_comp/apache_pkg create package-def name="httpd" ensure="installed" repository="RHEL_6.2"

# 
# Create a reference to the apache for node1
#
#litp /definition/deployment1/cluster1/node1/apache1 create component-ref component=httpd_comp


# ---------------------------------------------
# DEFINE APACHE ROLE
# ---------------------------------------------

litp /definition/httpd_comp create component-def
litp /definition/httpd_comp/apache_pkg create package-def name="httpd" ensure="installed" repository="RHEL_6.2"
litp /definition/httpd_comp/httpd_service create lsb-service-def name="httpd" require="apache_pkg"

# 
# Create a reference to the apache for node1
#
litp /definition/deployment1/cluster1/node1/apache1 create component-ref component=httpd_comp


# ---------------------------------------------
# DEFINE PUPPET DASHBOARD ROLE
# ---------------------------------------------

#
# Create puppet-dashboard role
#
litp /definition/puppetdashboard create component-def
litp /definition/puppetdashboard/config create puppet-dashboard-def

#
# Create a reference to the "puppet-dashboard role" for the MS node.
#
litp /definition/deployment1/ms1/puppetdashboard create component-ref component=puppetdashboard

# -------------------------------------------------
# DEFINE NFS SERVICE AND NFS CLIENT ROLES
# -------------------------------------------------

#
# Create NFS export for Core Middleware.
#
litp /definition/nfsshares create component-def
litp /definition/nfsshares/share1 create nfs-export-def share="/exports/cluster" options="rw,sync,no_root_squash" guest="*"
#litp /definition/nfsshares/share2 create nfs-export-def share="/exports/comp1_data" options="rw,sync,no_root_squash" guest="*"

#
# Create a reference to the "nfsshares" role for the MS node.
#
litp /definition/deployment1/ms1/nfsshares create component-ref component=nfsshares


# -------------------------------------------------
# DEFINE YUM REPOSITORY ROLE
# -------------------------------------------------

#
# Create roles for facilitating YUM Repositories.
#
litp /definition/msrepository create component-def

litp /definition/msrepository/repo1 create repository-def name="Ammeon_LITP" service="site_yum_repo_litp"
litp /definition/msrepository/repo2 create repository-def name="Ammeon_Custom" service="site_yum_repo_custom"
litp /definition/msrepository/repo3 create repository-def name="RHEL_6.2" service="site_yum_repo_rhel"
litp /definition/msrepository/yum_repo1 create repository-service-def name="pp_yum_repo_litp" uri="/litp" protocol="http"
litp /definition/msrepository/yum_repo2 create repository-service-def name="pp_yum_repo_custom" uri="/cobbler/ks_mirror/node-iso-x86_64/custom" protocol="http"
litp /definition/msrepository/yum_repo3 create repository-service-def name="pp_yum_repo_rhel" uri="/cobbler/ks_mirror/node-iso-x86_64" protocol="http"
# Reference that role to MS.
litp /definition/deployment1/ms1/repository create component-ref component=msrepository

litp /definition/repository create component-def

litp /definition/repository/repo1 create repository-def name="Ammeon_LITP" service="pp_yum_repo_litp"
litp /definition/repository/repo2 create repository-def name="Ammeon_Custom" service="pp_yum_repo_custom"
litp /definition/repository/repo3 create repository-def name="RHEL_6.2" service="pp_yum_repo_rhel"

# Reference that role to all peer servers.

litp /definition/deployment1/cluster1/node1/repository create component-ref component=repository
litp /definition/deployment1/cluster1/node2/repository create component-ref component=repository


# -------------------------------------------------
# DEFINE LDE (TIPC) SUPPORT ROLE
# -------------------------------------------------

#
# Create LDE role for CMW and reference this role to a pool of tipc addresses.
# Pools are part of the inventory.
#
litp /definition/lde create lde-component-def #share_type="drbd"  # enable drbd "nfs mounts must be removed from cli scripts" drbd and lde will then need to be manually configured
litp /definition/lde/tipc create tipc-address-def pool=tipc

#
# Refernce LDE role for all PSs (Peer Servers) 
#
litp /definition/deployment1/cluster1/node1/lde create component-ref component=lde
litp /definition/deployment1/cluster1/node2/lde create component-ref component=lde


# -----------------------------------------------------------
# DEFINE CAMPAIGN INSTALLER ROLE AND CAMPAIGN BUNDLES
# -----------------------------------------------------------

#
# Order is important when campaigns have dependencies on other campaigns.
# Order is based on the ascending sort order of the resource's definition names
#
litp /definition/cmw_installer create cmw-component-def
#litp /definition/cmw_installer/camp1 create cmw-campaign-def bundle_name="3PP-opendj-CXP9022742_1-R1A01" install_name="3PP-opendj-I-CXP9022742_1-R1A01"      # opendj (on 2 Nodes SC-1, SC-2)
# commenting out jboss campaign to prevent conflict with jee instances
#litp /definition/cmw_installer/camp2 create cmw-campaign-def bundle_name="3PP-jbosseap-CXP9022745_1-R1A01" install_name="3PP-jbosseap-I4-CXP9022745_1-R1A01" # jboss 6.0 EAP (on 4 Nodes SC-1, SC-2, PL-3, PL-4)
#litp /definition/cmw_installer/camp3 create cmw-campaign-def bundle_name="ERIC-examplelog-CXP123456_1-R1A01" install_name="ERIC-examplelog-I4-CXP123456_1-R1A01" # jboss example app on 4 Nodes
 
#litp /definition/cmw_installer/camp4 create cmw-campaign-def bundle_name="COM-CXP9017585_2" install_name="ERIC-COM-I-TEMPLATE-CXP9017585_2-R6A02"  # COM
#litp /definition/cmw_installer/camp5 create cmw-campaign-def bundle_name="COM_SA-CXP9017697_3" install_name="ERIC-ComSaInstall"                    # COM SA
#litp /definition/cmw_installer/camp6 create cmw-campaign-def bundle_name="ERIC-JAVAOAM-CXP9019839_1-R2B09" install_name="ERIC-JAVAOAM-I-2SCxNPL"   # JAVA OAM

#
# Assign CMW installer role to the cluster
#
litp /definition/deployment1/cluster1/cmw_installer create component-ref component=cmw_installer


# -----------------------------------------------------------
# DEFINE ROLES FOR USERS, GROUPS AND SUDOERS
# -----------------------------------------------------------

# LITP Users Role
litp /definition/rd_users create component-def

# Create the Group resource definition with a Group ID = 481
# (we'll later add user "litp_user" to that group)
litp /definition/rd_users/group_litp_user create group-def name=litp_user gid="481"
litp /definition/rd_users/group_litp_jboss create group-def name=litp_jboss gid="482"

#
# Create the users resource definitions
#

litp /definition/rd_users/litp_admin create user-def name=litp_admin umask="022" home="/users/litp_admin" uid="480" gid="0" seluser="unconfined_u"
litp /definition/rd_users/litp_user create user-def name=litp_user umask="022" home="/users/litp_user" uid="481" gid="481" seluser="user_u"
litp /definition/rd_users/litp_jboss create user-def name=litp_jboss umask="022" home="/users/litp_jboss" uid="482" gid="482" seluser="unconfined_u"


# Assign the LITP Users Role to each of the nodes.
litp /definition/deployment1/ms1/users create component-ref component=rd_users
litp /definition/deployment1/cluster1/node1/users create component-ref component=rd_users
litp /definition/deployment1/cluster1/node2/users create component-ref component=rd_users

#
# Define Sudoers Role (rd_sudoers)
#
litp /definition/rd_sudoers create component-def

#
# Define the resource that will manage /etc/sudoers
#
litp /definition/rd_sudoers/sudo_main create sudoers-main-def name=sudo_main

#
# Create the resource definitions for individual rules in /etc/sudoers.d
#
litp /definition/rd_sudoers/sudo_admin create sudoers-def sudorole="ADMIN" users="litp_admin" cmds="/usr/sbin/useradd,/usr/sbin/userdel,/usr/sbin/groupadd,/usr/sbin/groupdel,/bin/cat,/usr/sbin/litpedit,/bin/sed" requirePasswd="FALSE" 
litp /definition/rd_sudoers/sudo_backup create sudoers-def sudorole="BACKUP" users="litp_admin,litp_user" cmds="/usr/bin/netbackup" requirePasswd="TRUE"
litp /definition/rd_sudoers/sudo_verify create sudoers-def sudorole="VERIFY" users="litp_verify" cmds="/sbin/iptables -L" requirePasswd="FALSE"
litp /definition/rd_sudoers/sudo_troubleshoot create sudoers-def sudorole="TROUBLESHOOT" users="litp_admin" cmds="/usr/bin/dig,/usr/bin/host,/usr/sbin/lsof,/usr/bin/ltrace,/usr/bin/sar,/usr/bin/screen,/usr/bin/strace,/usr/sbin/tcpdump,/bin/traceroute,/usr/bin/vim,/sbin/service,/bin/mount,/bin/umount,/usr/bin/virsh,/bin/kill,/sbin/reboot,/sbin/shutdown,/usr/bin/pkill,/sbin/pvdisplay,/sbin/dmsetup,/sbin/multipath,/usr/bin/cobbler,/usr/bin/tail,/sbin/vgdisplay,/sbin/lvdisplay,/bin/rm,/opt/ericsson/nms/litp/litp_landscape/landscape,/usr/bin/which,/sbin/lltconfig,/sbin/gabconfig,/opt/VRTSvcs/bin/hastatus,/opt/VRTSvcs/bin/hacf" requirePasswd="TRUE"

#
# Assign Sudo Role Definition (rd_sudoers) to each of the nodes (node/sudoers is the Role Reference).
#
litp /definition/deployment1/ms1/rd_sudoers create component-ref component=rd_sudoers
litp /definition/deployment1/cluster1/node1/rd_sudoers create component-ref component=rd_sudoers
litp /definition/deployment1/cluster1/node2/rd_sudoers create component-ref component=rd_sudoers


# -----------------------------------------------------------
# DEFINE ROLES SYSLOGD SERVER AND CLIENTS
# -----------------------------------------------------------

#
# Define rsyslog server role and resource definition
#
litp /definition/rd_rsyslog_server create component-def
litp /definition/rd_rsyslog_server/rsyslog_server create rsyslog-server-def rlCentralHost="SC-1"

#
# Define rsyslog client role and resource definition
# (rlCentralHost is set to the hostname of the central log server)
#
litp /definition/rd_rsyslog_client create component-def
litp /definition/rd_rsyslog_client/rsyslog_client create rsyslog-client-def rlCentralHost="SC-1"

#
# The rsyslog centralised server is assigned to SC-1
#
litp /definition/deployment1/cluster1/node1/syslog_central create component-ref component=rd_rsyslog_server

# Make all Peer Servers (PSs) and the Management server (MS) rsyslog clients  
litp /definition/deployment1/ms1/syslog create component-ref component=rd_rsyslog_client
litp /definition/deployment1/cluster1/node2/syslog create component-ref component=rd_rsyslog_client

# Define rsyslog server logrotate rules
litp /definition/logrotate_server_rules create component-def
litp /definition/logrotate_server_rules/syslog create logrotate-def name=syslog path='/var/log/messages /var/log/secure /var/log/maillog /var/log/spooler /var/log/boot.log /var/log/cron /var/log/iptables.log /var/log/litp.log' size=1G dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'
litp /definition/logrotate_server_rules/jboss_logs create logrotate-def name=jboss path='/var/log/jboss.log /var/log/jboss/*/*.log' size=512M dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'

# Define standard logrotate rules (rsyslog client) server
litp /definition/logrotate_rules create component-def
litp /definition/logrotate_rules/syslog create logrotate-def name=syslog path='/var/log/messages /var/log/secure /var/log/maillog /var/log/iptables.log /var/log/spooler /var/log/boot.log /var/log/cron' size=100M dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'
litp /definition/logrotate_rules/jboss_logs create logrotate-def name=jboss path='/var/log/jboss.log /var/log/jboss/*/*.log' size=50M dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'

# Define litp logrotate rules
litp /definition/logrotate_litp create component-def
litp /definition/logrotate_litp/litp create logrotate-def name=litp path='/var/log/litp.log /var/log/litp/*.log' size=50M dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'


# Create reference for server logrotate rules
litp /definition/deployment1/cluster1/node1/logrotate_server_rules create component-ref component=logrotate_server_rules

# Create reference for server logrotate rules
litp /definition/deployment1/ms1/logrotate_rules create component-ref component=logrotate_rules
litp /definition/deployment1/ms1/logrotate_litp create component-ref component=logrotate_litp
litp /definition/deployment1/cluster1/node2/logrotate_rules create component-ref component=logrotate_rules

# ---------------------------------------------
# DEFINE A FIREWALLSMAIN ROLE
# ---------------------------------------------

#
# Create firewallsmain role
#
litp /definition/firewallsmain create component-def
litp /definition/firewallsmain/config create firewalls-main-def

#
# Create a reference to the "firewallsmain role" for the all nodes
#
litp /definition/deployment1/ms1/firewallsmain create component-ref component=firewallsmain
litp /definition/deployment1/cluster1/node1/firewallsmain create component-ref component=firewallsmain
litp /definition/deployment1/cluster1/node2/firewallsmain create component-ref component=firewallsmain

# ---------------------------------------------
# DEFINE FIREWALLS RULES AND OS ROLE REFERENCES
# ---------------------------------------------

#
# Create firewall rules and a reference to the OS role for MS
#
litp /definition/os/osms/fw_basetcp create firewalls-def name="001 basetcp" dport="22,80,111,443,3000,25151,9999"
litp /definition/os/osms/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/osms/fw_hyperic create firewalls-def name="003 hyperic" dport="57004,57005,57006"
litp /definition/os/osms/fw_syslog create firewalls-def name="004 syslog" dport="514"
litp /definition/os/osms/fw_baseudp create firewalls-def name="010 baseudp" dport="67,69,111,123,623,25151" proto="udp"
litp /definition/os/osms/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/osms/fw_icmp create firewalls-def name="100 icmp" proto="icmp" provider="iptables"
litp /definition/os/osms/fw_icmpv6 create firewalls-def name="100 icmpv6" proto="ipv6-icmp" provider="ip6tables"

litp /definition/deployment1/ms1/os create component-ref component=os/osms

#
# Create firewall rules and a reference to the OS role for SCs
#
litp /definition/os/ossc/fw_basetcp create firewalls-def name="001 basetcp" dport="22,80,111,161,162,443,1389,3000,25151,7788,9999"
litp /definition/os/ossc/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/ossc/fw_hyperic create firewalls-def name="003 hyperic" dport="57004,57005,57006"
litp /definition/os/ossc/fw_syslog create firewalls-def name="004 syslog" dport="514"
litp /definition/os/ossc/fw_jboss create firewalls-def name="005 jboss" dport="8080,9990,9999,9876,54321"
litp /definition/os/ossc/fw_baseudp create firewalls-def name="010 baseudp" dport="111,123,623,1129,9876,25151" proto="udp"
litp /definition/os/ossc/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/ossc/fw_icmp create firewalls-def name="100 icmp" proto="icmp" provider="iptables"
litp /definition/os/ossc/fw_icmpv6 create firewalls-def name="100 icmpv6" proto="ipv6-icmp" provider="ip6tables"

litp /definition/deployment1/cluster1/node1/os create component-ref component=os/ossc
litp /definition/deployment1/cluster1/node2/os create component-ref component=os/ossc
#



# -----------------------------------------------------------
# MATERIALISE THE DEFINITION
# -----------------------------------------------------------

# Instantiate (materialise) the Roles/Resources for Site1 within the Landscape
# This will create the placeholders for resources under the /inventory  with
# empty properties that will be filled by elements in the Inventory Section

litp /definition/deployment1 materialise

# ---------------------------------------------
# DEFINITION ENDS HERE
# ---------------------------------------------

# Let's guide the user for the next step (messages need to be improved)
echo "The definition part is completed."
echo "Next step is to run the inventory part"

exit 0
