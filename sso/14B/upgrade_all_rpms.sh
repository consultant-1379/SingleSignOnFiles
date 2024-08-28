#!/bin/bash
ECHO="echo -e"
UPGRADE_PLAN_NAME=upgrade_rpms

UPGRADE_SOURCE=/var/tmp/oasis/new_upgrade_pkgs
LITP_TOR_DIR=/var/www/html/products/TOR
UPGRADE_TARGET_DIR=$1
SKIP_SNAPSHOTS=$2


####
### FUNCTIONS
####

getCXPNumber() {
	_cxp_num_=`echo $1 | awk -F_ '{ print $4 }' | awk -F- '{ print $1 }'`
	echo $_cxp_num_
}


getVersionNumber() {
	_version_num_=`echo $1 | cut -d- -f2 | sed s/.rpm//g`
	echo $_version_num_
}

getEarInstallSource() {
	_install_source_=`rpm -qlip $1 | grep  "\.ear" | grep -v xml`
	echo $_install_source_
}

getEarName() {
	_ear_name_=`echo $1 | cut -d/ -f5`
	echo $_ear_name_
}

getCurrentEarName() {
	_ear_name_=`echo $1 | sed 's/\-[0-9]\+\.[0-9]\+\.[0-9]\+.ear//g'`
	echo $_ear_name_
}

####
### START OF PROGRAM
####

if [ $# -ne 2 ]; then
	${ECHO} "Please provide sprint name and whether you want to skip filesystem snapshots"
	${ECHO} "Example usage : `basename $0` 3.0.H yes|no"
	exit 1
fi

if [ ! -d ${UPGRADE_SOURCE} ]; then
        ${ECHO} "ERROR - Put the packages to upgrade to into the ${UPGRADE_SOURCE} directory"
        exit 1
fi

if [ `ls ${UPGRADE_SOURCE} | wc -l` -eq 0 ]; then
        ${ECHO} "ERROR - No packages in ${UPGRADE_SOURCE} directory, exiting, put the packages to upgrade to in ${UPGRADE_SOURCE} directory"
        exit 1
fi

if [ ! -d ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR} ]; then
        ${ECHO} "ERROR - ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR} doesn't exist"
        exit 1
fi

${ECHO} "Copying the following packages to ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR}\n"
LIST_OF_PKGS_TO_UPGRADE=`ls ${UPGRADE_SOURCE}/*`
${ECHO} "${LIST_OF_PKGS_TO_UPGRADE}\n"

cp -f ${UPGRADE_SOURCE}/* ${LITP_TOR_DIR}/${UPGRADE_TARGET_DIR}
if litp /depmgr/${UPGRADE_PLAN_NAME}/ show > /dev/null 2>&1; then
        ${ECHO} "Cleaning up previous ${UPGRADE_PLAN_NAME} plan"
        litp /depmgr/${UPGRADE_PLAN_NAME}/ cleanup -f
fi

date=`/bin/date +%Y%m%d_%H%M%S`
${ECHO} "Taking a copy of the LAST_KNOWN_CONFIG copying file to /var/tmp/LAST_KNOWN_CONFIG_${date}\n"
cp /var/lib/landscape/LAST_KNOWN_CONFIG /var/tmp/LAST_KNOWN_CONFIG_${date} 2>&1 1>/dev/null


for _each_pkg_ in ${LIST_OF_PKGS_TO_UPGRADE}; do

	# Following 3 lines get the new CXC number, new version number and the new EAR install source

	_cxp_number_=`getCXPNumber ${_each_pkg_}`
	_version_number_=`getVersionNumber ${_each_pkg_}`
	_new_ear_install_source_=`getEarInstallSource ${_each_pkg_}`

	# Only need to update EAR info if this RPM has a deployable entity

	if [[ -n ${_new_ear_install_source_} ]]; then
		_new_ear_name_=`getEarName ${_new_ear_install_source_}`
		_current_ear_name_=`getCurrentEarName ${_new_ear_name_}`
	fi

	_litp_pkg_definition_=`litp /definition/tor_sw/ show -rv | grep -B10 ${_cxp_number_} | grep tor_sw`
	[[ -n ${_new_ear_install_source_} ]] && _litp_de_definition_=`litp /definition/tor_sw/ show -rv | grep -B10 ${_current_ear_name_} | grep tor_sw`

	${ECHO} "Existing definition for ${_each_pkg_}"
	litp ${_litp_pkg_definition_} show
	[[ -n ${_new_ear_install_source_} ]] && litp ${_litp_de_definition_} show

	${ECHO} "Updating definition for ${_each_pkg_}\n"
	litp ${_litp_pkg_definition_} update version="${_version_number_}"
	[[ -n ${_new_ear_install_source_} ]] && litp ${_litp_de_definition_} update version="${_version_number_}" install-source="${_new_ear_install_source_}" name="${_new_ear_name_}"

done


${ECHO} "Prepare and plan the Upgrade\n"
litp /depmgr prepare ${UPGRADE_PLAN_NAME} scope=/inventory
litp /depmgr/${UPGRADE_PLAN_NAME}/ plan

${ECHO} "Here is the plan for Upgrade\n"
litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v

if [[ ${SKIP_SNAPSHOTS} == "yes" ]]; then
	${ECHO} "Deleting all Verify, NAS and LVM snapshot and sanity checks tasks from the plan to speed up upgrade\n"

	_inventory_task_=`litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v | grep inventory | grep verify | awk '{ print $1 }'`
	litp /depmgr/${UPGRADE_PLAN_NAME}/upgrade_plan/parent_task/${_inventory_task_} delete

	_sfs_task_=`litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v | grep SFS | grep run_sub | awk '{ print $1 }'`
	litp /depmgr/${UPGRADE_PLAN_NAME}/upgrade_plan/parent_task/${_sfs_task_} delete

	_lvm_tasks_=`litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v | grep LVM | grep run_sub | awk '{ print $1 }'`
	for _each_lvm_task_ in ${_lvm_tasks_}; do
		litp /depmgr/${UPGRADE_PLAN_NAME}/upgrade_plan/parent_task/${_each_lvm_task_} delete
	done

	_parent_sanity_task_=`litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v | grep -B1 sanity_check | head -1 | awk '{ print $1 }'`
	_sanity_tasks_=`litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v | grep sanity_check | awk '{ print $1 }'`
	for _each_sanity_task_ in ${_sanity_tasks_}; do
		litp /depmgr/${UPGRADE_PLAN_NAME}/upgrade_plan/parent_task/${_parent_sanity_task_}${_each_sanity_task_} delete
	done

	${ECHO} "Here is the updated plan for Upgrade\n"
	litp /depmgr/${UPGRADE_PLAN_NAME}/ show plan -v
fi

${ECHO} "Starting the Upgrade...\n"
litp /depmgr/${UPGRADE_PLAN_NAME}/ start
