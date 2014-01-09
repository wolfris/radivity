#!/bin/bash 

. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_irrad.sh
. $RADIVSCRIPTS/funcs/progbar.sh


lib_path=$HOME/bin/radivity/lib




PARSED_OPTIONS=$(getopt -n "$0"  -o abcdefghC:w:m:l:x: --long "no_climate,no_images,no_octrees,no_overture,refinish,reuse_filters,insolation_hours,reuse_cache,climate:,root:,module:,log:,expert:"  -- "$@")

eval set -- "$PARSED_OPTIONS"

do_sky=true
run_simulation=true
create_octrees=true
generate_filters=true
filter_sky=true
insolation_hours=false
reuse_cache=false
do_overture=true
climate_file=""

while true;
do
    case $1 in
	-a|--no_climate)
	    do_sky=false
	    shift;;
	-b|--no_images)
	    run_simulation=false
	    shift;;
	-c|--no_octrees)
	    check_octrees $path_to_module/octrees/
	    create_octrees=false
	    shift;;
	-d|--no_overture)
	    do_overture=false
	    shift;;
	-e|--refinish)
	    check_octrees $path_to_module/octrees/
	    do_sky=false
	    run_simulation=false
	    create_octrees=false
	    shift;;
	-f|--reuse_filters)
	    generate_filters=false
	    shift;;
	-g|--insolation_hours)
	    insolation_hours=true
	    shift;;
	-h|--reuse_cache)
	    reuse_cache=true
	    shift;;
	-C|--climate)
	    climate_file=`echo $2 | sed 's/[-a-zA-Z0-9]*=//'`
	    shift 2;;
	-w|--root)
	    root_path=$2
	    shift 2;;
	-m|--module)
	    path_to_module=$2
	    shift 2;;
	-l|--log)
	    logfile=$2
	    shift 2;;
	-x|--expert)
	    expert_mode=$2
	    shift 2;;
	--)
		shift
		break;;
		
	esac
done


#    Mapping configuration files

ambientParamsFile=$lib_path"/irrad_ambient_params.cfg"
custom_ambientParamsFile=$path_to_module"/config/ambient_params.cfg"
imageSizeFile=$lib_path"/image_size.cfg"
custom_imageSizeFile=$path_to_module"/config/size.cfg"
sky_rotation_file=$lib_path"/irrad_sky_rotations.cfg"
custom_sky_rotation_file=$path_to_module"/config/sky_rotation.cfg"
falsecolorFile=$lib_path"/irrad_falsecolor.cfg"
custom_falsecolorFile=$path_to_module"/config/falsecolor.cfg"
custom_falsecolorFileTmp=$root_path"/tmp/falsecolor.cfg"

echo "expert mode: "$expert_mode


if $run_simulation; then
    if $reuse_cache; then
	cat $custom_ambientParamsFile > $root_path"/tmp/amb_tmp"
	get_amb_cfg_options $root_path"/tmp/amb_tmp" $custom_ambientParamsFile irr used $logfile
	ambientParamsFile=$custom_ambientParamsFile
    else
	get_amb_cfg_options $ambientParamsFile $custom_ambientParamsFile irr default $logfile
	ambientParamsFile=$custom_ambientParamsFile
    fi
else
    if [ -e "$custom_ambientParamsFile" ]; then
	ambientParamsFile=$custom_ambientParamsFile
	echo -e "\tThe ambient parameters used for the original run are: " $(less $ambientParamsFile | awk '{print NF}')" "$(less $ambientParamsFile)" (all others default)" \
	    >> $logfile
    else
	echo -e "\tUsing default parameters, because there was no configuration file present."
	echo -e "\tThe ambient parameters used for the original run are: " $(less $ambientParamsFile | awk '{print NF}')" "$(less $ambientParamsFile)" (all others default)" \
	    >> $logfile
    fi
fi

palette="spec"

get_falsecolor_cfg_options $falsecolorFile $custom_falsecolorFile irr
echo -e "\tFalsecolor image options are: "$(less $custom_falsecolorFile | awk '{print NF}') $(less $custom_falsecolorFile) >> $logfile

falsecolorFile=$custom_falsecolorFile


if $run_simulation; then
    if $expert_mode; then
	get_image_size_options $imageSizeFile $custom_imageSizeFile irr
	imageSizeFile=$custom_imageSizeFile
    else
	echo -e "\tImage size: "$(less $imageSizeFile) >> $logfile
    fi
    get_rotation_options $sky_rotation_file $custom_sky_rotation_file irr
    sky_rotation_file=$custom_sky_rotation_file
else
    if [ -e "$custom_imageSizeFile" ]; then
	imageSizeFile=$custom_imageSizeFile
	echo -e "\tImage size: "$(less $imageSizeFile) >> $logfile
    else
	echo -e "\tUsing default image size, because there was no configuration file present."
	echo -e "\tImage size: "$(less $imageSizeFile) >> $logfile
    fi
    if [ -e "$custom_sky_rotation_file" ]; then
	sky_rotation_file=$custom_sky_rotation_file
        echo -e "\tSky rotations: "$(tail $sky_rotation_file -n +6 | awk '{printf $1" "}'| awk '{print NF}') $(tail $sky_rotation_file -n +6 | awk '{printf $1" "}') >> $logfile

    else
	echo -e "\tUsing default rotation (0 degrees), because there was no rotation file in the module directory."
        echo -e "\tSky rotations: "$(tail $sky_rotation_file -n +6 | awk '{printf $1" "}'| awk '{print NF}') $(tail $sky_rotation_file -n +6 | awk '{printf $1" "}') >> $logfile
    fi
fi

if $do_sky; then
    set_schedule irr

    climate_file_base=$path_to_module"/climate/"$(basename $climate_file _irrad.dat)".dat"
    echo -e "2" > $path_to_module/tmp/tmp_sched
    less $sched_file >> $path_to_module/tmp/tmp_sched
    less $climate_file_base | awk '{if ($4=="") {print $1"\t"$2"\t"$3} else {print $4"\t"$5}}' > $path_to_module/tmp/tmp_clim
    paste $path_to_module/tmp/tmp_sched $path_to_module/tmp/tmp_clim | awk '{if ($1=="1") print $2"\t"$3; else if($1=="2") print $2"\t"$3"\t"$4; else print "0\t0"}' > $climate_file
fi


echo -e "\n\n\n"
headerIrrad
echo -e "\n\n\n\n\n  Computing Irradiation Images...\n  A copy of the radiance record is kept at:\n  \033[00;33m"$path_to_module"/tmp/irrad_calcs.log\033[00m\n"
get_terminal
irrad_calcs.sh $root_path $sky_rotation_file $path_to_module $create_octrees $insolation_hours $lib_path $run_simulation $reuse_cache $falsecolorFile $ambientParamsFile $imageSizeFile $generate_filters $climate_file $do_sky &> >(tee $new_term) | tee $path_to_module"/tmp/irrad_calcs.log" > /dev/null
kill $xterm_id
if [ "$(tail -n 1  $path_to_module/tmp/irrad_calcs.log)" -eq 666 ]; then
    exit 666
fi 2> /dev/null
