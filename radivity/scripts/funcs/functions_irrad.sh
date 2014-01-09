#!/bin/bash

. $HOME/.bash_rad.inc
shopt -s expand_aliases


function get_options_irrad {
echo -e "\n\n\n"
headerIrrad
echo -e "\n  Please select as many as needed from the following options (sep. by space):"
echo -e "   a - No climate\t\tb - No images"
echo -e "   c - No octrees\t\td - No overture"
echo -e "   e - Refinish\t\t\tf - Reuse filters"
echo -e "   g - insolation hours\t\th - Reuse cache\n\n"
echo -e -n "  Example: a c f  [ENTER]\n  "
read options_raw
options=$(echo $options_raw | awk '{for (i=1;i<=NF;i++) print "-"$i}')
options=" -C "$1" -m "$path_to_module" -w "$root_path" "$options
echo -e "\tIrradiation options are: "$(echo $options | awk '{print NF}') $options >> $2
}


function check_sun_up_errors {
sun_up_errors=$(cat $1 | grep 'Error!  Solar altitude < 6 degrees' | wc -l)
if [[ "$sun_up_errors">0 ]]; then
    echo -e "\n\n\n"
    headerIrrad
    echo -e "\n\n\n\n\n\n  There were "$sun_up_errors" errors related to low sun irradiation.\n  Please check \033[00;33m/modules/irrad/tmp/"$(basename $1)"\033[00m for details!\n"
    echo -e "  To exit, press Ctr-c."
    sleep 10
fi
}


function check_gensuns_errors {
if [ -s $1 ]; then
    echo -e "\n\n\n"
    headerIrrad
    echo -e "\n\n\n\n\n\n  There were errors related to the gensuns.exe program.\n  Please check \033[00;33m/modules/irrad/tmp/"$(basename $1)"\033[00m for details!\n"
    read -p "  Press [Enter] to exit.."
    exit
fi
}    
