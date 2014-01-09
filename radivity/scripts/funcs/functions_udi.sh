#!/bin/bash

. $HOME/.bash_rad.inc
shopt -s expand_aliases


function check_coeffs {
existing_coeffs="don't know"
if [ -e "$path_to_module/out/all_coefficients" ]; then
	if [ "$(basename $(head -n 1 $path_to_module/out/all_coefficients) | sed -n 's/_.*//p')" == "$city" ]; then
		lines=$(echo $(wc -l $path_to_module/out/all_coefficients) | sed 's/ .*//')
		headerUDI
		echo -e "\n\n"
		echo -e "  A coefficient file with "$lines" lines for '"$city"' already exists.\n  You can either:"
		echo "	  - re-calculate everything (which will take a long time), or"
		echo "	  - use the existing file and compute the UDI"
		echo " "
		echo " "
		echo -e -n "  Do you want to use the existing coefficient file [y/n]?\n\n  "
		read existing_coeffs
		echo -e "\tUse exisiting coeffs: "$existing_coeffs >> $logfile
	else
		headerUDI
		echo -e "\n\n"
		echo -n -e "  There is a coefficient file in\n  "$path_to_module"/out/\n  which does not match the city you specified.\n  If you proceed this will be replaced. Do you want to proceed [y/n]?\n\n\n\n\n\n  "
		read proceed
		echo -e "\tUse exisiting coeffs: n" >> $logfile
		if [ "$proceed" == "n" -o "$proceed" == "N" ]; then
			exit
		fi
	fi
else
	echo -e "\tUse exisiting coeffs: n" >> $logfile
fi
}


function get_thresholds_udi {
echo -e "\n\n\n"
headerUDI
echo -e "\n\n\n\n\n\n\n  Please indicate three thresholds for the UDI (default thresholds "
echo -e "  are 100, 2000 and 10000). Enter the three numbers separated by space"
echo -e -n "  before pressing Enter.\n\n  "
read thresholds
if [[ -z "$thresholds" ]];then
    echo -e "\tUDI thresholds: 100 2000 10000" >> $logfile
else
    echo -e "\tUDI thresholds: "$thresholds >> $logfile
fi
threshold1=$(echo $thresholds | awk '{print $1}')
threshold2=$(echo $thresholds | awk '{print $2}')
threshold3=$(echo $thresholds | awk '{print $3}')

counter=0
while [[ ! -z "$rest" || "$threshold1" -gt "$threshold2" || "$threshold2" -gt "$threshold3" ]]; do
	if [ $counter == 3 ]; then
		echo -e "\n\n  $fullusername!! You don't seem to take this seriously! This script will now exit!\n\n"
		sleep 3
		exit
	fi
	if [[ ! -z "$rest" ]]; then
		headerUDI
		echo -e -n "\n\n\n\n\n\n\n\n\n  Please enter only three values!\n\n  "
	elif [[ "$threshold1" -gt "$threshold2" || "$threshold2" -gt "$threshold3" ]]; then
		headerUDI
		echo -e -n "\n\n\n\n\n\n\n\n\n  The thresholds have to be in ascending order. Please enter three values.\n\n  "
	fi
	read thresholds
	sed -i '$ d ' $logfile
	echo -e "\tUDI thresholds: "$thresholds >> $logfile
	threshold1=$(echo $thresholds | awk '{print $1}')
	threshold2=$(echo $thresholds | awk '{print $2}')
	threshold3=$(echo $thresholds | awk '{print $3}')
	let counter=counter+1
done
}


function check_coeff_images {
if [ "$(ls -A $path_to_module/coefficients/*.pic 2> /dev/null)" ]; then
	echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	headerUDI
	echo -e -n "\n\n\n\n\n\n\n  Coefficient images exist, do you want to proceed to re-calculate them\n  (the existing images will be destroyed) [y/n]?\n\n\n  "
	read coeffs
	echo -e "\tRe-render scene images: "$coeffs >> $logfile
elif [ "$(ls -A $path_to_module/coefficients/*.dat 2> /dev/null)" ]; then
	coeffs="y"
	echo -e "\tThere were only grid-coefficients. These should always be re-calculated"
	echo -e "\tThere were only grid-coefficients. These should always be re-calculated" >> $logfile
	echo -e "\tRe-render scene images: y"
else
	coeffs="y"
	echo -e "\tThere were no coefficient images."
	echo -e "\tRender scene images: y (There were no coefficient images)." >> $logfile
fi
}

function get_resolution {
if [ "$coeffs" == "y" -o "$coeffs" == "Y" ]; then
	echo -e "\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
	headerUDI
	echo -e -n "\n\n\n  Choose one of the options to produce coefficient images:\n\n"
	echo -e -n "  [high]\t-\tHigh resolution (512x512 - takes a long time)\n"
	echo -e -n "  [low]\t\t-\tLow resolution (128x128 - takes less time)\n"
	echo -e -n "  [grid]\t-\tUsing grid (very fast, no smoothing)\n\n\n\n  "
	read ch_res
	if [ "$ch_res" == "low" ]; then
	    resol=128
	elif [ "$ch_res" == "grid" ]; then
	    resol=0
	fi
else
    resol=$(cat $(ls $path_to_module/coefficients/*.pic | head -n 1) | grep -a 'rtcontrib' | awk '{print $3}')
fi

echo -e "\tThe coefficients were produced with a resolution of: "$resol"x"$resol >> $logfile
}


function schedule_for_coeffs {
	headerUDI
	echo -e "\n  WARNING!!\n\n  Please make sure that the existing coefficient file matches\n  your desired schedule.\n"
	echo -e "  Please check the log file associated to the coefficient file\n  ("$path_to_module"/out/all_coefficients).\n  The log file is specified in the first line of the coefficient file.\n"
	echo -e -n "  Does it match your schedule [y/n]?\n  "
	read ex
	if [ "$ex" != "y" -a "$ex" != "Y" ]; then
		exit
	fi
	headerUDI
	echo -e -n "\n\n\n\n\n  Please enter the name of the schedule file:\n\n\n\n\n\n  "
	read sched_file_nopath
	sched_file=$root_path/schedule/$sched_file_nopath
	while [ ! -e "$sched_file" ]; do
		headerUDI
		echo -e -n "\n\n\n\n\n  That file does not exist.\n  Please enter a valid schedule file (with complete path):\n\n\n\n\n  "
		read sched_file
	done
	echo -e -n "\tUse existing schedule file: "$sched_file"\n" >> $logfile
}


function fix_errors_coeffs {
    sed -e 's/ERROR/0/g' $path_to_module/out/sun_coefficients > $path_to_module/tmp/sun_coefficients_tmp
    diff $path_to_module/out/sun_coefficients $path_to_module/tmp/sun_coefficients_tmp > $path_to_module/tmp/difference
    if [ -s "$path_to_module/tmp/difference" ]; then
	echo -e "\n  WARNING!!"
	echo -e -n "  There were sunrise/sunset alignment problems. This is usually OK,\n  but you might want to double-check your climate file for\n  correct alignment."
	echo " "
	echo -e -n "\n\tWARNING!!\n  There were sunrise/sunset alignment problems. This is usually OK,\n\tbut you might want to double-check your climate file for\n\tcorrect alignment.\n" >> $logfile
	echo " "
    fi
    rm $path_to_module/tmp/difference

    counter=-1
    while read line
    do
		let counter=$counter+1
    done < $sun_mod

    zeros="0"
    for ((i=1;i<$counter;i++)); do
		zeros=$zeros" 0"
    done
    sed -e "s/.*Error:.*/$zeros/" $path_to_module/tmp/sun_coefficients_tmp > $path_to_module/out/sun_coefficients_fixed
    diff $path_to_module/tmp/sun_coefficients_tmp $path_to_module/out/sun_coefficients_fixed > $path_to_module/tmp/difference
    if [ -s "$path_to_module/tmp/difference" ]; then
	echo "  WARNING!!"
	echo "  There were differences between the climate file and the sun index file."
	echo "  This has been fixed and should be OK, but you might want to double-check" 
	echo "  your climate file for potential errors."
	echo " "
	echo -e "\n\tWARNING!!\n\tThere were differences between the climate file and the sun index file.\n\tThis has been fixed and should be OK, but you might want to double-check\n\tyour climate file for potential errors." >> $logfile
    fi
    rm $path_to_module/tmp/difference
    rm $path_to_module/tmp/sun_coefficients_tmp
    
    
    echo $logfile > $path_to_module/out/all_coefficients
    paste $path_to_module/out/coefficients $path_to_module/out/sun_coefficients_fixed >> $path_to_module/out/all_coefficients
    words=$(tail -n +2 $path_to_module/out/all_coefficients | wc -w)
    # words=$(tail -n $(($(cat $path_to_module/out/all_coefficients | wc -l)-1)) $path_to_module/out/all_coefficients | wc -w)
    lines=$(($(cat $path_to_module/out/all_coefficients | wc -l)-1))

    frac=$((($words)%$lines))	

    if [ $frac -eq 0 ]; then
		echo "  The final coefficient file (all_coefficients) seems to be OK"
    else
		echo "  There seems to be a problem with one of the coefficient files. Some line has less entries than expected."
    fi
}


function check_ouput_images {
    refinish=n
    for scene in $(ls $root_path/scenes/*.rad);do
	for view in $(ls $root_path/views/*.vf);do
	    sc_name=$(basename $scene .rad)
	    v_name=$(basename $view .vf)
	    if [ "$(ls $path_to_module/images/$(basename $scene .rad)"_"$(basename $view .vf)*.pic | wc -l)" == "5" ];then
		date_im=$(head -n 2 $(echo $(ls $path_to_module/images/$sc_name"_"$v_name*.pic) | awk '{print $1}') | tail -n 1 | awk '{print $2}'| sed 's/:/\//g')
		time_im=$(head -n 2 $(echo $(ls $path_to_module/images/$sc_name"_"$v_name*.pic) | awk '{print $1}') | tail -n 1 | awk '{print $3}')
		echo "There are finished pic files, which were created on "$date_im" at "$time_im". Do you want to refinish them?"
	    fi
	done
    done
}
