#!/bin/bash

#
# This sample script contains the commands used for a LITP installation creating
# the definition part for the following configuration:
#
# Type: Single-Blade
#
# Config:       MS (Managing Server)
#                       2 SC Nodes (Service Control Nodes)
#                       2 PL Nodes (Pay Load Nodes)
#                       1 NFS Node (SFS/NFS network filesystems)
#
# Hardware:     One physical server (Blade or Rackmount) and managed nodes are
#                       installed as VMs in MS1.
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
litp /definition/deployment1/cluster1 create cluster-def

# Create CMW Cluster Config
litp /definition/cmw_cluster_config create cmw-cluster-config-def
litp /definition/deployment1/cluster1/cmw_cluster_config create component-ref component=cmw_cluster_config
litp /definition/cmw_cluster_config/etf_generator/ create cmw-etf-generator-def
litp /definition/cmw_cluster_config/campaign_generator/ create cmw-campaign-generator-def

#litp /definition/deployment1/cluster1 create cmw-cluster-def
litp /definition/deployment1/cluster1/sc1 create node-def nodetype="control" primarynode=true
litp /definition/deployment1/cluster1/sc2 create node-def nodetype="control"

# VCS Cluster Config
litp /definition/vcsr create vcs-component-def
litp /definition/vcs_config create vcs-cluster-config-def
litp /definition/deployment1/cluster1/vcs_config create component-ref component=vcs_config
litp /definition/deployment1/cluster1/sc1/vcsr create component-ref component=vcsr
litp /definition/deployment1/cluster1/sc2/vcsr create component-ref component=vcsr

# MS1 shouldn't be part of the cluster as it's the server managing the cluster
# This is a workaround for the known bug LITP-xxxx
litp /definition/deployment1/ms1 create node-def nodetype="management"

################################################################################
# Define jee instance for the TOR UI services - all in one jboss cluster
################################################################################
litp /definition/jee_torUI create component-def name=jee_torUI version=1.0.0
litp /definition/jee_torUI/rpm create package-def name="eap-litp-rpm-1.0.12" ensure="installed" repository="Ammeon_Custom"
litp /definition/jee_torUI/instance create jee-container-def name=jboss_torUI instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-ericsson-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/home/jboss/{rdni}/jboss_data' home-dir='/home/jboss/{rdni}' process-user=litp_jboss  process-group=litp_jboss management-listener={ip.address} public-listener={ip.address} public-port-base=8080 management-user=root management-password=shroot command-line-options="-Djgroups.uuid_cache.max_age=5000" messaging-group-address='231.8.10.8' default-multicast='231.8.10.8' messaging-group-port='12100' jgroups-mping-mcast-addr='230.0.10.147' jgroups-mping-mcast-port='45100' jgroups-udp-mcast-addr='230.0.10.147' jgroups-udp-mcast-port='45103'
litp /definition/jee_torUI/instance/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=true
litp /definition/jee_torUI/instance/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=300
litp /definition/jee_torUI/instance/ip create ip-address-def pool=network net_name=mgmt
litp /definition/jee_torUI/instance/modcluster_multicast create jee-property-def property='-Djboss.modcluster.multicast.address' value=224.0.1.105

#STORY-5009
litp /definition/jee_torUI/instance/jee_unsecure create jee-property-def property='-Djboss.bind.address.unsecure' value=127.0.0.1

################################################################################
# Define jee instance for the Open AM service - second jboss cluster
################################################################################
# We need to change multicast address and ports to separate this jboss cluster
# from the other
litp /definition/jee_torSSO create component-def name=jee_torSSO version=1.0.0
litp /definition/jee_torSSO/rpm create package-def name="eap-litp-rpm-1.0.12" ensure="installed" repository="Ammeon_Custom"
litp /definition/jee_torSSO/instance create jee-container-def name=jboss_torSSO instance-name={rdni} version=1.0.0 install-source=/opt/ericsson/nms/jboss/jboss-eap-ericsson-6.0.tgz log-dir='/var/log/jboss/{rdni}' data-dir='/home/jboss/{rdni}/jboss_data' home-dir='/home/jboss/{rdni}' process-user=litp_jboss  process-group=litp_jboss management-listener={ip.address} public-listener={ip.address} public-port-base=8080 management-user=root management-password=shroot command-line-options="-Djgroups.uuid_cache.max_age=5000 --server-config=standalone-sso.xml" messaging-group-address='231.8.11.8' default-multicast='231.8.11.8' messaging-group-port='12100' jgroups-mping-mcast-addr='230.0.11.147' jgroups-mping-mcast-port='45100' jgroups-udp-mcast-addr='230.0.11.147' jgroups-udp-mcast-port='45103'
litp /definition/jee_torSSO/instance/preferIPv4Stack create jee-property-def property='-Djava.net.preferIPv4Stack' value=true
litp /definition/jee_torSSO/instance/gcInterval create jee-property-def property='-Dsun.rmi.dgc.server.gcInterval' value=300
litp /definition/jee_torSSO/instance/ip create ip-address-def pool=network net_name=mgmt

#STORY-5009
litp /definition/jee_torSSO/instance/jee_unsecure create jee-property-def property='-Djboss.bind.address.unsecure' value=127.0.0.1
#additional firewall rules to enable multicast traffic on the defined ports
litp /definition/jee_torSSO/instance/fw_jee_torSSO create firewalls-def name="006 jee torSSO" dport="12100,45100,45103"

# Security Service
litp /definition/security_service create component-def name=security_service version=1.0.18
litp /definition/security_service/pkg create package-def name="ERICsecuritysvc" ensure="installed"
litp /definition/security_service/de create deployable-entity-def name=security_service version=1.0.18 install-source=/opt/ericsson/com.ericsson.nms.services/SecurityService-ear-1.0.18.ear app-type=ear service=jboss_torUI

# Single Sign On
litp /definition/sso create component-def name=sso version=1.7.38
litp /definition/sso/pkg create package-def name="ERICsinglesignon" ensure="installed" repository="Ammeon_Custom"
litp /definition/sso/de create deployable-entity-def name=heimdallr.war version=1.7.38 install-source=/opt/ericsson/sso/resources/heimdallr.war app-type=war service=jboss_torSSO post-start=/opt/ericsson/sso/resources/jboss/jboss_app/post_start.d

#################################################################################
# Service Group 3 - UI Service Group                                                  x
#################################################################################
litp /definition/deployment1/cluster1/UIServ create service-group-def node_list="sc1,sc2" availability_model="nway" version="1.0.0"
litp /definition/deployment1/cluster1/UIServ/si create service-instance-def active-count=2 version="1.0.0"
litp /definition/deployment1/cluster1/UIServ/si/jee create component-ref component="jee_torUI"
litp /definition/deployment1/cluster1/UIServ/si/security_service create component-ref component="security_service"

#################################################################################
# Service Group 1 - SingleSignOn
#################################################################################
litp /definition/deployment1/cluster1/OpAm create service-group-def node_list="sc1,sc2" availability_model="nway" version="1.0.0"
litp /definition/deployment1/cluster1/OpAm/si create service-instance-def active-count=2 version="1.0.0"
litp /definition/deployment1/cluster1/OpAm/si/jee create component-ref component="jee_torSSO"
litp /definition/deployment1/cluster1/OpAm/si/sso create component-ref component="sso"
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

#SC-1 specific
litp /definition/os/ossc1 create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/ossc1/ntp1 create ntp-client-def service=ntp_1
litp /definition/os/ossc1/ntp_l2 create ntp-service-def name=ntp_l2

#SC-2 specific
litp /definition/os/ossc2 create rhel-component-def profile='node-iso-x86_64' topo_framework='off'
litp /definition/os/ossc2/ntp1 create ntp-client-def service=ntp_1
litp /definition/os/ossc2/ntp_l2 create ntp-service-def name=ntp_l2

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
# Create NFS export for Core Middleware.
#
litp /definition/nfsshares create component-def
litp /definition/nfsshares/share1 create nfs-export-def share="/exports/cluster" options="rw,sync,no_root_squash" guest="*"

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
#TOR-UI : Deployment
litp /definition/cmw_installer/camp7 create cmw-campaign-def bundle_name="ERIC-httpd-CXP9030291-1.0.1" install_name="ERIC-httpd-UI-Camp"
#litp /definition/cmw_installer/camp8 create cmw-campaign-def bundle_name="cmip_CXP123456-R1A01-1.x86_64" install_name="ERIC-cmip-UI-Camp"  bundle_type="rpm"

#litp /definition/cmw_installer/camp6 create cmw-campaign-def bundle_name="ERIC-JAVAOAM-CXP9019839_1-R2B09" install_name="ERIC-JAVAOAM-I-2SCxNPL"   # JAVA OAM

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

# Define standard logrotate rules (rsyslog client) server
litp /definition/logrotate_rules create component-def
litp /definition/logrotate_rules/syslog create logrotate-def name=syslog path='/var/log/messages /var/log/secure /var/log/maillog /var/log/iptables.log /var/log/spooler /var/log/boot.log /var/log/cron' size=100M dateext=true dateformat='-%Y%m%d-%s' rotate=6 compress=true delaycompress=true create=false sharedscripts=true postrotate='service rsyslog restart || true'

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

litp /definition/os/osms/fw_ms1simulator create firewalls-def name="026 ms1simulator" dport="45678,45679"

#
# Create firewall rules and a reference to the OS role for SCs
#

#SC-1
litp /definition/os/ossc1/fw_basetcp create firewalls-def name="001 basetcp" dport="22,25,80,111,161,162,443,1389,3000,25151,7788,9999"
litp /definition/os/ossc1/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/ossc1/fw_hyperic create firewalls-def name="003 hyperic" dport="2144,7080,7443"
litp /definition/os/ossc1/fw_syslog create firewalls-def name="004 syslog" dport="514"
litp /definition/os/ossc1/fw_jboss create firewalls-def name="005 jboss" dport="8080,9990,9876,54321"
litp /definition/os/ossc1/fw_baseudp create firewalls-def name="010 baseudp" dport="111,123,623,1129,9876,45712,45713,45782,45783,25151" proto="udp"
litp /definition/os/ossc1/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/ossc1/fw_icmp create firewalls-def name="100 icmp" proto="icmp"

litp /definition/os/ossc1/fw_sc1_groupPort create firewalls-def name="31 groupPort" dport="9892" proto=udp
litp /definition/os/ossc1/fw_sc1_hazelcastudp create firewalls-def name="32 hazelcastudp" dport="57429" proto=udp
litp /definition/os/ossc1/fw_sc1_hazelcastudprange1 create firewalls-def name="33 hazelcastudprange1" dport="15901,15902,15903,15904,15905,15906,15907,15908,15909,15910" proto=udp
litp /definition/os/ossc1/fw_sc1_hazelcastudprange2 create firewalls-def name="34 hazelcastudprange2" dport="15911,15912,15913,15914,15915,15916,15917,15918,15919,15920,15921" proto=udp
litp /definition/os/ossc1/fw_remoting create firewalls-def name="35 remoting" dport="4463,4563,4663,4763"

litp /definition/os/ossc1/fw_CMWjboss1 create firewalls-def name="36 CMWjboss1" dport="8009,8080,8443,3528,3529,7500,45700,7600,57600,55200,54200,45688"
litp /definition/os/ossc1/fw_CMWjboss2 create firewalls-def name="37 CMWjboss2" dport="5445,5455,23364,8090,4447,4712,4713"

#SC-2
litp /definition/os/ossc2/fw_basetcp create firewalls-def name="001 basetcp" dport="22,25,80,111,161,162,443,1389,3000,25151,7788,9999"
litp /definition/os/ossc2/fw_nfstcp create firewalls-def name="002 nfstcp" dport="662,875,2020,2049,4001,4045"
litp /definition/os/ossc2/fw_hyperic create firewalls-def name="003 hyperic" dport="2144,7080,7443"
litp /definition/os/ossc2/fw_syslog create firewalls-def name="004 syslog" dport="514"
litp /definition/os/ossc2/fw_jboss create firewalls-def name="005 jboss" dport="8080,9990,9876,54321"
litp /definition/os/ossc2/fw_baseudp create firewalls-def name="010 baseudp" dport="111,123,623,1129,9876,45712,45713,45782,45783,25151" proto="udp"
litp /definition/os/ossc2/fw_nfsudp create firewalls-def name="011 nfsudp" dport="662,875,2020,2049,4001,4045" proto="udp"
litp /definition/os/ossc2/fw_icmp create firewalls-def name="100 icmp" proto="icmp"

litp /definition/os/ossc2/fw_CMWjboss1 create firewalls-def name="36 CMWjboss1" dport="8009,8080,8443,3528,3529,7500,45700,7600,57600,55200,54200,45688"
litp /definition/os/ossc2/fw_CMWjboss2 create firewalls-def name="37 CMWjboss2" dport="5445,5455,23364,8090,4447,4712,4713"

# -----------------------------------------------------------
# DEFINE SOLUTION AND ASSIGN ROLES
# -----------------------------------------------------------

# Primary Node
litp /definition/primary_node create solution-def description="primarynodev1" name="primarynodev1" solution_type="BASIC" version="1.0.0"
litp /definition/primary_node/firewallsmain create component-ref component=firewallsmain
litp /definition/primary_node/os create component-ref component=os/ossc1
litp /definition/primary_node/troubleshooting create component-ref component=troubleshooting
litp /definition/primary_node/repository create component-ref component=repository
litp /definition/primary_node/lde create component-ref component=lde
litp /definition/primary_node/users create component-ref component=rd_users
litp /definition/primary_node/rd_sudoers create component-ref component=rd_sudoers
litp /definition/primary_node/syslog_central create component-ref component=rd_rsyslog_server
litp /definition/primary_node/logrotate_server_rules create component-ref component=logrotate_server_rules
litp /definition/primary_node/hypericagent create component-ref component=hyperica

# Litp SC Node
litp /definition/litp_sc_node create solution-def description="litp_sc_nodev1" name="litpscnodev1" solution_type="BASIC" version="1.0.0"
litp /definition/litp_sc_node/firewallsmain create component-ref component=firewallsmain
litp /definition/litp_sc_node/os create component-ref component=os/ossc2
litp /definition/litp_sc_node/troubleshooting create component-ref component=troubleshooting
litp /definition/litp_sc_node/repository create component-ref component=repository
litp /definition/litp_sc_node/lde create component-ref component=lde
litp /definition/litp_sc_node/users create component-ref component=rd_users
litp /definition/litp_sc_node/rd_sudoers create component-ref component=rd_sudoers
litp /definition/litp_sc_node/syslog create component-ref component=rd_rsyslog_client
litp /definition/litp_sc_node/logrotate_rules create component-ref component=logrotate_rules
litp /definition/litp_sc_node/hypericagent create component-ref component=hyperica

# MS Node
litp /definition/ms_node create solution-def description="msnodev1" name="msnodev1" solution_type="BASIC" version="1.0.0"
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
litp /definition/ms_node/hypericagent create component-ref component=hyperica
litp /definition/ms_node/hypericserver create component-ref component=hyperics
litp /definition/ms_node/libvirt create component-ref component=libvirt
litp /definition/ms_node/nfsshares create component-ref component=nfsshares

#
# Assign CMW installer role to the cluster
#
litp /definition/deployment1/cluster1/cmw_installer create component-ref component=cmw_installer
#
#
#
litp /definition/deployment1/cluster1/sc1/control_1 create solution-ref solution-name=primary_node
litp /definition/deployment1/cluster1/sc2/control_2 create solution-ref solution-name=litp_sc_node
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