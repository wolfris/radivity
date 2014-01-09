#!/bin/bash

. $HOME/.bash_rad.inc
shopt -s expand_aliases


get_daylighthours(){
    hour_init=25
    hour_final=25
    while [[ "$hour_init" -gt 24 || "$hour_final" -gt 24 ]]; do
	echo -e "\n\n"
	headerShadow
	echo -e "\n\n\n\n\n\n\n\n "
	echo -e -n "  Enter daylight hours separated by space (Example: 8 20):\n\n  "
	read dlghthrs
	hour_init=$(echo $dlghthrs | awk '{print $1}')
	hour_final=$(echo $dlghthrs | awk '{print $2}')
	if [ -z $hour_final ];then
	    hour_final=$hour_init
	fi
    done
}

get_minutes(){
    echo -e "\n\n"
    headerShadow
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n "  Enter number of intervals per hour:\n\n  "
    read intervals
}

