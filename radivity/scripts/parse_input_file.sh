#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_radivity.sh

function header {
echo "  *****************************************************************************"
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

echo -e "\n\n"
header
echo -e "\n\n\n  Parsing the input file...\n"

shift_list(){
    if [ "$2" == "params" ]; then
	params=$(echo $1 $params | awk '{for(i=$1+2;i<=NF;i++) {print $i" "}}')
    elif [ "$2" == "options" ]; then
	options=$(echo $1 $options | awk '{for(i=$1+2;i<=NF;i++) {print $i" "}}')
    fi
}

lib_path=$HOME/bin/radivity/lib

parse_da() {
    module_2=$(echo $params | awk '{print $1}')
    shift_list 1 params
    case "$module_2" in
	1) echo "Sub Module: Daylight Factor"
#	    parse_df
	    ;;
	2) echo "Sub Module: Illuminance"
#	    parse_illum
	    ;;
	3) echo "Sub Module: UDI"
	    parse_udi
	    ;;
	*) echo "Corrupt input file"
	    sleep 15
	    exit
	    ;;
    esac    
}


parse_udi() {
    palette=$(echo $params | awk '{print $1}')
    shift_list 1 params
    existing_coeffs=$(echo $params | awk '{print $1}')
    shift_list 1 params
    thresholds=$(echo $params | awk '{print $1" "$2" "$3}')
    shift_list 3 params
    coeffs=$(echo $params | awk '{print $1}')
    shift_list 1 params
    resolution=$(echo $params | awk '{print $1}')
    resol=$(echo $resolution | awk -F'x' '{print $1}')
    shift_list 1 params
    amb_params_sun=$(echo $params | awk '{for(i=2;i<2+$1;i++) {print $i" "}}')
    echo $amb_params_sun > $PWD/tmp/ambient_params_sun.cfg
    shift_list $(echo $params | awk '{print $1+1}') params
    amb_params_sky=$(echo $params | awk '{for(i=2;i<2+$1;i++) {print $i" "}}')
    echo $amb_params_sky > $PWD/tmp/ambient_params_sky.cfg
    shift_list $(echo $params | awk '{print $1+1}') params
    sched_file=$(echo $params | awk '{print $1}')
    shift_list 2 params
    udi.sh $rad_logfile $USER -i $coeffs $existing_coeffs $thresholds $resol $sched_file $palette
}

parse_irrad() {


    options=$(echo $params | awk '{for(i=2;i<2+$1;i++) {print $i" "}}')
    shift_list $(echo $params | awk '{print $1+1}') params
    do_sky=true
    run_simulation=true
    create_octrees=true
    generate_filters=true
    filter_sky=true
    insolation_hours=false
    reuse_cache=false
    do_overture=true

   
    while true;
    do
	case $(printf "%s " $options | awk '{print $1}') in
	    -a)
		do_sky=false
		shift_list 1 options;;
	    -b)
		run_simulation=false
		shift_list 1 options;;
	    -c)
#		check_octrees $path_to_module/octrees/
		create_octrees=false
		shift_list 1 options;;
	    -d)
		do_overture=false
		shift_list 1 options;;
	    -e)
#		check_octrees $path_to_module/octrees/
		do_sky=false
		run_simulation=false
		create_octrees=false
		shift_list 1 options;;
	    -f)
		generate_filters=false
		shift_list 1 options;;
	    -g)
		insolation_hours=true
		shift_list 1 options;;
	    -h)
		reuse_cache=true
		shift_list 1 options;;
	    -C)
		climate_file_irrad=$(echo $(echo $options | awk '{print $2}') | sed 's/[-a-zA-Z0-9]*=//')
		shift_list 2 options;;
	    -w)
		root_path=$(echo $options | awk '{print $2}')
		shift_list 2 options;;
	    -m)
		path_to_module=$(echo $options | awk '{print $2}')
		shift_list 2 options;;
	    -l)
		logfile=$2
		shift_list 2 options;;
	    *)
		break;;
	esac
    done

    sky_rotation_file=$path_to_module/config/sky_rotation.cfg
    falsecolorFile=$path_to_module/config/falsecolor_params_irrad.cfg
    ambientParamsFile=$path_to_module/config/ambient_params_irrad.cfg
    imageSizeFile=$path_to_module/config/size.cfg

    time_run=$(echo $(date) | sed -e 's/, /_/g;s/ /_/g;s/:/-/g')
    outd=$root_path/out/"irrad_images_"$time_run
    mkdir $outd

    
    if [ ! -d $path_to_module ];then
	mkdir -p $path_to_module/tmp
    fi
    if [ ! -d $path_to_module/tmp ];then
	mkdir $path_to_module/tmp
    else
	rm -fr $path_to_module/tmp/*
    fi
    if [ ! -d $path_to_module/climate ];then
	mkdir $path_to_module/climate
    else
	rm -fr $path_to_module/climate/*
    fi
    if [ ! -d $path_to_module/rotated_sky ];then
	mkdir $path_to_module/rotated_sky
    fi
    if [ ! -d $path_to_module/config ];then
	mkdir $path_to_module/config
    fi
    if [ ! -d $path_to_module/octrees ];then
	mkdir $path_to_module/octrees
    fi
    if [ ! -d $path_to_module/out ];then
	mkdir $path_to_module/out
    fi

    get_climate irr
    
#    if $run_simulation; then
	amb_params=$(echo $params | awk '{for(i=2;i<2+$1;i++) {print $i" "}}')
	echo $amb_params > $ambientParamsFile
	shift_list $(echo $params | awk '{print $1+1}') params
#    fi

    falsecolor_params=$(echo $params | awk '{for(i=2;i<2+$1;i++) {printf $i" "}}')
    echo "$falsecolor_params" > $falsecolorFile
    shift_list $(echo $params | awk '{print $1+1}') params

    
#    if $run_simulation; then
	image_size=$(echo $params | awk '{print $1" "$2" "$3" "$4}')
	echo $image_size > $imageSizeFile
	shift_list 4 params
#    fi

    echo $params | awk '{for(i=2;i<2+$1;i++) {print $i}}' > $PWD/tmp/sky_rotation.cfg
    head -n 5 $lib_path/irrad_sky_rotations.cfg | cat - $PWD/tmp/sky_rotation.cfg > $sky_rotation_file
    shift_list $(echo $params | awk '{print $1+1}') params

    if $do_sky; then
	sched_file=$(echo $params | awk '{print $2}')
	
	echo -e "2" > $path_to_module/tmp/tmp_sched
	less $sched_file >> $path_to_module/tmp/tmp_sched
	less $climate_file | awk '{if ($4=="") {print $1"\t"$2"\t"$3} else {print $4"\t"$5}}' > $path_to_module/tmp/tmp_clim
	paste $path_to_module/tmp/tmp_sched $path_to_module/tmp/tmp_clim | awk '{if ($1=="1") print $2"\t"$3; else if($1=="2") print $2"\t"$3"\t"$4; else print "0\t0"}' > $climate_file_irrad
    fi

    echo -e "\n\n\n"
    headerIrrad
    echo -e "\n\n\n\n\n  Computing Irradiation Images...\n  A copy of the radiance record is kept at:\n  \033[00;33m"$path_to_module"/tmp/irrad_calcs.log\033[00m\n"
    get_terminal
    irrad_calcs.sh $root_path $sky_rotation_file $path_to_module $create_octrees $insolation_hours $lib_path $run_simulation $reuse_cache $falsecolorFile $ambientParamsFile $imageSizeFile $generate_filters $climate_file_irrad $do_sky &> >(tee $new_term) | tee $path_to_module"/tmp/irrad_calcs.log" > /dev/null
    kill $xterm_id

    cp $path_to_module/tmp/scale.bmp $outd
    mv $path_to_module/out/*.gif $outd

    
}



params=$(less $1 | awk -F': ' '{if ($2!="") print $2}' | awk -F'('  '{print $1}')
city=$(echo $params | awk '{print $1}')
shift_list 1 params
time_log=$(date +%F_%H-%M-%S)
rad_logfile=$PWD/log/$city"_"$time_log".bdsp"
echo -e "Input file used: "$PWD/$1 > $rad_logfile
city_climate_file=$(echo "$HOME"/.climate_lib/"$city".epw)
if [ -e "$city_climate_file" ]; then
    cp "$city_climate_file" $PWD/climate
    echo "City: "$city >> $rad_logfile
else
    echo -e "\n\n\n"
    headerq
    echo -e "\n\n  ******************************************************************"
    echo -e -n "  *\n  * There seems to be something wrong with the city specified\n  * in your input file.\n  * Please check...\n  *\n  *"
    echo -e "*****************************************************************\n\n\n"
    read -p "  Press [Enter] to exit.."
fi


module_1=$(echo $params | awk '{print $1}')
shift_list 1 params
case "$module_1" in
    1) echo "Module run: Irradiation Mapping"
	parse_irrad
	;;
    2) echo "Module run: Visualisation (Rendering)" ;;
    3) echo "Module run: Shadow Sequence" ;;
    4) echo "Module run: Right to Light" ;;
    5) echo "Module run: LEED IEQ 8.1 Credit" ;;
    6) echo "Module run: Daylight Availability"
	parse_da
	;;
    7) echo "Module run: Glare Analysis" ;;
    *) echo "Corrupt input file"
	sleep 15
	exit
	;;
esac

