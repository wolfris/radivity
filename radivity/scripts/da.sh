#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_mod.sh

function options {
    header_selector 4
    echo -e "  Please select which of the following modules you would like to use:\n"
    echo -e "   1 - Daylight Factor\t\t\t2 - Illuminance"
    echo -e -n "   3 - UDI\t\t\t\t4 - Exit\n\n\n\n  "
# echo -e "   1 - 'Traffic lights' image\t\t2 - Daylight Factor"
# echo -e "   3 - Luminance\t\t\t4 - Illuminance"
# echo -e -n "   5 - UDI\t\t\t\t6 - Exit\n\n\n\n  "
}

menu(){
    case $module in
	1)
	    echo "Module used: "$module" (Daylight Factor)" >> $rad_logfile
	    $RADIVSCRIPTS/df.sh $rad_logfile $fullusername $cli_option 2>> $rad_logfile
	    if [ "$?" -gt 0 ]; then
		print_error_message
	    else
		options
		read module
		menu		    
	    fi
	    ;;
	2)
	    echo "Module used: "$module" (Illuminance)" >> $rad_logfile
	    $RADIVSCRIPTS/illum.sh $rad_logfile $fullusername $epw_climate_file $cli_option 2>> $rad_logfile
	    if [ "$?" -gt 0 ]; then
		print_error_message
	    else
		options
		read module
		menu		    
	    fi
	    ;;
	3)
	    echo "Sub-Module used: "$module" (UDI)" >> $rad_logfile
	    udi.sh $rad_logfile $fullusername $cli_option 2>> $rad_logfile
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
epw_climate_file=$3
cli_option=$4


echo -e "\n"
header
options
read module
menu



