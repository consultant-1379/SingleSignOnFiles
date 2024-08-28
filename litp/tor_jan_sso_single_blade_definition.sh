#!/bin/bash

#
# This sample script contains the commands used for a LITP installation creating
# the definition part for the following configuration:
#
# Type: Single-Blade
#
# Config:	MS (Managing Server)
#			2 SC Nodes (Service Control Nodes)
#			2 PL Nodes (Pay Load Nodes)
#			1 NFS Node (SFS/NFS network filesystems)
#
# Hardware:	One physical server (Blade or Rackmount) and managed nodes are
#			installed as VMs in MS1.
#
# Campaigns: Jboss
#
# Target built: SP20
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
        
        command litp "$@" 2>&1 | tee -a "$LOGFILE"
        if [ "${PIPESTATUS[0]}" -gt 0 ]; then
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
# Names sc1, sc2, pl3 etc are inticative for the node's role and not the hostname
#
litp /definition/deployment1/cluster1 create cmw-cluster-def
litp /definition/deployment1/cluster1/sc1 create node-def nodetype="control" primarynode=true
litp /definition/deployment1/cluster1/sc2 create node-def nodetype="control"
litp /definition/deployment1/cluster1/pl3 create node-def nodetype="payload"
litp /definition/deployment1/cluster1/pl4 create node-def nodetype="payload"
litp /definition/deployment1/cluster1/nfs1 create node-def

# MS1 shouldn't be part of the cluster as it's the server managing the cluster
# This is a workaround for the known bug LITP-xxxx
litp /definition/deployment1/ms1 create node-def nodetype="management"

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

litp /definition/os/ospl create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/ospl/ntp1 create ntp-client-def service=ntp_l2 name=ntp_l2

litp /definition/os/osnfs create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/osnfs/ntp1 create ntp-client-def service=ntp_l2 name=ntp_l2

# ---------------------------------------------
# DEFINE A SUPERVISOR ROLE (HYPERIC)
# ---------------------------------------------

#
# Define Hyperic server role setup
#
litp /definition/hyperics create component-def
litp /definition/hyperics/hyserver create hyperic-server-def

#
# Define Hyperic agent role setup
#
litp /definition/hyperica create component-def
litp /definition/hyperica/hyagent create hyperic-agent-def

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

# ---------------------------------------------
# DEFINE A LIBVIRT ROLE
# ---------------------------------------------

#
# Create the libvirt vm-service-def role.
#
litp /definition/libvirt create component-def
litp /definition/libvirt/vmservice create vm-service-def
litp /definition/libvirt/libvirtd_logrotate_rules create logrotate-def name=libvirtd path='/var/log/libvirt/*.log' size=50M dateext=true dateformat='-%Y%m%d-%s' rotate=4 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'
litp /definition/libvirt/libvirtd_qemu_rules create logrotate-def name='libvirtd.qemu' path='/var/log/libvirt/qemu/*.log' size=50M dateext=true dateformat='-%Y%m%d-%s' rotate=4 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'

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

# ---------------------------------------------
# DEFINE A MYSQL SERVER ROLE
# ---------------------------------------------

#
# Create mysql-server role
#
litp /definition/mysqlserver create component-def
litp /definition/mysqlserver/config create mysql-server-def


# ---------------------------------------------
# DEFINE JBOSS ROLES
# ---------------------------------------------

litp /definition/jboss_source create component-def
litp /definition/jboss_source/jboss_rpm create package-def name="3PP-jboss-eap_CXP9022745" ensure="installed" repository="Ammeon_Custom"
litp /definition/jboss_example_app create component-def
litp /definition/jboss_example_app/example_app create package-def name="jbossExampleApp" ensure="installed" repository="Ammeon_Custom"

litp /definition/jee1_container create component-def name=jee_container version=1.0.0
litp /definition/jee1_container/jee1 create jee-container-def name=jee1 instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/var/lib/jboss{rdni}' home-dir='/home/jboss/{rdni}' messaging-group-address='231.7.7.7' default-multicast='231.7.7.7' messaging-group-port='12342' process-user=litp_jboss  process-group=litp_jboss public-listener='0.0.0.0' public-port-base=8080 management-listener='0.0.0.0' management-port-base=9990 management-port-native=9999 management-user=admin management-password=passw0rd port-offset=200 command-line-options="-Djgroups.uuid_cache.max_age=5000" jgroups-bind-addr='127.0.0.1' jgroups-mping-mcast-addr='230.0.0.147' jgroups-mping-mcast-port='45831' jgroups-udp-mcast-addr='230.0.0.147' jgroups-udp-mcast-port='45843'
litp /definition/jee1_container/jee1/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=true
litp /definition/jee1_container/jee1/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=300
litp /definition/jee1_container/jee1/fw_jee1 create firewalls-def name="006 jee1" dport="8280,10190,10199"

litp /definition/jee2_container create component-def name=jee_container version=1.0.0
litp /definition/jee2_container/jee2 create jee-container-def name=jee2 instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/var/lib/jboss{rdni}' home-dir='/home/jboss/{rdni}' messaging-group-address='231.7.7.7' default-multicast='231.7.7.7' messaging-group-port='12352' process-user=litp_jboss  process-group=litp_jboss public-listener='0.0.0.0' public-port-base=8180 management-listener='0.0.0.0' management-port-base=9890 management-port-native=9899 management-user=admin management-password=passw0rd port-offset=0 command-line-options="-Djgroups.uuid_cache.max_age=5000" jgroups-bind-addr='127.0.0.1' jgroups-mping-mcast-addr='230.0.0.147' jgroups-mping-mcast-port='45831' jgroups-udp-mcast-addr='230.0.0.147' jgroups-udp-mcast-port='45843'
litp /definition/jee2_container/jee2/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=false
litp /definition/jee2_container/jee2/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=500
litp /definition/jee2_container/jee2/fw_jee2 create firewalls-def name="006 jee2" dport="8180,9890,9899"

litp /definition/example_app1 create component-def name=example_app_1 version=1.0.0
litp /definition/example_app1/de1 create deployable-entity-def name=jboss-as-helloworld version=1.1.1 install-source=/opt/jboss-eap/standalone/deployments/jboss-as-helloworld-1.1.1.war app-type=war service=jee1 
litp /definition/example_app1/de1/jee_users create jee-property-def property=max-users value=10
litp /definition/example_app1/de1/jee_queue create jms-queue-def name=queue101  jndi=myqueue
litp /definition/example_app1/de1/jee_topic create jms-topic-def name=topic101,second/path  jndi=mytopic
litp /definition/example_app1/de1/jee_datasource create jee-datasource-def name=datasource driver_name=h2 connection_url=jdbc:oracle:thin:@server1:11521:orcl username=jimmy jndi_name=jboss/TestO123RCL password=passw0rd
litp /definition/example_app1/depends_01 create depends-def name=jee_container min-version=1.0.0 scope=node
litp /definition/example_app1/conflicts_01 create conflicts-def name=example_app_2 min-version=1.0.0 max-version=1.2.0 scope=service-instance


litp /definition/example_app2 create component-def name=example_app_2 version=1.0.0
litp /definition/example_app2/de2 create deployable-entity-def name=jboss-as-helloworld version=1.1.1 install-source=/opt/jboss-eap/standalone/deployments/jboss-as-helloworld-1.1.1.war app-type=war service=jee2
litp /definition/example_app2/depends_01 create depends-def name=jee_container min-version=1.0.0 scope=node
litp /definition/example_app2/conflicts_01 create conflicts-def name=example_app_1 version=1.0 scope=service-instance

#
# Create a reference to the "jee role" for node1.
#
litp /definition/deployment1/cluster1/sc1/jboss_source create component-ref component=jboss_source
litp /definition/deployment1/cluster1/sc1/jboss_example_app create component-ref component=jboss_example_app

litp /definition/deployment1/cluster1/sc1/jee1 create component-ref component=jee1_container
litp /definition/deployment1/cluster1/sc1/jee2 create component-ref component=jee2_container

litp /definition/deployment1/cluster1/sc1/example_app1 create component-ref component=example_app1
litp /definition/deployment1/cluster1/sc1/example_app2 create component-ref component=example_app2


# ---------------------------------------------
# DEFINE APACHE ROLE
# ---------------------------------------------

#litp /definition/httpd_comp create component-def
#litp /definition/httpd_comp/apache_pkg create package-def name="httpd" ensure="installed" repository="RHEL_6.2"
#litp /definition/httpd_comp/httpd_service create lsb-service-def name="httpd" require="apache_pkg"

# 
# Create a reference to the apache for node1
#
#litp /definition/deployment1/cluster1/sc1/apache1 create component-ref component=httpd_comp


# ---------------------------------------------
# DEFINE PUPPET DASHBOARD ROLE
# ---------------------------------------------

#
# Create puppet-dashboard role
#
litp /definition/puppetdashboard create component-def
litp /definition/puppetdashboard/config create puppet-dashboard-def

# -------------------------------------------------
# DEFINE NFS SERVICE AND NFS CLIENT ROLES
# -------------------------------------------------

#
# nas-service allows the LITP designer to specify the nfs server details.
# The "share" parameter is the unique identifier that
# collates the mountpoints defined with nas-client on the clients with the
# exported filesystems on the SFS server.
#
litp /definition/nasinfo create component-def
litp /definition/nasinfo/export1 create nas-service-def options="rw,sync,no_root_squash" share="litp_cluster"

#
# Define nfs server Role - only needed for RHEL nfs this makes sure that the nfs daemon and required
# packages are online on the RHEL nfs server
#
litp /definition/nfssystem create component-def
litp /definition/nfssystem/rhel create nas-rhel-server-def

#
# Create the SFS client role for Core Middleware.
# SIZE is per node, N nodes will require (2G + 2G + 2G) = Nx6G on the SFS server
#
litp /definition/sfs_client create component-def
litp /definition/sfs_client/sfs_share_1 create nas-client-def mountpoint="/cluster" share="litp_cluster" shared_size="6G"

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

litp /definition/repository create component-def

litp /definition/repository/repo1 create repository-def name="Ammeon_LITP" service="pp_yum_repo_litp"
litp /definition/repository/repo2 create repository-def name="Ammeon_Custom" service="pp_yum_repo_custom"
litp /definition/repository/repo3 create repository-def name="RHEL_6.2" service="pp_yum_repo_rhel"

# -------------------------------------------------
# DEFINE LDE (TIPC) SUPPORT ROLE
# -------------------------------------------------

#
# Create LDE role for CMW and reference this role to a pool of tipc addresses.
# Pools are part of the inventory.
#
litp /definition/lde create lde-component-def #share_type="drbd"  # enable drbd "nfs mounts must be removed from cli scripts" drbd and lde will then need to be manually configured
litp /definition/lde/tipc create tipc-address-def pool=tipc

# -----------------------------------------------------------
# DEFINE CAMPAIGN INSTALLER ROLE AND CAMPAIGN BUNDLES
# -----------------------------------------------------------

#
# Order is important when campaigns have dependencies on other campaigns.
# Order is based on the ascending sort order of the resource's definition names
#
litp /definition/cmw_installer create cmw-component-def
litp /definition/cmw_installer/camp1 create cmw-campaign-def bundle_name="3PP-opendj-CXP9022742_1-R1A01" install_name="3PP-opendj-I-CXP9022742_1-R1A01"        # opendj (on 2 Nodes SC-1, SC-2)
# commenting out jboss campaign to prevent conflict with jee instances
#litp /definition/cmw_installer/camp2 create cmw-campaign-def bundle_name="3PP-jbosseap-CXP9022745_1-R1A01" install_name="3PP-jbosseap-I4-CXP9022745_1-R1A01"   # jboss 6.0 EAP (on 4 Nodes SC-1, SC-2, PL-3, PL-4)
litp /definition/cmw_installer/camp3 create cmw-campaign-def bundle_name="ERIC-examplelog-CXP123456_1-R1A01" install_name="ERIC-examplelog-I4-CXP123456_1-R1A01" # jboss example app on 4 Nodes
litp /definition/cmw_installer/camp_ammeon create cmw-campaign-def bundle_name="ammeonApp1-CXP12345_1-R1A01-1.noarch" install_name="3PP-ammeonApp1-InstCamp-R1A01" bundle_type="rpm" #ammeon app upgrade campaign

#litp /definition/cmw_installer/camp4 create cmw-campaign-def bundle_name="COM-CXP9017585_2" install_name="ERIC-COM-I-TEMPLATE-CXP9017585_2-R6A02"  # COM
#litp /definition/cmw_installer/camp5 create cmw-campaign-def bundle_name="COM_SA-CXP9017697_3" install_name="ERIC-ComSaInstall"                    # COM SA
#litp /definition/cmw_installer/camp6 create cmw-campaign-def bundle_name="ERIC-JAVAOAM-CXP9019839_1-R2B09" install_name="ERIC-JAVAOAM-I-2SCxNPL"   # JAVA OAM

#TOR-UI : Deployment
litp /definition/cmw_installer/camp7 create cmw-campaign-def bundle_name="ERIC-jboss-ews_CXP123456-R1A01" install_name="ERIC-jboss-ews-UI-Camp"
litp /definition/cmw_installer/camp8 create cmw-campaign-def bundle_name="cmip_CXP123456-R1B01-1.x86_64" install_name="ERIC-cmip-UI-Camp"

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
litp /definition/logrotate_litp/savefiles create logrotate-def name=savefiles path='/var/lib/landscape/*.json' dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true rotate_every=day

# ---------------------------------------------
# DEFINE A FIREWALLSMAIN ROLE
# ---------------------------------------------

#
# Create firewallsmain role
#
litp /definition/firewallsmain create component-def
litp /definition/firewallsmain/config create firewalls-main-def

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
litp /definition/os/osms/fw_baseudp create firewalls-def name="010 baseudp" dport="67,69,123,623,25151" proto="udp"
litp /definition/os/osms/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/osms/fw_icmp create firewalls-def name="100 icmp" proto="icmp" provider="iptables"
litp /definition/os/osms/fw_icmpv6 create firewalls-def name="100 icmpv6" proto="ipv6-icmp" provider="ip6tables"

#
# Create rules and a reference to the OS role for SCs
#
litp /definition/os/ossc/fw_basetcp create firewalls-def name="001 basetcp" dport="22,80,111,161,162,443,1389,3000,25151,7788,9999"
litp /definition/os/ossc/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/ossc/fw_hyperic create firewalls-def name="003 hyperic" dport="57004,57005,57006"
litp /definition/os/ossc/fw_syslog create firewalls-def name="004 syslog" dport="514"
litp /definition/os/ossc/fw_jboss create firewalls-def name="005 jboss" dport="9876,54321"
litp /definition/os/ossc/fw_baseudp create firewalls-def name="010 baseudp" dport="111,123,623,1129,9876,25151" proto="udp"
litp /definition/os/ossc/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/ossc/fw_icmp create firewalls-def name="100 icmp" proto="icmp" provider="iptables"
litp /definition/os/ossc/fw_icmpv6 create firewalls-def name="100 icmpv6" proto="ipv6-icmp" provider="ip6tables"

#
# Create firewall rules and a reference to the OS role for PLs
#
litp /definition/os/ospl/fw_basetcp create firewalls-def name="001 basetcp" dport="22,80,111,161,162,443,1389,3000,25151,7788,9999"
litp /definition/os/ospl/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/ospl/fw_hyperic create firewalls-def name="003 hyperic" dport="57004,57005,57006"
litp /definition/os/ospl/fw_syslog create firewalls-def name="004 syslog" dport="514"
litp /definition/os/ospl/fw_jboss create firewalls-def name="005 jboss" dport="9876,54321"
litp /definition/os/ospl/fw_baseudp create firewalls-def name="010 baseudp" dport="111,123,623,1129,9876,25151" proto="udp"
litp /definition/os/ospl/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/ospl/fw_icmp create firewalls-def name="100 icmp" proto="icmp" provider="iptables"
litp /definition/os/ospl/fw_icmpv6 create firewalls-def name="100 icmpv6" proto="ipv6-icmp" provider="ip6tables"

#
# Create rules and a reference to the OS role for NFS
#
litp /definition/os/osnfs/fw_basetcp create firewalls-def name="001 basetcp" dport="22,80,111,161,162,443,3000,9999"
litp /definition/os/osnfs/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/osnfs/fw_syslog create firewalls-def name="003 syslog" dport="514"
litp /definition/os/osnfs/fw_baseudp create firewalls-def name="010 baseudp" dport="111,123,623" proto="udp"
litp /definition/os/osnfs/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/osnfs/fw_icmp create firewalls-def name="100 icmp" proto="icmp" provider="iptables"
litp /definition/os/osnfs/fw_icmpv6 create firewalls-def name="100 icmpv6" proto="ipv6-icmp" provider="ip6tables"

# -----------------------------------------------------------
# DEFINE SOLUTION AND ASSIGN ROLES
# -----------------------------------------------------------

# Primary Node
litp /definition/primary_node create solution-def description="primarynodev1" name="primarynodev1" solution_type="BASIC" version="1.1.1"
litp /definition/primary_node/firewallsmain create component-ref component=firewallsmain
litp /definition/primary_node/os create component-ref component=os/ossc
litp /definition/primary_node/troubleshooting create component-ref component=troubleshooting
litp /definition/primary_node/repository create component-ref component=repository
litp /definition/primary_node/lde create component-ref component=lde
litp /definition/primary_node/users create component-ref component=rd_users
litp /definition/primary_node/rd_sudoers create component-ref component=rd_sudoers
litp /definition/primary_node/syslog_central create component-ref component=rd_rsyslog_server
litp /definition/primary_node/logrotate_server_rules create component-ref component=logrotate_server_rules
litp /definition/primary_node/sfs create component-ref component=sfs_client
litp /definition/primary_node/hypericagent create component-ref component=hyperica

# Litp SC Node
litp /definition/litp_sc_node create solution-def description="litp_sc_nodev1" name="litpscnodev1" solution_type="BASIC" version="1.1.1"
litp /definition/litp_sc_node/firewallsmain create component-ref component=firewallsmain
litp /definition/litp_sc_node/os create component-ref component=os/ossc
litp /definition/litp_sc_node/troubleshooting create component-ref component=troubleshooting
litp /definition/litp_sc_node/repository create component-ref component=repository
litp /definition/litp_sc_node/lde create component-ref component=lde
litp /definition/litp_sc_node/users create component-ref component=rd_users
litp /definition/litp_sc_node/rd_sudoers create component-ref component=rd_sudoers
litp /definition/litp_sc_node/syslog create component-ref component=rd_rsyslog_client
litp /definition/litp_sc_node/logrotate_rules create component-ref component=logrotate_rules
litp /definition/litp_sc_node/sfs create component-ref component=sfs_client
litp /definition/litp_sc_node/hypericagent create component-ref component=hyperica

# Litp PL Node
litp /definition/litp_pl_node create solution-def description="litp_pl_nodev1" name="litpplnodev1" solution_type="BASIC" version="1.1.1"
litp /definition/litp_pl_node/firewallsmain create component-ref component=firewallsmain
litp /definition/litp_pl_node/os create component-ref component=os/ospl
litp /definition/litp_pl_node/troubleshooting create component-ref component=troubleshooting
litp /definition/litp_pl_node/repository create component-ref component=repository
litp /definition/litp_pl_node/lde create component-ref component=lde
litp /definition/litp_pl_node/users create component-ref component=rd_users
litp /definition/litp_pl_node/rd_sudoers create component-ref component=rd_sudoers
litp /definition/litp_pl_node/syslog create component-ref component=rd_rsyslog_client
litp /definition/litp_pl_node/logrotate_rules create component-ref component=logrotate_rules
litp /definition/litp_pl_node/sfs create component-ref component=sfs_client
litp /definition/litp_pl_node/hypericagent create component-ref component=hyperica

# MS Node
litp /definition/ms_node create solution-def description="msnodev1" name="msnodev1" solution_type="BASIC" version="1.1.1"
litp /definition/ms_node/firewallsmain create component-ref component=firewallsmain
litp /definition/ms_node/os create component-ref component=os/osms
litp /definition/ms_node/ms_boot create component-ref component=cobbler
litp /definition/ms_node/troubleshooting create component-ref component=troubleshooting
litp /definition/ms_node/mysqlserver create component-ref component=mysqlserver
litp /definition/ms_node/puppetdashboard create component-ref component=puppetdashboard
litp /definition/ms_node/repository create component-ref component=msrepository
litp /definition/ms_node/users create component-ref component=rd_users
litp /definition/ms_node/rd_sudoers create component-ref component=rd_sudoers
litp /definition/ms_node/syslog create component-ref component=rd_rsyslog_client
litp /definition/ms_node/logrotate_rules create component-ref component=logrotate_rules
litp /definition/ms_node/logrotate_litp create component-ref component=logrotate_litp
litp /definition/ms_node/sfs create component-ref component=nasinfo
litp /definition/ms_node/hypericagent create component-ref component=hyperica
litp /definition/ms_node/hypericserver create component-ref component=hyperics
litp /definition/ms_node/libvirt create component-ref component=libvirt
litp /definition/ms_node/nfssystem create component-ref component=nfssystem

# NFS Node
litp /definition/nfs_node create solution-def description="nfsnodev1" name="nfsnodev1" solution_type="BASIC" version="1.1.1"
litp /definition/nfs_node/nfssystem create component-ref component=nfssystem
litp /definition/nfs_node/firewallsmain create component-ref component=firewallsmain
litp /definition/nfs_node/os create component-ref component=os/osnfs
litp /definition/nfs_node/repository create component-ref component=repository

#litp /definition/ammeon_gen_app_solution create solution-def description="bvps_solution" name="bvps" solution_type="BASIC" version="1.1.1"
#litp /definition/ammeon_gen_app_solution/ammeon_gen_app_software create component-ref component="ammeon_gen_app_software"

#
# Assign CMW installer role to the cluster
#
litp /definition/deployment1/cluster1/cmw_installer create component-ref component=cmw_installer
#
#
#
litp /definition/deployment1/cluster1/sc1/control_1 create solution-ref solution-name=primary_node
#litp /definition/deployment1/cluster1/sc1/ammeon_gen_app_solution create solution-ref solution-name=ammeon_gen_app_solution
litp /definition/deployment1/cluster1/sc2/control_2 create solution-ref solution-name=litp_sc_node
#litp /definition/deployment1/cluster1/sc2/ammeon_gen_app_solution create solution-ref solution-name=ammeon_gen_app_solution
litp /definition/deployment1/cluster1/pl3/payload_3 create solution-ref solution-name=litp_pl_node
#litp /definition/deployment1/cluster1/pl3/ammeon_gen_app_solution create solution-ref solution-name=ammeon_gen_app_solution
litp /definition/deployment1/cluster1/pl4/payload_4 create solution-ref solution-name=litp_pl_node
#litp /definition/deployment1/cluster1/pl4/ammeon_gen_app_solution create solution-ref solution-name=ammeon_gen_app_solution
litp /definition/deployment1/cluster1/nfs1/nfs_node create solution-ref solution-name=nfs_node
litp /definition/deployment1/ms1/ms_node create solution-ref solution-name=ms_node

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
