#!/bin/bash

#                         nmapSL
#                    Created By Hi_skid
#
# This script will detect all open ports on the target and then
# run service detection on those specific ports, cutting down on
# The total time it takes to enumerate services on open ports.

#Setting variables

#Help text
usage="$(basename "$0") [hostname] [-h] -- This script will detect all open ports on the target and then run service detection on those specific ports.

where:
  -h  show this help text"

#Parse cli arguments
while getopts ":h" opt; do
	case ${opt} in
		h )
			echo "$usage"
			exit 0
			;;
		\? )
			echo "Invalid Option: -$OPTARG" 1>&2
			exit 1
			;;
	esac
done
shift $((OPTIND -1))

#Check to see if ip has been passed as an agrument.  If so set hostname to first argument
if [ -n $1 ]
then
	hostname="$1"
fi

#Creating directory to save temporary files
mkdir ~/nmapSL_RUN
cd ~/nmapSL_RUN

#Prompting user for input details regarding scan
#Asking for hostname/IP, and saving results to the $hastname variable
printf "\nThis script will scan the provided IP/Hostname over all possible ports and return the open ports, services running on those ports, and perform OS detection on the host.\n\nScan type is NMAP DEFAULT\n\nOpen ports will be collected first with no service scanning, then the open scans will be specifically scanned for services running over those ports\n\n\n"
#Check if hostname previously has been set and if so skip prompt
if [ -z $hostname ]
then
	read -p "Enter Target IP/Hostname: " hostname
fi

#defining function that will later be used to concatinate all open ports discovered, and seperate them by a comma so they can be passed into the service discovery scan 
function join_by { local IFS="$1"; shift; echo "$*"; }

#Defining array and string variables for later use
arr=()
ports=""
runpath="$(pwd)"

#Initial port detection scan. This scan will find open ports, taking the $hostname variable collected from the user earlier to designate the target
nmap -Pn -oN ports.txt --top-ports 1000 $hostname

#ports.txt is searched for the ports, then the port numbers are pulled out and added 1 by 1 into the array for joining
for i in $(cat ports.txt | grep open | awk '{print $1}'|grep -Eo '[0-9]{1,4}') 
do
	echo $i
	arr+=( "$i" )
done

#Ports have been added to the array, so the temp file is no longer required
rm ports.txt

#Updating the user, then taking the items in the array (individual port numbers seperated by spaces), and joining them together, seperated by commas. This string is then assigned to the $ports variable for use in the service detection scan
printf "\n\nInitial port detection complete, checking services on the detected open ports\n\n"
ports=$(join_by , "${arr[@]}")
echo $ports

#Service detection scan, taking $hostname for the target, and $ports as the ports to scan.
nmap -sV -p $ports $hostname| grep -w 'open\|OS\|report' >> nmap_results.txt
printf "\n\nScan complete! Results have been saved in the nmap_results.txt file stored at "
echo "${runpath}"
