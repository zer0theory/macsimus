#!/bin/bash

################################################
#
#                   macsimus
#
# https://github.com/zer0theory
# A program that will quickly randomize the mac
# address of your current network interface.
#
#  This requires sudo. (lolcat doesn't hurt)
#
################################################

# Checking for sudo
if [ "$EUID" -ne 0 ]
then printf "Please run with sudo \n"
				exit 1
fi

# Asking / finding for your interface
printf "Leave blank to attempt self detection\n"
read -p "Enter your network interface: " iface

if [ -z "$iface" ]
then
  iface=$(ip a | grep '^.* state UP' | cut -d ' ' -f2 | sed 's/:$//')
#	iface=$(ip r show|grep -F " src "|cut -d " " -f 3)
fi

# Finding your current and permanent mac address
currentmac=$(ip link show "$iface"| grep -F "link"| cut -d " " -f 6)
permmac=$(ethtool -P "$iface"|cut -d " " -f 3)

# checking for lolcat for the lulz
catCheck=$(command -v lolcat)

# Random bits for first sextet in mac to avoid errors
declare -a arr=("0" "1")

for i in {1..7}
do
				declare "b$i=$[$RANDOM % ${#arr[@]}]"
done

binary="$b1""$b2""$b3""$b4""$b5""$b6""$b7"0

# Setting random hex values for the new mac address
# Special case for m1 as it needs to end in zero

m1=$(printf '%x\n' "$((2#$binary))")

# Set m2 through m6
for i in {2..6}
do
				declare "m$i=$(openssl rand -hex 1)"
done

randmac="$m1:$m2:$m3:$m4:$m5:$m6"

# stop the interface, Randomize the mac, then restart interface

macChange () {
				ip link set "$iface" down
				ip link set "$iface" address "$randmac"
				ip link set "$iface" up
}

macInfo () {
				printf "         ##### Starting Macsimus #####\n"
				printf "Your current mac address:    %s\n" "$currentmac"
				printf "Your permanent mac address:  %s\n" "$permmac"
}

if [ -n "$catCheck" ]
then
		macInfo | lolcat
else
		macInfo
fi

# changing the mac address officially
macChange

# grep out the new mac address
finalmac=$(ip link show "$iface"| grep -F "link"| cut -d " " -f 6)

# and print it out
if [ -n "$catCheck" ]
then
				printf "Your new mac address:        %s\n" "$finalmac"|lolcat
else
				printf "Your new mac address:        %s\n" "$finalmac"
fi

