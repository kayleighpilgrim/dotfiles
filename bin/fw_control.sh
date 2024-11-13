#!/bin/bash


##########################################################################################
# VARIABLES                                                                              #
##########################################################################################
Color_Off='\e[0m';Black='\e[0;30m';Red='\e[0;31m';Green='\e[0;32m';Yellow='\e[0;33m';Blue='\e[0;34m';Purple='\e[0;35m';Cyan='\e[0;36m';White='\e[0;37m'
FILE="/etc/puppet/environments/production/modules/abs_firewall/templates/ips_to_block.erb"
HELP_MSG="\n${Yellow}Examples:\n${White}Sort banned IPs to erb : ${Cyan}/bin/bash /home/fw_control.sh sorterb\n${White}Unban IP on all hosts: ${Cyan}/bin/bash /home/fw_control.sh unbanip IP.IP.IP.IP\n${White}Ban IP on all hosts  : ${Cyan}/bin/bash /home/fw_control.sh banip IP.IP.IP.IP\n\n"


##########################################################################################
# Do stuff depending on first parameter                                                  #
##########################################################################################

#################
# No parameters #
#################
if [ -z ${1} ]; then
    printf "${HELP_MSG}${Color_Off}"
    #return 1

###########
# Sorterb #
###########
elif [ ${1} = "sorterb" ]; then
    cat ${FILE} >> /root/ip_blocklist
    cat /root/ip_blocklist | sort | uniq > ${FILE}
    echo "" > /root/ip_blocklist
    #return 0

#########
# Unban #
#########
elif [ ${1} = "unbanip" ]; then
    if [ -z ${2} ]; then return 1; fi
    cat ${FILE} | grep -v "${2}" > temp && mv -f temp ${FILE}
    while read HOST; do
        ssh -n -q -o StrictHostKeyChecking=no root@${HOST} -C "ipset del block ${2} ; ipset del blockall ${2} ; for JAIL in \`iptables -nL | grep 'Chain f2b' | awk -F'Chain f2b-' '{print \$2}' | awk -F' ' '{print \$1}'\`; do fail2ban-client set \${JAIL} unbanip ${2}; done" > /dev/null 2> /dev/null
    done < /root/sshkey_hosts
    #return 0

#######
# Ban #
#######
elif [ ${1} = "banip" ]; then
    if [ -z ${2} ]; then return 1; fi
    if ! grep -Fxq "${2}" ${FILE}; then echo "${2}" >> ${FILE}; fi
    while read HOST; do
        ssh -n -q -o StrictHostKeyChecking=no root@${HOST} -C "ipset add block ${2} ; ipset add blockall ${2}" > /dev/null 2> /dev/null
    done < /root/sshkey_hosts
    #return 0

###############################
# Didn't understand parameter #
###############################
else
    printf "${HELP_MSG}${Color_Off}"
    #return 1
fi
