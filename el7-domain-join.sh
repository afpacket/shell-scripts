#!/bin/bash

DOMAIN="mydomain"
OU="myou"
USER="myuser"
GROUP="mygroup"

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
   #echo "dyndns_update = True" >> /etc/sssd/sssd.conf
   systemctl restart sssd.service
   realm permit -g $GROUP
   sed -i '106i "%'$GROUP'" ALL=(ALL)\tALL' /etc/sudoers

	# Search for domain presence in krb5.conf	
	KRBSEARCH=$(grep -i "$DOMAIN" /etc/krb5.conf)
 
	if [ "$KRBSEARCH" == "" ]; then
	   sed -i 's/default_ccache_name = KEYRING:persistent:%{uid}/default_ccache_name = KEYRING:persistent:%{uid}\n\n default_realm = '"${DOMAIN^^}"'/g' /etc/krb5.conf
	   sed -i 's/# }/# }\n\n '"${DOMAIN^^}"' = {\n }/g' /etc/krb5.conf
	   sed -i 's/# example.com = EXAMPLE.COM/# example.com = EXAMPLE.COM\n '"$DOMAIN"' = '"${DOMAIN^^}"'\n .'"$DOMAIN"' = '"${DOMAIN^^}"'/g' /etc/krb5.conf
	   exit 0
	else 
	   exit 0 
   	fi
else 
   show_usage
   exit 1
fi
