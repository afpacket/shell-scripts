#!/bin/bash

show_usage() {
   echo -e "BASH Script for generating a Nagios host definition"
   echo -e "By Andrew Fox\n"
   echo -e "Usage: nagios-confgen.sh -H <Host name> -c <Contact group(s)> -g <Hostgroup(s)> [-d <Description>] [-i <Image>]\n"
   echo -e "Example:"
   echo -e "nagios-confgen.sh -H nagios -c admins -g linux-servers -d myserver -i redhat.png"
}

if [ $# -eq 0 ]; then
   show_usage
   exit 1
else
	while getopts c:d:H:i:g: OPTION
	do	
		case $OPTION
			in
			c)
			CONTACTGROUPS="$OPTARG"
			;;
			d)
			DESCRIPTION="$OPTARG"
			;;
			H)
			HOST_NAME="$OPTARG"
			;;
			i)
			IMAGE="$OPTARG"
			;;
			g)
			HOSTGROUP_NAME="$OPTARG"
			;;
			*)
			show_usage
			exit 1
			;;
		esac
	done
fi

# Input Sanitization
CONTACTGROUPS_CLEAN=${CONTACTGROUPS//[^a-zA-Z0-9\-\_\,]/}
DESCRIPTION_CLEAN=${DESCRIPTION//[^a-zA-Z0-9\[\]\ \_]/}
HOST_NAME_CLEAN=${HOST_NAME//[^a-zA-Z0-9]/}
HOSTGROUP_NAME_CLEAN=${HOSTGROUP_NAME//[^a-zA-Z0-9\-\_\,]/}
IMAGE_CLEAN=${IMAGE//[^a-zA-Z0-9\.]/}
IPADDR=$(host ${HOST_NAME_CLEAN} | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')

if [[ "$CONTACTGROUPS_CLEAN" == "" || "$HOST_NAME_CLEAN" == "" || "$HOSTGROUP_NAME_CLEAN" == "" ]]; then
   show_usage
   exit 1
fi

if [ "$DESCRIPTION_CLEAN" == "" ]; then
   DESCRIPTION_CLEAN=${HOST_NAME_CLEAN}
fi

if [ "$IMAGE_CLEAN" == "" ]; then
   IMAGE_CLEAN=switch.gif
fi

echo -e "define host {\n\tuse\t\t\tgeneric-host\n\thost_name\t\t$HOST_NAME_CLEAN\n\talias\t\t\t$DESCRIPTION_CLEAN\n\taddress\t\t\t$IPADDR\n\tcontact_groups\t\t$CONTACTGROUPS_CLEAN\n\thostgroups\t\t$HOSTGROUP_NAME_CLEAN\n\ticon_image\t\t$IMAGE_CLEAN\n\t}"

exit 0
