#!/bin/bash

#
# This sample script contains the commands used for a LITP installation applying
# to the landscape the boot manager part for the following configuration:
#
# Type: Single-Blade
#
# Can be run in two modes, Interactive and Non-interactive
#
# Interactive mode pauses the execution waiting for the user to hit a key to
# continue, in order to allow the user to check the status of the system before
# next step.
#
# Non-interactive is enabled by providing '-i' as an argument to this script.
# In this mode the script doesn't pause, suitable when ran by an application.
#
# For more details, please visit the documentation site here:
# https://team.ammeon.com/confluence/display/LITPExt/Landscape+Installation
#

INTERACTIVE=On
# Parsing arguments to check for non-interactive mode. Ignoring unspecified
# arguments
while getopts :i opt; do
    case $opt in
        i)
            INTERACTIVE=Off
            ;;
    esac
done
 
# Helper function for debugging purpose. 
# ----------------------------------------
# Reduces the clutter on the script's output while saving everything in 
# landscape log file in the user's current directory. Can safely be removed 
# if not needed.

STEP=0
LOGDIR="logs"
if [ ! -d "$LOGDIR" ]; then
    mkdir $LOGDIR
fi
LOGFILE="${LOGDIR}/landscape_bootmgr.log"
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

# Function to show elapsed time in human readable format (minutes:seconds)
function time_elapsed() {
	secs=$1

	mins=$(( $secs / 60 ))
	secs=$(( $secs % 60 ))

	printf "Time elapsed: %02d:%02d\r" $mins $secs
}

# pause function to allow for user confirmation in interactive mode
function pause() {
    case $INTERACTIVE in
        [Yy]es|[Oo]n|[Tt]rue)
            read -s -n 1 -p "Press any key to continue or Ctrl-C to abort."
            echo
            ;;
    esac
}

#
# A function that checks if cobbler is ready with a profile and distro
# before starting to create systems
#
function wait_for_cobbler() {
	c=0 # attempt timer
	TEMPO=1 # interval between checks
	
	echo
	echo "Waiting for cobbler distro/profile to be loaded..."

	time_elapsed $(( $c * $TEMPO ))
	while sleep $TEMPO; do
		let c++
		time_elapsed $(( $c * $TEMPO ))

		output=$(cobbler distro list)
		if [[ -n "$output" ]]; then
			output=$(cobbler profile list)
			if [[ -n "$output" ]]; then
				break
			fi
		fi
	done
	echo
	echo "Cobbler is now ready with a distro & profile."
	pause
}

# A function that checks if dhcp is ready for distro import
# before starting to import distro
#
function wait_for_dhcp() {
	c=0 # attempt timer
	TEMPO=1 # interval between checks
	
	echo
	echo "Waiting for dhcp to be configured..."

	time_elapsed $(( $c * $TEMPO ))
	while sleep $TEMPO; do
		let c++
		time_elapsed $(( $c * $TEMPO ))

                grep -Eq  "puppet-agent.*File.*dhcp.*content.*changed" /var/log/messages*
                if [ $? -eq 0 ]; then
                    break
                fi
	done
	echo
	echo "Cobbler is now ready for distro import."
	pause
}

# --------------------------------------------
# BOOT MANAGER STARTS HERE
# --------------------------------------------

# -------------------------------------------------------------
# APPLY CONFIGURATION TO COBBLER & START (BOOT) NODES
# -------------------------------------------------------------

#
# Cobbler must have been configured before running the following commands
# check /var/log/messages for next puppet iteration, 'cobbler sync' should not
# fail after this
#

# Cobbler's management interface
litp /bootmgr update server_url="http://127.0.0.1/cobbler_api" username="testing" password="testing"

wait_for_dhcp

# Adding a distribution and a profile to cobbler
litp /bootmgr/distro1 create boot-distro arch='x86_64' breed='redhat' path='/profiles/node-iso/' name='node-iso-x86_64'

#
# We must wait a few seconds for profile and distro to be imported to cobbler
#

wait_for_cobbler

# Add profile to landscape
litp /bootmgr/distro1/profile1 create boot-profile name='node-iso-x86_64' distro='node-iso-x86_64' kopts='' kopts_post='console=ttyS0,115200'

#
# Now that Cobbler has imported the distro, we can create systems
#
litp /bootmgr boot scope=/inventory

# --------------------------------------------
# BOOT MANAGER ENDS HERE
# --------------------------------------------

echo "Check 'cobbler list' to see if cluster installation has been kickstarted."

exit 0
