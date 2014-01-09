#!/bin/bash

. $HOME/.bash_rad.inc
shopt -s expand_aliases


header() {
echo "  ***************************************************************************** "
echo "  **                _____           _ _       _ ___     __                   **"
echo "  **               |  __ \         | (_)     (_) \ \   / /                   **"
echo "  **               | |__) |__ _  __| |___   ___| |\ \_/ /                    **"
echo "  **               |  _  // _\` |/ _\` | \ \ / / | __\   /                     **"
echo "  **               | | \ \ (_| | (_| | |\ V /| | |_ | |                      **"
echo "  **               |_|  \_\__,_|\__,_|_| \_/ |_|\__||_|                      **"
echo "  **                                                                         **"
echo "  **                 BDSP Radiance Productivity Tool                         **"
echo "  **                                                                         **"
echo "  ***************************************************************************** "
}


header_selector(){
    skip_lines=$1
    case $2 in
	udi)
	    echo -e "\n\n"
	    headerUDI 
	    ;;
	df)
	    echo -e "\n\n"
	    headerDF 
	    ;;
	illum)
	    echo -e "\n\n"
	    headerIllum 
	    ;;
	render)
	    echo -e "\n\n"
	    headerRender
	    skip_lines=$(echo $1 | awk '{print $1-1}')
	    ;;
	ieq)
	    echo -e "\n\n"
	    headerIeq 
	    ;;
	irr)
	    echo -e "\n\n"
	    headerIrrad
	    skip_lines=$(echo $1 | awk '{print $1-2}')
	    ;;
	shadow)
	    echo -e "\n\n"
	    headerShadow
	    ;;
	*)
	    echo -e "\n\n\n"
	    header
	    skip_lines=$(echo $1 | awk '{print $1+1}')
	    ;;
    esac
    for i in $(eval echo {1..$skip_lines});do
	echo -e " "
    done
}

print_error_message() {
    echo -e "\n\n\n"
    header
    echo -e "\n\n\n  ******************************************************************"
    echo -e -n "  *\n  * \033[0;31mRadivity finished with errors!\033[00m\n  * Please check the log files for information.\n  *\n  *"
    echo -e "*****************************************************************\n\n\n"
    read -p "  Press [Enter] to exit.."
}


get_climate() {
    header_selector 11 $1
    if [ $(ls -1 $root_path/climate | wc -l) == 1 ]; then
	climate_file_epw="$root_path/climate/"$(ls $root_path/climate/)
    elif [ $(ls -1 $root_path/climate | wc -l) == 0 ]; then
	echo "  There is no climate file in the climate folder. Please check."
	sleep 5
	exit
    else
	echo $(ls -1 $root_path/climate | wc -l)
	echo "  There is more than one climate file in the climate folder. Please check."
	sleep 5
	exit	
    fi
    $RADIVSCRIPTS/epw2udi.py
    for files in `ls $root_path/climate/`; do
	if [ ${files##*.} != 'epw' ]; then
	    mv $root_path/climate/$files $path_to_module/climate
	fi
    done
    base_climate=$path_to_module/climate/$(basename $climate_file_epw .epw)
    climate_file=$(echo $base_climate".dat")
}

get_accuracy() {
    header_selector 9 $1
    echo -e -n  "  Do you want high, low or customized level of accuracy [high/low/custom]?\n\n  "
    read accuracy
    
    while [ "$accuracy" != "high" -a  "$accuracy" != "low" -a "$accuracy" != "custom" ]; do
	header_selector 8 $1
	echo -e -n  "  Do you want high, low or costumized level of accuracy [high/low/custom]?\n\n  "
	read accuracy
    done
}


set_schedule() {
    header_selector 8 $1
    if [ "$(ls -A $root_path/schedule)" ];then
	header_selector 8 $1
	echo -e -n "  There is a schedule file in the schedule directory,\n  do you want to use it [y/n]?\n\n  "
	read schedule
	echo -e "\tUse existing schedule file: "$schedule >> $logfile
	if [ "$schedule" == "n" -o "$schedule" == "N" ]; then
	    schedule_options "$1"
	    read schedule
	    schedule_select
	    echo -e "\tSchedule file: "$sched_file >> $logfile
	else
	    counter=$(ls -A $root_path/schedule | wc -l)
	    if [ "$counter" -gt 1 ]; then
		header_selector 8 $1
		echo -e -n "  There are "$counter" schedule files, please enter the one you'd like to use.\n\n  "
		read schedule
		sched_file=$root_path/schedule/$schedule
		echo -e "\tSchedule file: "$sched_file >> $logfile
	    else
		sched_file=$root_path/schedule/$(ls -A $root_path/schedule)
		echo -e "\tSchedule file: "$sched_file >> $logfile
	    fi
	fi
    else
	schedule_options "$1"
	read schedule
	schedule_select
	echo -e "\tSchedule file: "$sched_file >> $logfile
    fi
}

schedule_options() {
    header_selector 3 $1
    echo -e "\n\n\n  Please select an appropiate schedule:\n"
    echo -e "   1 - Whole year (8760 hours)\t\t2 - Hospital"
    echo -e -n "   3 - Seasons\t\t\t\t4 - User defined\n\n  "
}


ask_palette() {
    header_selector 8 $1
    echo -e -n "  The default color palette for the images is '"$palette"'.\n  Do you want to change that [y/n]?\n\n  "
    read change_palette
    if [ "$change_palette" == "y" -o "$change_palette" == "Y" ]; then
	get_palette $1
    else
	echo -e "\tColour palette: "$palette >> $logfile
    fi
}


get_palette() {
    header_selector 2 $1
    echo -e -n "  Please select a color palette for the images:\n\n  Radiance\t\033[00;37;44mblue\033[00m  ->\033[00;37;42mgreen\033[00m ->\033[00;37;41mred\033[00m   \t\t-->\tspec\n  Hot\t\tblack ->\033[00;37;41mred\033[00m   ->\033[00;30;43myellow\033[00m\t\t-->\thot\n  Pm3D\t\tblack ->\033[00;37;45mpurple\033[00m->\033[00;37;41mred\033[00m->\033[00;30;43myellow\033[00m\t-->\tpm3d\n  Mono Blue\t\033[00;30;47mwhite\033[00m ->\033[00;37;44mblue\033[00m\t\t\t-->\tb\n  Mono Red\t\033[00;37;41mred\033[00m   ->\033[00;30;47mwhite\033[00m\t\t\t-->\tr\n  Yellow-Red\t\033[00;30;43myellow\033[00m->\033[00;37;41mred\033[00m\t\t\t-->\tyr\n\n  "
    read palette_in
    case $palette_in in
	spec)
	    palette="spec"
	    ;;
	hot)
	    palette="hot"
	    ;;
	pm3d)
	    palette="pm3d"
	    ;;
	b)
	    palette="mono_b"
	    ;;
	r)
	    palette="mono_r"
	    ;;
	yr)
	    palette="mono_ry"
	    ;;
	*)
	    get_palette $1
	    ;;
    esac
}



get_rotation_options() {
    less $1 > $2
    header_selector 8 $3 
    echo -e -n "  By default the model points North (0 degrees rotation).\n  Do you want to change that [y/n]?\n\n  "
    read changerotation
    if [ "$changerotation" == "y" -o "$changerotation" == "Y" ]; then
	echo -e "\n\n\n"
	headerIrrad
	echo -e -n "\n\n\n\n\n\n\n  Please enter the degrees of rotation (separated by space if more than one):\n\n  "
	read newrotation
	head -n 5 $1 > $2
	echo $newrotation | awk '{for (i=1;i<=NF;i++) {print $i}}' >> $2
    fi
    echo -e "\tSky rotations: "$(tail $2 -n +6 | awk '{printf $1" "}'| awk '{print NF}') $(tail $2 -n +6 | awk '{printf $1" "}') >> $logfile
}


get_image_size_options() {
    less $1 > $2
    x=$(less $1 | awk '{print $2}')
    y=$(less $1 | awk '{print $4}')
    header_selector 8 $3
    echo -e -n "  Enter resolution for the images (\033[00;33mseparated by space\033[00m, default resolution\n  is "$x"x"$y"):\n\n  "
    read newsize
    new_x=$(echo $newsize | awk '{print $1}')
    new_y=$(echo $newsize | awk '{print $2}')
    if [ ! -z $new_x ] && [ ! -z $new_y ];then
	echo "$newsize" | awk '{print "-x "$1" -y "$2}' > $2
    fi	
    echo -e "\tImage size: "$(less $2) >> $logfile    
}


get_falsecolor_cfg_options() {
    less $1 > $2

    if [ ! "$3" == "udi" ]; then
	header_selector 9 $3
	echo -e -n "  Do you want to add the \033[00;33mband\033[00m option for the falsecolor images [y/n]?\n\n  "
	read bandoption
	if [ "$bandoption" == "y" -o "$bandoption" == "Y" ]; then
	    tempvar=$(less $1)
	    echo "$tempvar -cb" > $2
	fi
    fi
    header_selector 9 $3  
    echo -e -n "  Enter number of divisions \033[00;33m(-n option)\033[00m (default number: "$(cat $2 | \
	awk '{for (i=1;i<=NF;i++) {if ($i == "-n") {print $(i+1)}}}')")\n\n  "
    read newn
    tf=$path_to_module"/tmp/tmp1"
    if [ ! -z $newn ];then
	echo $newn | paste $2 - > $tf
	cat $tf | awk '{for (i=1;i<=(NF-1);i+=2) {if ($i == "-n") {printf $i" "$(NF)" "} else if ($i=="-cb" || $i=="-z") {printf $i" ";i-=1} else {printf $i" "$(i+1)" "}}}' > $2
    fi
    if [ ! "$3" == "udi" ]; then
	header_selector 9 $3
	echo -e -n "  Enter a \033[00;33mscale\033[00m (default scale: "$(cat $2 | awk '{for (i=1;i<=NF;i++) {if ($i == "-s") {print $(i+1)}}}')")\n\n  "
	read newscale
	if [ ! -z $newscale ];then
	    echo $newscale | paste $2 - > $tf
	    cat $tf | awk '{for (i=1;i<=(NF-1);i+=2) {if ($i == "-s") {printf $i" "$(NF)" "} else if ($i=="-cb" || $i=="-z") {printf $i" ";i-=1} else {printf $i" "$(i+1)" "}}}' > $2
	fi
    fi
	
    if $expert_mode; then
	ask_palette $3
    fi
    less $2 | awk -v pal=$palette '{for(i=1;i<=NF;i++) if(i!=NF) {printf $i" "} else {printf $NF" -"pal}}' > $2
	
    header_selector 9 $3
    echo -e -n "  Do you want to change any other option for the falsecolor images [y/n]?\n\n  "
    read otheroption
    if [ "$otheroption" == "y" -o "$otheroption" == "Y" ]; then
	header_selector 3 $3
	echo -e "  The current options are:\n"
	echo -e "\033[00;33m  $(less $2)\033[00m\n"
	echo -e -n "  Please enter the new options (following the same format):\n\n  "
	read newoptions
	echo "$newoptions" > $2
    fi
}

get_amb_cfg_options() {
    header_selector 3 $3
    if [ "$3" == "udi" ]; then
	echo -e "  The default ambient parameters for the "$4" renderings are:"
    elif [ "$3" == "irr" ]; then
	echo -e "  The "$4" ambient parameters are:"
    else
	echo -e "  The default ambient parameters are:"
    fi
    echo -e "  \t-ab: "$(less $1 | awk '{for (i=1;i<=NF;i++) {if ($i == "-ab") {print $(i+1)}}}') 
    echo -e "  \t-aa: "$(less $1 | awk '{for (i=1;i<=NF;i++) {if ($i == "-aa") {print $(i+1)}}}') 
    echo -e "  \t-ar: "$(less $1 | awk '{for (i=1;i<=NF;i++) {if ($i == "-ar") {print $(i+1)}}}') 
    echo -e "  \t-ad: "$(less $1 | awk '{for (i=1;i<=NF;i++) {if ($i == "-ad") {print $(i+1)}}}') 
    echo -e "  \t-as: "$(less $1 | awk '{for (i=1;i<=NF;i++) {if ($i == "-as") {print $(i+1)}}}') 
    echo -e -n "  Do you want to adjust them [y/n]?\n\n  "
    read adjust_ambparams
    
    if [ "$adjust_ambparams" == "y" -o "$adjust_ambparams" == "Y" ]; then
	header_selector 9 $3
	echo -e -n "  Enter the parameter(s) you want to adjusttt (example: -ab 5 -ar 32):\n\n  "
	read newparams
	adjambpar=$(echo $newparams | awk '{for (i=1;i<=NF;i=i+2) {print $i}}')
	counter=2
	tempvar=$(less $1)
	for param in $(echo $adjambpar); do
	    paramvalue=$(echo $counter $newparams | awk '{print $($1+1)}')
	    tempvar=$(echo $paramvalue $param $tempvar | awk '{bool=0;for (i=3;i<=NF;i=i+2) {if ($i==$2) {print $i" "$1;bool=1} else {print $i" "$(i+1)}}; if (bool==0){print $2" "$1}}')
	    let counter=$counter+2
	done
	echo $tempvar > $2
    else
	less $1 > $2
    fi
    if [ "$3" == "udi" ]; then
	echo -e "\tThe ambient parameters used for the "$4" renderings are: " $(less $2 | awk '{print NF}')" "$(less $2)" (all others default)" >> $5
    elif [ "$3" == "df" ]; then
	echo -e "\tThe ambient parameters used are: " $(less $2 | awk '{print NF}')" "$(less $2)" (all others default)" >> $4
    elif [ "$3" == "illum" ]; then
	echo -e "\tThe ambient parameters used are: " $(less $2 | awk '{print NF}')" "$(less $2)" (all others default)" >> $4
    elif [ "$3" == "render" ]; then
	echo -e "\tThe ambient parameters used are: " $(less $2 | awk '{print NF}')" "$(less $2)" (all others default)" >> $4
    elif [ "$3" == "irr" ]; then
	echo -e "\tThe ambient parameters used are: " $(less $2 | awk '{print NF}')" "$(less $2)" (all others default)" >> $5
    fi
}


check_octrees() {
    FILTER=$(find $1 -type f \( -name "*.oct" \)) 
    if [ -z $(echo ${FILTER} | awk '{print $1}') ]; then
	echo -e "\n\n\n"
	headerIrrad
	echo -e "\n\n\n\n\n\n\n  There are no octrees, please do not use the\033[00;31m No Octree\033[00m option!\n"
	read -p "  Press [Enter] to exit.."
	exit
    fi
}


get_terminal() {
    terms_before=$(ls /dev/pt*)
    xterm &
    xterm_id=$(echo $!)
    sleep 1
    terms_after=$(ls /dev/pt*)
    new_term=$(diff <(echo "$terms_before") <(echo "$terms_after") | awk '{if ($1==">") print $2}')
    if [ -z "$(uname -a | grep Cygwin)" ]; then
	new_term="/dev/pts/"$new_term
    fi
}


check_amb_cache() {
    cache_opts=$(head -n 2 $1 | tail -n 1 | awk '{for (i=2;i<=NF;i++) print $i}')
    run_opts=$(less $2)
    ab_cache=$(echo $cache_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-ab") {print $(i+1)}}}')
    ab_run=$(echo $run_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-ab") {print $(i+1)}}}')
    aa_cache=$(echo $cache_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-aa") {print $(i+1)}}}')
    aa_run=$(echo $run_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-aa") {print $(i+1)}}}')
    ad_cache=$(echo $cache_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-ad") {print $(i+1)}}}')
    ad_run=$(echo $run_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-ad") {print $(i+1)}}}')
    as_cache=$(echo $cache_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-as") {print $(i+1)}}}')
    as_run=$(echo $run_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-as") {print $(i+1)}}}')
    ar_cache=$(echo $cache_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-ar") {print $(i+1)}}}')
    ar_run=$(echo $run_opts | awk '{for (i=1;i<=NF;i++) {if ($i == "-ar") {print $(i+1)}}}')
    if [ "$ab_run" != "$ab_cache" -o "$aa_run" != "$aa_cache" -o "$ad_run" != "$ad_cache" -o "$as_run" != "$as_cache" -o "$ar_run" != "$ar_cache" ]; then
	amb_cache=false
    else
	amb_cache=true
    fi
}


get_dates() {
    header_selector 8 $1
    echo -e -n "  Please indicate the day of the year (DD/MM);\n  if you want several days, please separate them with spaces:\n\n  "
    read dates
    number_dates=$(echo $dates | awk '{print NF}')
    
    corrected_date=""
    for date in $(echo $dates); do
	day=$(echo $date | awk -F/ '{print $1}')
	month=$(echo $date | awk -F/ '{print $2}')
	let "day=10#$day"
	let "month=10#$month"
	while [[ "$month" -gt 12 || "$day" -gt 31 ]]; do
	    header_selector 8 $1
	    echo -e -n "  The date "$day"/"$month" is not valid.\n"
	    echo -e -n "  Please indicate a valid day of the year for that date (DD/MM):\n\n  "
	    read date
	    day=$(echo $date | awk -F/ '{print $1}')
	    month=$(echo $date | awk -F/ '{print $2}')
	    let "day=10#$day"
	    let "month=10#$month"
	done
	corrected_date=$(echo $corrected_date $day"/"$month)
    done
}

get_hours() {
    hours=""
    for day in $corrected_date;do
	hour=25
	while [[ "$hour" -gt 24 ]]; do
	    header_selector 9 $1
	    echo -e -n "  Please indicate the hour of the day (0-24) for \033[00;33m"$(echo $corrected_date | awk -v d=$day '{print d}')"\033[00m:\n\n  "
	    read hour
	    let "hour=10#$hour"
	done
	hours=$(echo $hours $hour)
    done
}

get_skyconds() {
    sky_conds=""
    for day in $corrected_date;do
	sky_cond=""
	
	while [ "$sky_cond" != "+s" -a "$sky_cond" != "-s" -a "$sky_cond" != "+i" -a "$sky_cond" != "-i" -a "$sky_cond" != "-c" ]; do
	    header_selector 3 $1
	    echo -e -n  "  Please indicate what type of sky you want for \033[00;33m"$(echo $corrected_date | awk -v d=$day '{print d}')"\033[00m:\n  Sunny sky with sun\t\t-->\t+s\n  Sunny sky without sun\t\t-->\t-s\n  Intermediate sky with sun\t-->\t+i\n  Intermediate sky without sun\t-->\t-i\n  Cloudy sky\t\t\t-->\t-c\n\n\n  "
	    read sky_cond
	done
	sky_conds=$(echo $sky_conds $sky_cond)
    done
}


get_overcast_options() {
    header_selector 8 $3
    echo -e -n "  Do you want to calculate the brightness of the design sky based on the\n  \033[1mweather file\033[0m (alternatively RADIANCE will calculate it based\n  on latitude) [y/n]? \n\n  "  
    read calc_bright
    echo -e "\t\tSky brightness calculated: "$calc_bright"." >> $logfile
    
    if [ "$calc_bright" == "y" -o "$calc_bright" == "Y" ]; then
	header_selector 9 $3
	echo -e -n "  Calculating Design Sky...\n\n"  
	design_illum=$(echo $1 $2 | designsky.py)
    fi
}




