#!/bin/bash

#
# This sample script contains the commands used for a LITP installation creating
# the definition part for the following configuration:
#
# Type: Single-Blade
# Config:       MS (Management Server)
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
LOGFILE="${LOGDIR}/landscape_inventory.log"
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

# --------------------------------------------
# INVENTORY STARTS HERE
# --------------------------------------------

# ---------------------------------------------
# UPDATE NFS Mounts
# ---------------------------------------------
litp /inventory/deployment1/cluster1/sc1/control_1/os/mount1 create nfs-mount mountpoint="/cluster" server="MS1" share="/exports/cluster"
litp /inventory/deployment1/cluster1/sc2/control_2/os/mount1 create nfs-mount mountpoint="/cluster" server="MS1" share="/exports/cluster"


# ---------------------------------------------
# CREATE AN IP ADDRESS POOL
# ---------------------------------------------

litp /inventory/deployment1/network create ip-address-pool

# Add available addresses to the network by creating a pool
litp /inventory/deployment1/network/range1 create ip-address-pool subnet=10.45.237.0/22 start=10.45.237.104 end=10.45.237.105 gateway=10.45.236.1

#ms1 node ip
litp /inventory/deployment1/network/ip_10_45_237_103 create ip-address subnet=10.45.237.0/22 address=10.45.237.103 gateway=10.45.236.1
litp /inventory/deployment1/network/ip_10_45_237_103 enable
litp /inventory/deployment1/ms1/ms_node/os/ip allocate

# we use {ip.address} macro to bind public-listner and management-listener to th vip
# jgroups-bind-addr does not accept the {ip.address} macro, we need to update it to proper address manually (per si)
# Allocate an IP address to Service Group 3 Service instance 0
litp /inventory/deployment1/network/ip_UIServ_si_0 create ip-address subnet=10.45.237.0/22 address=10.45.237.106 gateway=10.45.236.1
litp /inventory/deployment1/network/ip_UIServ_si_0 enable
litp /inventory/deployment1/cluster1/UIServ/si_0/jee/instance/ip allocate
litp /inventory/deployment1/cluster1/UIServ/si_0/jee/instance/ update jgroups-bind-addr=10.45.237.106
litp /inventory/deployment1/cluster1/UIServ/si_0/jee/instance/jee_unsecure/ update value=10.45.237.106

# Allocate an IP address to Service Group 3 Service instance 1
litp /inventory/deployment1/network/ip_UIServ_si_1 create ip-address subnet=10.45.237.0/22 address=10.45.237.107 gateway=10.45.236.1
litp /inventory/deployment1/network/ip_UIServ_si_1 enable
litp /inventory/deployment1/cluster1/UIServ/si_1/jee/instance/ip allocate
litp /inventory/deployment1/cluster1/UIServ/si_1/jee/instance/ update jgroups-bind-addr=10.45.237.107
litp /inventory/deployment1/cluster1/UIServ/si_1/jee/instance/jee_unsecure/ update value=10.45.237.107

# we use {ip.address} macro to bind public-listner and management-listener to th vip
# jgroups-bind-addr does not accept the {ip.address} macro, we need to update it to proper address manually (per si)
# Allocate an IP address to Service Group 1 Service instance 0
litp /inventory/deployment1/network/ip_OpAm_si_0 create ip-address subnet=10.45.237.0/22 address=10.45.237.108 gateway=10.45.236.1
litp /inventory/deployment1/network/ip_OpAm_si_0 enable
litp /inventory/deployment1/cluster1/OpAm/si_0/jee/instance/ip allocate
litp /inventory/deployment1/cluster1/OpAm/si_0/jee/instance/ update jgroups-bind-addr=10.45.237.108
litp /inventory/deployment1/cluster1/OpAm/si_0/jee/instance/jee_unsecure/ update value=10.45.237.108

# Allocate an IP address to Service Group 1 Service instance 1
litp /inventory/deployment1/network/ip_OpAm_si_1 create ip-address subnet=10.45.237.0/22 address=10.45.237.109 gateway=10.45.236.1
litp /inventory/deployment1/network/ip_OpAm_si_1 enable
litp /inventory/deployment1/cluster1/OpAm/si_1/jee/instance/ip allocate
litp /inventory/deployment1/cluster1/OpAm/si_1/jee/instance/ update jgroups-bind-addr=10.45.237.109
litp /inventory/deployment1/cluster1/OpAm/si_1/jee/instance/jee_unsecure/ update value=10.45.237.109

# --------------------
# STORY-2094
# --------------------

litp /inventory/deployment1/cluster1/vcs_config update vcs_csgvip=10.45.237.112 vcs_csgnic="eth0" vcs_lltlinklowpri1="eth0" vcs_lltlink2="eth2" vcs_lltlink1="eth1" vcs_csgnetmask="255.255.252.0" vcs_clusterid="10103" vcs_gconetmask="255.255.252.0" vcs_gconic="eth0" vcs_gcovip="10.45.237.113" gco="1"


# This allocate call creates the neccessary VCS groups and resources
# cmw_cluster_config searches through the service groups for resources that cannot be controlled/monitored by CMW
litp /inventory/deployment1/cluster1/cmw_cluster_config allocate

# ---------------------------------------------
# CREATE A TIPC ADDRESS POOL
# ---------------------------------------------

#
# First two addresses are reserved for sc-1 and sc-2 nodes, so we start
# assigning addresses to other nodes from 1.1.3 and after
#
litp /inventory/deployment1/tipc create tipc-address-pool netid="1103"

# ---------------------------------------------
# ADD THE PHYSICAL SERVERS
# ---------------------------------------------

litp /inventory/deployment1/systems create generic-system-pool
litp /inventory/deployment1/systems/blade create generic-system macaddress="80:C1:6E:7A:89:18" hostname="ms1"
litp /inventory/deployment1/systems/blade enable
litp /inventory/deployment1/systems/blade update bridge_enabled=True


# ---------------------------------------------
# ADD THE VIRTUAL NODES
# ---------------------------------------------

litp /inventory/deployment1/systems/vm_pool create vm-pool mac_start='FA:DE:2B:ED:B1:17' mac_end='FA:DE:2B:ED:B1:21'
litp /inventory/deployment1/systems/vm_pool update path='/var/lib/libvirt/images'
litp /inventory/deployment1/systems/vm_pool/hyper_visor create vm-host-assignment host='/inventory/deployment1/ms1/ms_node/libvirt/vmservice'

# ---------------------------------------------
# ADD AN NTP SERVER
# ---------------------------------------------
litp /inventory/deployment1/ntp_1 update ipaddress="159.107.173.12"

# Update the user's passwords
# The user's passwords must be encrypted, the encryption method is Python's 2.6.6
# crypt function. The following is an example for encrypting the phrase 'passw0rd'
#
# [cmd_prompt]$ python
# Python 2.6.6 (r266:84292, May 20 2011, 16:42:11)
# [GCC 4.4.5 20110214 (Red Hat 4.4.5-6)] on linux2
# Type "help", "copyright", "credits" or "license" for more information.
# >>> import crypt
# >>> crypt.crypt("passw0rd")
# '$6$VbIEnv1XppQpNHel$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.'
#
# Symbol '$' is a shell metacharacter and needs to be "escaped" with '\\\'
#
litp /inventory/deployment1/ms1/ms_node/users/litp_admin update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/ms1/ms_node/users/litp_user update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/ms1/ms_node/users/litp_jboss update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/cluster1/sc1/control_1/users/litp_admin update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/cluster1/sc1/control_1/users/litp_user update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/cluster1/sc1/control_1/users/litp_jboss update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/cluster1/sc2/control_2/users/litp_admin update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/cluster1/sc2/control_2/users/litp_user update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.
litp /inventory/deployment1/cluster1/sc2/control_2/users/litp_jboss update password=\\\$6\\\$VbIEnv1XppQpNHel\\\$/ikRQIa5i/cNJR2BYucNkTjHmO/HBzHdvDbsXa7fprXILrGYa.xMOPI9b.y5HrfqWHfVyfXK7AffI9DrkUBWJ.

# ---------------------------------------------
# CONFIGURE & ALLOCATE THE RESOURCES
# ---------------------------------------------

#
# Set MySQL Password
#
litp /inventory/deployment1/ms1/ms_node/mysqlserver/config update password="ammeon101"

# MS to allocate first and "secure" the blade hw for this node.
litp /inventory/deployment1/ms1 allocate
litp /inventory/deployment1 allocate

# ------------------------------------------------------------
# SET THIS PROPERTY FOR ALL SYSTEMS NOT TO BE ADDED TO COBBLER
# ------------------------------------------------------------
litp /inventory/deployment1/ms1 update add_to_cobbler="False"

# Updating hostnames of the systems.
litp /inventory/deployment1/cluster1/sc1/control_1/os/system update hostname="SC-1" systemname="vm_deployment1_cluster1_sc1_control_1"
litp /inventory/deployment1/cluster1/sc2/control_2/os/system update hostname="SC-2" systemname="vm_deployment1_cluster1_sc2_control_2"

# Allocate some more h/w resources for VMs, by modifying default values.
# RAM size in Megabytes, disk size in Gigabytes
litp /inventory/deployment1/systems/vm_pool/vm_deployment1_cluster1_sc1_control_1 update ram='20240M' disk='60G' cpus="5" hostname="SC-1" systemname="vm_deployment1_cluster1_sc1_control_1"
litp /inventory/deployment1/systems/vm_pool/vm_deployment1_cluster1_sc2_control_2 update ram='20240M' disk='60G' cpus="5" hostname="SC-2" systemname="vm_deployment1_cluster1_sc2_control_2"

# Update kiskstart information. Convention for kickstart filenames is node's
# hostname with a "ks" extension
litp /inventory/deployment1/cluster1/sc1/control_1/os/ks update ksname="SC-1.ks" path=/var/lib/cobbler/kickstarts
litp /inventory/deployment1/cluster1/sc2/control_2/os/ks update ksname="SC-2.ks" path=/var/lib/cobbler/kickstarts

# Update the verify user to root. Workaround, user litp_verify doesn't exist yet
# Issue LITP-XXX (or User Story?)
litp /inventory/deployment1/ms1 update verify_user="root"
litp /inventory/deployment1/cluster1/sc1 update verify_user="root"
litp /inventory/deployment1/cluster1/sc2 update verify_user="root"

# Allocate the complete site
litp /inventory/deployment1 allocate

# --------------------------------------
# APPLY CONFIGURATION TO PUPPET
# --------------------------------------

# This is an intermediate step before applying the configuration to puppet
litp /inventory/deployment1 configure
litp /inventory/deployment1/cluster1/cmw_cluster_config configure


# --------------------------------------
# VALIDATE INVENTORY CONFIGURATION
# --------------------------------------

litp /inventory validate

# --------------------------------------
# APPLY CONFIGURATION TO PUPPET
# --------------------------------------

# Configuration's Manager (Puppet) manifests for the inventory will be created
# after this
litp /cfgmgr apply scope=/inventory

# (check for puppet errors -> "grep puppet /var/log/messages")
# (use "service puppet restart" to force configuration now)

# --------------------------------------------
# INVENTORY ENDS HERE
# --------------------------------------------

echo "Inventory addition has completed"
echo "Please wait for puppet to configure cobbler. This should take about 3 minutes"

exit 0