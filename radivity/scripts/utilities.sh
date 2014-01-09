#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_mod.sh



function options {
echo -e "\n\n"
header
echo -e "\n\n\n\n\n  Please select which of the following modules you would like to use:\n"
echo -e -n "   1 - Grid from View\t\t\t2 - Check Filters\n"
echo -e -n "   3 - Clean rad file\t\t\t4 - Exit\n\n\n\n  "
}

menu(){
    case $module in
	1)
	    echo "Module used: "$module" (Grid from View)" >> $rad_logfile
	    $RADIVSCRIPTS/gridfromview.sh $rad_logfile $cli_option 2>> $rad_logfile
	    if [ "$?" -gt 0 ]; then
		print_error_message
	    else
		options
		read module
		menu
	    fi
	    ;;
	2)
	    echo "Module used: "$module" (Check Filter)" >> $rad_logfile
	    $RADIVSCRIPTS/checkfilter.sh $rad_logfile $cli_option 2>> $rad_logfile
	    if [ "$?" -gt 0 ]; then
		print_error_message
	    else
		options
		read module
		menu
	    fi
	    ;;
	3)
	    echo "Module used: "$module" (Clean rad file)" >> $rad_logfile
	    $RADIVSCRIPTS/clean_rad.sh $rad_logfile 2>> $rad_logfile
	    if [ "$?" -gt 0 ]; then
		print_error_message
	    else
		options
		read module
		menu
	    fi
	    ;;
	4)
	    echo "Exiting"
	    exit
	    ;;
    esac
}


rad_logfile=$1
fullusername=$2
cli_option=$3

echo -e "\n"
header
options
read module
menu



