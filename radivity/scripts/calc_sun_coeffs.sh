#!/bin/bash

climate_file=$1
sun_indices=$2
sun_modifiers=$3
path_to_module=$4

sun_count=`wc $sun_modifiers | awk '{print $2}'`

location_line=`head -n 1 $climate_file`
counter=0
tail -n +2 $climate_file | paste - $sun_indices | while read climate_file_line; do 
    let counter=counter+1
    echo -e 'Processing line' $counter 'of the climate file..'
# assume solar irradiance is greater than zero (zeros should be removed from climate file! - use grep -v '0.0.$' $climate_file) ....
# MERIDIAN, LATITUDE, LONGITUDE IN THIS LINE - NOTE -ve EAST OF GREENWICH - NOT MY FAULT!
    solar_brightness_line=$(`echo $climate_file_line $location_line | rcalc -o 'gendaylit ${$1} ${$2} ${$3} -G ${$4-$5} ${$5} -m ${0-$9} -a ${$7} -o ${0-$8} -O 2 +s'` | \
	head -n 7 | tail -n 1)
    solar_brightness=`echo $solar_brightness_line | awk '{if (NF!=4 ) { print "ERROR" } else {print $2}}'`
    sun_index=`echo $climate_file_line | awk '{print $6}'`
	# if sun index is in range...
    if test $sun_index -ge 0; then
	echo $sun_index $solar_brightness $sun_count | awk '{for (i=1; i<$1; ++i) {printf "0 "}; printf $2" "; for (i=$1+1; i<=$3; ++i) {printf 0" "}; printf "\n" }' >> $path_to_module/out/sun_coefficients
    else
		# sun index is -1, so sun is below horizon.  That's okay as long as Ibh=0...
	if test `echo $climate_file_line | awk '{print $4-$5}'` -gt 10; then
	    echo "Error: invalid sun index: "$climate_file_line >> $path_to_module/out/sun_coefficients
	else
	    echo $sun_count | awk '{for (i=1; i<=$1; ++i) {printf "0 "}; printf "\n";}' >> $path_to_module/out/sun_coefficients 
	fi
    fi
    
done
