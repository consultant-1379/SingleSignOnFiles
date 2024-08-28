#!/bin/bash

echo "Usage : `basename $0 ` : no arguments to configure MS, 1 argument to configure Nodes"

ECHO=/bin/echo
SSH=/usr/bin/ssh
CP=/bin/cp
CAT=/bin/cat
PEER_NODES="SC-1 SC-2"

FILE=.bashrc

COLOUR_SCHEME=desert
VIM_FILE=.vimrc


if [ $# -eq 0 ]; then

#MS
${ECHO} "alias lr='ls -ltr --color=auto'" >> ~/${FILE}
${ECHO} "alias deploydir='cd /opt/ericsson/nms/litp/bin/deployment/bin'" >> ~/${FILE}
${ECHO} "alias tail_messages='tail -f /var/log/messages'" >> ~/${FILE}
${ECHO} "alias ssopkgs='find / -name \"ERICs*\" | grep -v litp | grep -v toriso'" >> ~/${FILE}
${CAT} ~/${FILE} | grep alias

${ECHO} "colorscheme ${COLOUR_SCHEME}" > ${HOME}/${VIM_FILE}
${CAT} ${HOME}/${VIM_FILE}
fi

#SC-1 SC-2

if [ $# -eq 1 ]; then
for NODE in ${PEER_NODES};
do
  ${SSH} ${NODE} ${CP} ~/${FILE} ~/${FILE}.orig
  ${SSH} ${NODE} "${ECHO} \"alias lr='ls -ltr --color=auto'\" >> ~/${FILE}"
  ${SSH} ${NODE} "${ECHO} \"alias checkcampaigns='cmw-repository-list --campaign | xargs cmw-campaign-status'\" >> ~/${FILE}"
  ${SSH} ${NODE} "${ECHO} \"alias sso_rpms='rpm -qa | grep -i ERICs'\" >> ~/${FILE}"
  ${SSH} ${NODE} "${ECHO} \"alias sso_status='/opt/ericsson/sso/bin/sso.sh status'\" >> ~/${FILE}"
  ${SSH} ${NODE} "${ECHO} \"alias tail_messages='tail -f /var/log/messages'\" >> ~/${FILE}"                        
  ${SSH} ${NODE} "${CAT} ~/${FILE} | grep alias"

   SSH_ECHO_CMD="${SSH} ${NODE} '${ECHO} -e \"colorscheme ${COLOUR_SCHEME}\" > ${HOME}/${VIM_FILE}'"
   eval ${SSH_ECHO_CMD}
   ${ECHO} ${NODE}
   ${SSH} ${NODE} ${CAT} ${HOME}/${VIM_FILE}
done

fi


