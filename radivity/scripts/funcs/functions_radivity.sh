#!/bin/bash

function headerUDI {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **                                                                         ** "
echo "  **                          _    _ _____ _____                             ** "
echo "  **                         | |  | |  __ \_   _|                            ** "
echo "  **                         | |  | | |  | || |                              ** "
echo "  **                         | |  | | |  | || |                              ** "
echo "  **                         | |__| | |__| || |_                             ** "
echo "  **                          \____/|_____/_____|                            ** "
echo "  **                                                                         ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}

function headerDF {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **                                                                         ** "
echo "  **                             _____  ______                               ** "
echo "  **                            |  __ \|  ____|                              ** "
echo "  **                            | |  | | |__                                 ** "
echo "  **                            | |  | |  __|                                ** "
echo "  **                            | |__| | |                                   ** "
echo "  **                            |_____/|_|                                   ** "
echo "  **                                                                         ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}

function headerIllum {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **                                                                         ** "
echo "  **       _____ _ _                 _                                       ** "
echo "  **      |_   _| | |               (_)                                      ** "
echo "  **        | | | | |_   _ _ __ ___  _ _ __   __ _ _ __   ___ ___            ** "
echo "  **        | | | | | | | | '_ \` _ \| | '_ \ / _\` | '_ \ / __/ _ \           ** "
echo "  **       _| |_| | | |_| | | | | | | | | | | (_| | | | | (_|  __/           ** "
echo "  **      |_____|_|_|\__,_|_| |_| |_|_|_| |_|\__,_|_| |_|\___\___|           ** "
echo "  **                                                                         ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}

function headerIeq {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **                                                                         ** "
echo "  **       _      ______ ______ _____    _____ ______ ____     ___  __       ** "
echo "  **      | |    |  ____|  ____|  __ \  |_   _|  ____/ __ \   / _ \/_ |      ** "
echo "  **      | |    | |__  | |__  | |  | |   | | | |__ | |  | | | (_) || |      ** "
echo "  **      | |    |  __| |  __| | |  | |   | | |  __|| |  | |  > _ < | |      ** "
echo "  **      | |____| |____| |____| |__| |  _| |_| |___| |__| | | (_) || |      ** "
echo "  **      |______|______|______|_____/  |_____|______\___\_\  \___(_)_|      ** "
echo "  **                                                                         ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}

function headerIrrad {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **            ___                 _ _      _   _                           ** "
echo "  **           |_ _|_ _ _ _ __ _ __| (_)__ _| |_(_)___ _ _                   ** "
echo "  **            | || '_| '_/ _\` / _\` | / _\` |  _| / _ \ ' \                  ** "
echo "  **           |___|_| |_| \__,_\__,_|_\__,_|\__|_\___/_||_|                 ** "
echo "  **                                                                         ** "
echo "  **                 __  __                _                                 ** "
echo "  **                |  \/  |__ _ _ __ _ __(_)_ _  __ _                       ** "
echo "  **                | |\/| / _\` | '_ \ '_ \ | ' \/ _\` |                      ** "
echo "  **                |_|  |_\__,_| .__/ .__/_|_||_\__, |                      ** "
echo "  **                            |_|  |_|         |___/                       ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}

function headerRender {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **             _____                _           _                          ** "
echo "  **            |  __ \              | |         (_)                         ** "
echo "  **            | |__) |___ _ __   __| | ___ _ __ _ _ __   __ _              ** "
echo "  **            |  _  // _ \ '_ \ / _\` |/ _ \ '__| | '_ \ / _\` |             ** "
echo "  **            | | \ \  __/ | | | (_| |  __/ |  | | | | | (_| |             ** "
echo "  **            |_|  \_\___|_| |_|\__,_|\___|_|  |_|_| |_|\__, |             ** "
echo "  **                                                       __/ |             ** "
echo "  **                                                      |___/              ** "
echo "  **                                                                         ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}

function headerShadow {
echo -e "\n\n\n\n\n\n\n\n\n"
echo -e "\n"
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
echo "  **                                                                         ** "
echo "  **                 _____ _               _                                 ** "
echo "  **                / ____| |             | |                                ** "
echo "  **               | (___ | |__   __ _  __| | _____      __                  ** "
echo "  **                \___ \| '_ \ / _\` |/ _\` |/ _ \ \ /\ / /                  ** "
echo "  **                ____) | | | | (_| | (_| | (_) \ V  V /                   ** "
echo "  **               |_____/|_| |_|\__,_|\__,_|\___/ \_/\_/                    ** "
echo "  **                                                                         ** "
echo "  ***************************************************************************** "
echo "  ***************************************************************************** "
}


function error_exit {
 echo "exiting because of error"
 echo 666
 exit 666
}
trap error_exit ERR


function schedule_select {
case $schedule in
	1) 
	sched_file="/cygdrive/e/dev/schedules/allyear"
	echo "" | awk '{for (i=1;i<=8760;i++) print 1 }' > $root_path/schedule/allyear 
	sched_file=$root_path/schedule/allyear
	;;
	2) 
	sched_file="/cygdrive/e/dev/schedule/hospital"
	;;
	3) 
	sched_file="/cygdrive/e/dev/schedule/seasons"
	echo -n "  Enter start and end date of season separated by space:  "
	read sched_dates
	echo -e "\tStart and End date of the season "$sched_dates >> $logfile
	echo -n "  Enter working hours separated by space (Example: 9 17):  "
	read sched_hours
	echo -e "\tWorking hours "$sched_hours >> $logfile
	create_season_schedule > $root_path/schedule/season
	sched_file=$root_path/schedule/season
	;;
	4)
	sched_file="/cygdrive/e/dev/schedule/userdefined"
	echo -n "  Do you want to eliminate weekends?  "
	read wknds
	echo -e "\tEliminate weekends? "$wknds >> $logfile
	echo -n "  Enter working hours separated by space (Example: 9 17):  "
	read wknghrs
	echo -e "\tWorking hours "$wknds >> $logfile
	set -- $wknghrs
	wrk_in=$1
	wrk_out=$2
	create_userdefined_schedule > $root_path/schedule/userdefined
	sched_file=$root_path/schedule/userdefined
	;;
esac
}

ESC=$'\e'
CSI=$ESC[

function spinner(){
    local pid=$1
    local delay=0.1
    local spinstr='\|/-'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}
printf "${CSI}?25l"

function create_userdefined_schedule() {
    counter=0
    for i in {1..365};do
	let counter+=1
	for j in {1..24};do
	    if [ "$wknds" == "y" -o "$wknds" == "Y" ]; then
		if [ "$counter" -lt 6 ]; then
		    if [ "$j" -ge "$wrk_in" -a "$j" -le "$wrk_out" ]; then
			echo "1"
		    else
			echo "0"
		    fi
		else
		    echo "0"
		fi
	    else
		if [ "$j" -ge "$wrk_in" -a "$j" -le "$wrk_out" ]; then
		    echo "1"
		else
		    echo "0"
		fi
	    fi
	done
	if [ "$counter" == 7 ]; then
	    counter=0
	fi
    done
}

function create_season_schedule() {
    day_begin=$(echo $sched_dates | awk '{print $1}' | awk -F/ '{print $1}')
    month_begin=$(echo $sched_dates | awk '{print $1}' | awk -F/ '{print $2}')
    day_end=$(echo $sched_dates | awk '{print $2}' | awk -F/ '{print $1}')
    month_end=$(echo $sched_dates | awk '{print $2}' | awk -F/ '{print $2}')
    hour_begin=$(echo $sched_hours | awk '{print $1}')
    hour_end=$(echo $sched_hours | awk '{print $2}')
    days_in_month=$(echo 31 28 31 30 31 30 31 31 30 31 30 31)
    month=0
    for days in $days_in_month; do
	let month=$month+1
	for day in $(eval echo {1.."$days"});do
	    for hour in {0..23};do
		if [ "$month" -eq "$month_begin" ];then
		    if [ "$month" -eq "$month_end" ];then
			if [ "$day" -ge "$day_begin" -a "$day" -le "$day_end" ];then
			    if [ "$hour" -ge "$hour_begin" -a "$hour" -le "$hour_end" ];then
				echo 1
			    else
				echo 0
			    fi
			else
			    echo 0
			fi
		    else
			if [ "$day" -ge "$day_begin" ];then
			    if [ "$hour" -ge "$hour_begin" -a "$hour" -le "$hour_end" ];then
				echo 1
			    else
				echo 0
			    fi
			else
			    echo 0
			fi
		    fi
		elif [ "$month" -eq "$month_end" ];then
		    if [ "$day" -le "$day_end" ];then
			if [ "$hour" -ge "$hour_begin" -a "$hour" -le "$hour_end" ];then
			    echo 1
			else
			    echo 0
			fi
		    else
			echo 0
		    fi      
		elif [ "$month" -gt "$month_begin" -a "$month" -lt "$month_end" ];then
		    if [ "$hour" -ge "$hour_begin" -a "$hour" -le "$hour_end" ];then
			echo 1
		    else
			echo 0
		    fi
		else
		    echo 0
		fi
	    done
	done
    done
}



function create_options_df {
    echo -e -n "-w -h -I+" > $path_to_module/tmp/df_custom.opt
    echo -e "\n\n"
    headerDF 
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n  "  Please enter number of bounces (-ab option)\n\n  "
    read bounces
    if [ ! -z "$bounces" ]; then echo -e -n " -ab "$bounces >> $path_to_module/tmp/df_custom.opt; fi
    echo -e "\n\n"
    headerDF 
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n  "  Please enter ambient accuracy (-aa option)\n\n  "
    read amb_acc
    if [ ! -z "$amb_acc" ]; then echo -e -n " -aa "$amb_acc >> $path_to_module/tmp/df_custom.opt; fi
    echo -e "\n\n"
    headerDF 
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n  "  Please enter number ambient divisions (-ad option)\n\n  "
    read amb_div
    if [ ! -z "$amb_div" ]; then echo -e -n " -ad "$amb_div >> $path_to_module/tmp/df_custom.opt; fi
    echo -e "\n\n"
    headerDF 
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n  "  Please enter number of ambient super-samples (-as option)\n\n  "
    read super_samp
    if [ ! -z "$super_samp" ]; then echo -e -n " -as "$super_samp >> $path_to_module/tmp/df_custom.opt; fi
    echo -e "\n\n"
    headerDF 
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n  "  Please enter ambient resolution (-ar option)\n\n  "
    read amb_res
    if [ ! -z "$amb_res" ]; then echo -e -n " -ar "$amb_res >> $path_to_module/tmp/df_custom.opt; fi
    echo -e "\n\n"
    headerDF 
    echo -e "\n\n\n\n\n\n\n\n "
    echo -e -n  "  Please enter any other options.\n  For this you need to include the rtrace option indicator. You may specify as many\n  additional options as you want.\n\n  "
    read other_options
    if [ ! -z "$other_options" ];then echo -e -n " "$other_options >> $path_to_module/tmp/df_custom.opt; fi
}
