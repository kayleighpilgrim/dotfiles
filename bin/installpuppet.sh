#!/bin/bash

# RUN THIS SCRIPT WITH THE FOLLOWING COMMAND:
#      wget https://scripts.teleweb.network/puppet/installpuppet.sh -qO /tmp/installpuppet.sh &> /dev/null ; /bin/bash /tmp/installpuppet.sh ; rm -f /tmp/installpuppet.sh &> /dev/null

clear


##########################################################################################
# VARIABLES                                                                              #
##########################################################################################
FQDN="foreman.teleweb.network"
IP="185.77.198.78"

# Colors
Color_Off='\e[0m'
Black='\e[0;30m';Red='\e[0;31m';Green='\e[0;32m';Yellow='\e[0;33m';Blue='\e[0;34m';Purple='\e[0;35m';Cyan='\e[0;36m';White='\e[0;37m' 
BBlack='\e[1;30m';BRed='\e[1;31m';BGreen='\e[1;32m';BYellow='\e[1;33m';BBlue='\e[1;34m';BPurple='\e[1;35m';BCyan='\e[1;36m';BWhite='\e[1;37m' 
UBlack='\e[4;30m';URed='\e[4;31m';UGreen='\e[4;32m';UYellow='\e[4;33m';UBlue='\e[4;34m';UPurple='\e[4;35m';UCyan='\e[4;36m';UWhite='\e[4;37m' 
On_Black='\e[40m';On_Red='\e[41m';On_Green='\e[42m';On_Yellow='\e[43m';On_Blue='\e[44m';On_Purple='\e[45m';On_Cyan='\e[46m';On_White='\e[47m' 
IBlack='\e[0;90m';IRed='\e[0;91m';IGreen='\e[0;92m';IYellow='\e[0;93m';IBlue='\e[0;94m';IPurple='\e[0;95m';ICyan='\e[0;96m';IWhite='\e[0;97m' 
BIBlack='\e[1;90m';BIRed='\e[1;91m';BIGreen='\e[1;92m';BIYellow='\e[1;93m';BIBlue='\e[1;94m';BIPurple='\e[1;95m';BICyan='\e[1;96m';BIWhite='\e[1;97m'
On_IBlack='\e[0;100m';On_IRed='\e[0;101m';On_IGreen='\e[0;102m';On_IYellow='\e[0;103m';On_IBlue='\e[0;104m';On_IPurple='\e[0;105m';On_ICyan='\e[0;106m';On_IWhite='\e[0;107m'


##########################################################################################
# ROOTCHECK                                                                              #
##########################################################################################
printf "${Yellow}Checking if we are root.\n${Color_Off}"
if [[ $EUID -ne 0 ]]; then
    printf "${Black}${On_Red}\n\nERROR: This script must be run as root!\n\n${White}${On_Black}" 1>&2
    exit 1
fi


##########################################################################################
# ADD MASTER TO HOSTS FILE                                                               #
##########################################################################################
printf "${Yellow}Adding puppet master to hosts file.\n${Color_Off}"
echo "$IP  $FQDN" >> /etc/hosts &> /dev/null


##########################################################################################
# CHECK DISTRO/RELEASE                                                                   #
##########################################################################################
printf "${Yellow}Checking your distribution and release.\n${Color_Off}"
OS=`uname -s`
REV=`uname -r`
MACH=`uname -m`
if [ "${OS}" = "SunOS" ]; then
    OS=Solaris
    ARCH=`uname -p`
    OSSTR="${OS} ${REV}(${ARCH} `uname -v`)"
elif [ "${OS}" = "AIX" ]; then
    OSSTR="${OS} `oslevel` (`oslevel -r`)"
elif [ "${OS}" = "Linux" ]; then
    KERNEL=`uname -r`
    if [ -f /etc/redhat-release ]; then
        DIST=$(cat /etc/redhat-release | awk '{print $1}')
        if [ "${DIST}" = "CentOS" ]; then
            DIST="CentOS"
        elif [ "${DIST}" = "Mandriva" ]; then
            DIST="Mandriva"
            PSEUDONAME=`cat /etc/mandriva-release | sed s/.*\(// | sed s/\)//`
            REV=`cat /etc/mandriva-release | sed s/.*release\ // | sed s/\ .*//`
        elif [ "${DIST}" = "Fedora" ]; then
            DIST="Fedora"
        else
            DIST="RedHat"
        fi
        PSEUDONAME=`cat /etc/redhat-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ]; then
        DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
        REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    elif [ -f /etc/mandrake-release ]; then
        DIST='Mandrake'
        PSEUDONAME=`cat /etc/mandrake-release | sed s/.*\(// | sed s/\)//`
        REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
    elif [ -f /etc/debian_version ]; then
        if [ -f /etc/mailcleaner/etc/mailcleaner/version.def ]; then
            DIST="MailCleaner"
            REV=`cat /etc/mailcleaner/etc/mailcleaner/version.def`
        else
            DIST="Debian `cat /etc/debian_version`"
            REV=""
        fi
    fi
    if [ -f /etc/UnitedLinux-release ]; then
        DIST="${DIST}[`cat /etc/UnitedLinux-release | tr "\n" ' ' | sed s/VERSION.*//`]"
    fi
    if [ -f /etc/lsb-release ]; then
        LSB_DIST="`cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2`"
        LSB_REV="`cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2`"
        if [ "$LSB_DIST" != "" ]; then
            DIST=$LSB_DIST
            REV=$LSB_REV
        fi
    fi
    OSSTR="${DIST} ${REV}"
elif [ "${OS}" = "Darwin" ]; then
    if [ -f /usr/bin/sw_vers ]; then
        OSSTR=`/usr/bin/sw_vers|grep -v Build|sed 's/^.*:.//'| tr "\n" ' '`
    fi
fi
OS=`echo ${OSSTR} | awk -F'.' '{print $1}'`


##########################################################################################
# ACTUAL SCRIPT, DEPENDANT ON OS                                                         #
##########################################################################################
if [[ "${OS}" == "CentOS 6" ]];then
    printf "${Yellow}Installing Puppetlabs repository.\n${Color_Off}"
    yum localinstall -y http://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm &> /dev/null
	printf "${Yellow}Removing any old puppet configuration.\n${Color_Off}"
	yum remove -y puppet &> /dev/null
    rm -fr /var/lib/puppet &> /dev/null
    rm -fr /etc/puppet &> /dev/null
	printf "${Yellow}Installing puppet and augeas.\n${Color_Off}"
	yum install -y puppet augeas &> /dev/null
	if [ -d /etc/puppet ]; then
        printf "${Yellow}Configuring puppet with augeas.\n${Color_Off}"
        augtool -s set /files/etc/puppet/puppet.conf/agent/server ${FQDN} &> /dev/null
        augtool -s set /files/etc/puppet/puppet.conf/main/pluginsync true &> /dev/null
        augtool -s set /files/etc/puppet/puppet.conf/agent/listen true &> /dev/null
        printf "${Yellow}Configuring puppet auth.conf .\n${Color_Off}"
        if ! grep -q -P '^path \/run' /etc/puppet/auth.conf &> /dev/null; then
            perl -0777 -p -i -e 's/\n\n((#.*\n)*path \/\s*\n)/\n\npath \/run\nauth any\nmethod save\nallow ${MGMT}\n\n\$1/' /etc/puppet/auth.conf &> /dev/null
        fi
    fi
	printf "${Yellow}Are you ready to sign the certificate in Foreman and do the first Puppet run?\n${Color_Off}"
    printf "You can sign the certificate on ${Green}https://foreman.teleweb.network/smart_proxies/1-foreman-teleweb-network#certificates${Color_Off} .\n"
    printf "You have 30 seconds to sign the certificate.\n"
    printf "If you can't do this now you will have to do this manually with the command ${Green}puppet agent -tv --waitforcert=30${Color_Off}.\n"
    select yn in "Do the first run and sign the certificate." "I will do this manually." "I have already done this and have a signed certificate."; do
	    case $yn in
		    "Do the first run and sign the certificate." )
				puppet agent -tv --waitforcert=30
				chkconfig puppet on &> /dev/null
				service puppet restart &> /dev/null
				printf "${Yellow}You can add the classes and parameters to the new host in Foreman now, or you can choose to do this later.${Color_Off}\n"
				printf "Go to ${Green}https://foreman.teleweb.network/hosts${Color_Off} and click on the Edit button next to the new host to do this now.\n"
				select yn in "I have added the classes and parameters to the new host." "I will do this later."; do
					case $yn in
						"I have added the classes and parameters to the new host." )
							puppet agent -tv
							puppet agent -tv
							puppet agent -tv
							break;;
						"I will do this later." )
							break;;
					esac
				done
			    break;;
			"I will do this manually." )
				chkconfig puppet on &> /dev/null
				service puppet restart &> /dev/null
			    break;;
			"I have already done this and have a signed certificate." )
				chkconfig puppet on &> /dev/null
				service puppet restart &> /dev/null
				printf "${Yellow}You can add the classes and parameters to the new host in Foreman now, or you can choose to do this later.${Color_Off}\n"
				printf "Go to ${Green}https://foreman.teleweb.network/hosts${Color_Off} and click on the Edit button next to the new host to do this now.\n"
				select yn in "I have added the classes and parameters to the new host." "I will do this later."; do
					case $yn in
						"I have added the classes and parameters to the new host." )
							puppet agent -tv
							puppet agent -tv
							puppet agent -tv
							break;;
						"I will do this later." )
							break;;
					esac
				done
			    break;;
		esac
	done
elif [[ "${OS}" == "CentOS 7" ]];then
    printf "${Yellow}Installing Puppetlabs repository.\n${Color_Off}"
    yum localinstall -y http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm &> /dev/null
	printf "${Yellow}Removing any old puppet configuration.\n${Color_Off}"
	yum remove -y puppet &> /dev/null
    rm -fr /var/lib/puppet &> /dev/null
    rm -fr /etc/puppet &> /dev/null
	printf "${Yellow}Installing puppet and augeas.\n${Color_Off}"
	yum install -y puppet augeas &> /dev/null
	if [ -d /etc/puppet ]; then
        printf "${Yellow}Configuring puppet with augeas.\n${Color_Off}"
        augtool -s set /files/etc/puppet/puppet.conf/agent/server ${FQDN} &> /dev/null
        augtool -s set /files/etc/puppet/puppet.conf/main/pluginsync true &> /dev/null
        augtool -s set /files/etc/puppet/puppet.conf/agent/listen true &> /dev/null
        printf "${Yellow}Configuring puppet auth.conf .\n${Color_Off}"
        if ! grep -q -P '^path \/run' /etc/puppet/auth.conf &> /dev/null; then
            perl -0777 -p -i -e 's/\n\n((#.*\n)*path \/\s*\n)/\n\npath \/run\nauth any\nmethod save\nallow ${MGMT}\n\n\$1/' /etc/puppet/auth.conf &> /dev/null
        fi
    fi
	printf "${Yellow}Are you ready to sign the certificate in Foreman and do the first Puppet run?\n${Color_Off}"
    printf "You can sign the certificate on ${Green}https://foreman.teleweb.network/smart_proxies/1-foreman-teleweb-network#certificates${Color_Off} .\n"
    printf "You have 30 seconds to sign the certificate.\n"
    printf "If you can't do this now you will have to do this manually with the command ${Green}puppet agent -tv --waitforcert=30${Color_Off}.\n"
    select yn in "Do the first run and sign the certificate." "I will do this manually." "I have already done this and have a signed certificate."; do
	    case $yn in
		    "Do the first run and sign the certificate." )
				puppet agent -tv --waitforcert=30
				systemctl enable puppet &> /dev/null
				service puppet restart &> /dev/null
				printf "${Yellow}You can add the classes and parameters to the new host in Foreman now, or you can choose to do this later.${Color_Off}\n"
				printf "Go to ${Green}https://foreman.teleweb.network/hosts${Color_Off} and click on the Edit button next to the new host to do this now.\n"
				select yn in "I have added the classes and parameters to the new host." "I will do this later."; do
					case $yn in
						"I have added the classes and parameters to the new host." )
							puppet agent -tv
							puppet agent -tv
							puppet agent -tv
							break;;
						"I will do this later." )
							break;;
					esac
				done
			    break;;
			"I will do this manually." )
				systemctl enable puppet &> /dev/null
				service puppet restart &> /dev/null
			    break;;
			"I have already done this and have a signed certificate." )
				systemctl enable puppet &> /dev/null
				service puppet restart &> /dev/null
				printf "${Yellow}You can add the classes and parameters to the new host in Foreman now, or you can choose to do this later.${Color_Off}\n"
				printf "Go to ${Green}https://foreman.teleweb.network/hosts${Color_Off} and click on the Edit button next to the new host to do this now.\n"
				select yn in "I have added the classes and parameters to the new host." "I will do this later."; do
					case $yn in
						"I have added the classes and parameters to the new host." )
							puppet agent -tv
							puppet agent -tv
							puppet agent -tv
							break;;
						"I will do this later." )
							break;;
					esac
				done
			    break;;
		esac
	done
elif [[ "${OS}" == "Debian 9" || "${OS}" == "Debian buster/sid" ]];then
    printf "${Yellow}Installing Puppetlabs repository.\n${Color_Off}"
    wget https://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb -qO /tmp/puppetlabs-release-pc1-jessie.deb &> /dev/null
    dpkg -i /tmp/puppetlabs-release-pc1-jessie.deb &> /dev/null
    rm -f /tmp/puppetlabs-release-pc1-jessie.deb &> /dev/null
	printf "${Yellow}Removing any old puppet configuration.\n${Color_Off}"
	apt-get -y remove puppet &> /dev/null
    rm -fr /var/lib/puppet &> /dev/null
    rm -fr /etc/puppet &> /dev/null
	printf "${Yellow}Installing puppet and augeas.\n${Color_Off}"
	apt-get install -y puppet augeas-lenses augeas-tools &> /dev/null
	if [ -d /etc/puppet ]; then
        printf "${Yellow}Configuring puppet with augeas.\n${Color_Off}"
        augtool -s set /files/etc/puppet/puppet.conf/agent/server ${FQDN} &> /dev/null
        augtool -s set /files/etc/puppet/puppet.conf/main/pluginsync true &> /dev/null
        augtool -s set /files/etc/puppet/puppet.conf/agent/listen true &> /dev/null
        printf "${Yellow}Configuring puppet auth.conf .\n${Color_Off}"
        if ! grep -q -P '^path \/run' /etc/puppet/auth.conf &> /dev/null; then
            perl -0777 -p -i -e 's/\n\n((#.*\n)*path \/\s*\n)/\n\npath \/run\nauth any\nmethod save\nallow ${MGMT}\n\n\$1/' /etc/puppet/auth.conf &> /dev/null
        fi
    fi
	printf "${Yellow}Are you ready to sign the certificate in Foreman and do the first Puppet run?\n${Color_Off}"
    printf "You can sign the certificate on ${Green}https://foreman.teleweb.network/smart_proxies/1-foreman-teleweb-network#certificates${Color_Off} .\n"
    printf "You have 30 seconds to sign the certificate.\n"
    printf "If you can't do this now you will have to do this manually with the command ${Green}puppet agent -tv --waitforcert=30${Color_Off}.\n"
    select yn in "Do the first run and sign the certificate." "I will do this manually." "I have already done this and have a signed certificate."; do
	    case $yn in
		    "Do the first run and sign the certificate." )
				puppet agent --enable &> /dev/null
				puppet agent -tv --waitforcert=30
				systemctl enable puppet &> /dev/null
				service puppet restart &> /dev/null
				printf "${Yellow}You can add the classes and parameters to the new host in Foreman now, or you can choose to do this later.${Color_Off}\n"
				printf "Go to ${Green}https://foreman.teleweb.network/hosts${Color_Off} and click on the Edit button next to the new host to do this now.\n"
				select yn in "I have added the classes and parameters to the new host." "I will do this later."; do
					case $yn in
						"I have added the classes and parameters to the new host." )
							puppet agent -tv
							puppet agent -tv
							puppet agent -tv
							break;;
						"I will do this later." )
							break;;
					esac
				done
			    break;;
			"I will do this manually." )
				puppet agent --enable &> /dev/null
				systemctl enable puppet &> /dev/null
				service puppet restart &> /dev/null
			    break;;
			"I have already done this and have a signed certificate." )
				puppet agent --enable &> /dev/null
				systemctl enable puppet &> /dev/null
				service puppet restart &> /dev/null
				printf "${Yellow}You can add the classes and parameters to the new host in Foreman now, or you can choose to do this later.${Color_Off}\n"
				printf "Go to ${Green}https://foreman.teleweb.network/hosts${Color_Off} and click on the Edit button next to the new host to do this now.\n"
				select yn in "I have added the classes and parameters to the new host." "I will do this later."; do
					case $yn in
						"I have added the classes and parameters to the new host." )
							puppet agent -tv
							puppet agent -tv
							puppet agent -tv
							break;;
						"I will do this later." )
							break;;
					esac
				done
			    break;;
		esac
	done
else
    printf "${Black}${On_Red}\n\nERROR: Your Distribution is not supported by this script.\n\n${White}${On_Black}" 1>&2
    exit 1
fi

