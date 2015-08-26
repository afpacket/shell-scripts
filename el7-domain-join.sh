#!/bin/bash

DOMAIN=mydomain
OU=myou
USER=myuser
GROUP=mygroup

show_usage() {
   echo -e "BASH Script for joining RHEL / CentOS 7 machine to a domain"
   echo -e "By Andrew Fox\n"
   echo -e "Usage: el7-domain-join.sh [-i|-j]"
   echo -e "Options:"
   echo -e " -h, --help"
   echo -e "    Print detailed help screen"
   echo -e " -i, --install-deps"
   echo -e "    Install Dependencies"
   echo -e " -j, --join"
   echo -e "    Join Domain"
}

if [ $(whoami) != 'root' ]; then
   echo "Must be root to run script"
   exit 1
elif [ "$1" == "-h" ] || [ "$1" == "--help" ] || [ $# -eq 0 ]; then
   show_usage
   exit 1
elif [ "$1" == "-i" ] || [ "$1" == "--install-deps" ]; then
   yum -y install samba-common realmd oddjob oddjob-mkhomedir sssd adcli
   exit 0
elif [ "$1" == "-j" ] || [ "$1" == "--join" ]; then
   realm join $DOMAIN -U $USER --computer-ou=$OU -v
   sed -i 's/use_fully_qualified_names = True/use_fully_qualified_names = False/g' /etc/sssd/sssd.conf
   systemctl restart sssd.service
   realm permit -g $GROUP
   sed -i '106i "%'$GROUP'" ALL=(ALL)\tALL' /etc/sudoers
   exit 0
else 
   show_usage
   exit 1
fi
