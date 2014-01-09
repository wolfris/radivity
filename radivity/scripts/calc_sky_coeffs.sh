#!/bin/bash

climate_file=$1
path_to_module=$2

lib_path=$HOME/bin/radivity/lib


rm -f $path_to_module/out/coefficients
rm -f $path_to_module/tmp/this_sky*
rm -f $path_to_module/tmp/pval.dat

location_line=$(head -n 1 $climate_file)
counter=0
echo $location_line
tail -n +2 $climate_file | while read climate_file_line; do 
    let counter=counter+1
# assume solar irradiance is greater than zero (zeros should be removed from climate file! - use grep -v '0.0.$' $climate_file) ....
# MERIDIAN, LATITUDE, LONGITUDE IN THIS LINE - NOTE -ve EAST OF GREENWICH - NOT MY FAULT!
    gendaylit $(echo $climate_file_line $location_line | rcalc -o '${$1} ${$2} ${$3} -G ${$4-$5} ${$5} -m ${0-$8} -a ${$6} -o ${0-$7} -s -O 2 ')  > $path_to_module/tmp/this_sky.rad 2>> $path_to_module/tmp/gendaylit.log
    echo -e 'Processing line' $counter 'of the climate file..'
# if generated sky file is more than 4 lines long (i.e. it generated ok)...
    if test  $(wc $path_to_module/tmp/this_sky.rad | awk '{print $1}') -gt 4 ; then
	# generate sky radiance distribution, sample it and put results in pval.dat
	oconv -w $path_to_module/tmp/this_sky.rad $lib_path/sky_source.rad > $path_to_module/tmp/this_sky.oct
	rtrace -w -h -dv- $path_to_module/tmp/this_sky.oct < $RAYLIB/tregsamp.dat 2> $path_to_module/tmp/rtrace.log | total -64 -m > $path_to_module/tmp/pval.dat
	
	awk '{printf "%f ",$1} END {printf "\n"}' $path_to_module/tmp/pval.dat >> $path_to_module/out/coefficients
    else
	echo "" | awk '{for (i=1; i<=146; ++i) {printf "0 "}; printf "\n";}' >> $path_to_module/out/coefficients 
    fi
done


