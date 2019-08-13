#!/bin/bash
cd ~
printf "\nThis script will scan the provided IP/Hostname over all possible ports and return the open ports, services running on those ports, and perform OS detection on the host.\n\nScan type is NMAP DEFAULT\n\nOpen ports will be collected first with no service scanning, then the open scans will be specifically scanned for services running over those ports\n\n\n"
read -p "Enter Target IP/Hostname: " hostname
function join_by { local IFS="$1"; shift; echo "$*"; }
arr=()
ports=""
for i in $(nmap -p 1-65535 $hostname| grep open|grep -o '[0-9]\+')
do
	for t in $i
       	do 
		arr+=( "$t" )
	done
done
ports=$(join_by , "${arr[@]}")
sudo nmap -sV -O -p $ports $hostname| grep -w 'open\|OS\|report' >> nmap_results.txt
