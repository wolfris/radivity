#!/bin/bash

. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/progbar.sh
. $RADIVSCRIPTS/funcs/functions_udi.sh

runtime_initial=$(date +"%s")

path_to_module=$PWD"/modules/da/udi"
root_path=$(echo $PWD)
lib_path=$HOME/bin/radivity/lib
logfile=$1
fullusername=$2

echo -e "******************\nUDI:\n******************" >> $logfile

if [ ! -d $path_to_module ];then
    mkdir -p $path_to_module
fi
if [ ! -d $path_to_module/tmp ];then
    mkdir $path_to_module/tmp
else
    rm -fr $path_to_module/tmp/*
fi
mkdir $path_to_module/tmp/dc

if [ ! -d $path_to_module/octrees ];then
    mkdir $path_to_module/octrees
else
    rm -f $path_to_module/octrees/*
fi
if [ ! -d $path_to_module/climate ];then
    mkdir $path_to_module/climate
else
    rm -fr $path_to_module/climate/*
fi
if [ ! -d $path_to_module/images ];then
    mkdir $path_to_module/images
fi
if [ ! -d $path_to_module/out ];then
    mkdir $path_to_module/out
fi
if [ ! -d $path_to_module/coefficients ];then
    mkdir $path_to_module/coefficients
fi
if [ ! -d $path_to_module/config ];then
    mkdir $path_to_module/config
else
    rm -f $path_to_module/config/*
fi

if [ ! -z "$3" ]; then
    case $3 in
	-e)
	    expert_mode=true
	    echo "expert mode";;
	-i)	    
	    coeffs=$(echo $4)
	    existing_coeffs=$(echo $5)
	    thresholds=$(echo $6 $7 $8)
	    resol=$(echo $9)
	    sched_file=$(echo ${10})
	    palette=$(echo ${11})
	    echo $coeffs $existing_coeffs $thresholds $resol $sched_file $palette
    esac
fi


falsecolorFile=$lib_path"/udi_falsecolor.cfg"
custom_falsecolorFile=$path_to_module"/config/falsecolor.cfg"


## SET CLIMATE FOR UDI
get_climate udi
sun_ind=$base_climate"_sun_indices.dat"
sun_mod=$base_climate"_sun_modifiers.dat"
sun_rep=$base_climate"_representative_suns.rad"
climate_updated=$base_climate"_upd.dat"
city=$(basename $climate_file)
city=${city%.dat}

## NAMES OF THE LOCAL AMBENT PARAMETER FILE
custom_ambientParamsFile_sun=$path_to_module"/config/ambient_params_sun.cfg"
custom_ambientParamsFile_sky=$path_to_module"/config/ambient_params_sky.cfg"


if [  -z "$3" ]; then
    
    
    grad="false"
    palette="-mono_r"
    echo -e "\tColour palette: "$palette >> $logfile
    echo $palette | paste $falsecolorFile - > $custom_falsecolorFile
    falsecolorFile=$custom_falsecolorFile
    
    ## DEFAULT RESOLUTION FOR RENDERING OF COEFFICIENT IMAGES
    resol=512

    ## CHECK IF THERE IS A COEFFICIENT FILE
    check_coeffs

    ## GET THE UDI THRESHOLDS
    get_thresholds_udi
    
    ## CHECK IF THERE ARE COEFFICIENT IMAGES
    check_coeff_images
    
    ## GET RESOLUTION FOR RENDERING OF COEFFICIENT IMAGES AND GET AMBIENT PARAMETERS
    get_resolution
    if [[ "$resol" > 0 ]]; then
	ambientParamsFile_sun=$lib_path"/udi_sun_ambient_params.cfg"
	ambientParamsFile_sky=$lib_path"/udi_sky_ambient_params.cfg"
    else
	ambientParamsFile_sun=$lib_path"/udi_sun_ambient_params_grid.cfg"
	ambientParamsFile_sky=$lib_path"/udi_sky_ambient_params_grid.cfg"
    fi
    if [ "$coeffs" == "y" -o "$coeffs" == "Y"  ]; then
	get_amb_cfg_options $ambientParamsFile_sun $custom_ambientParamsFile_sun udi sun $logfile
	ambientParamsFile_sun=$custom_ambientParamsFile_sun
	get_amb_cfg_options $ambientParamsFile_sky $custom_ambientParamsFile_sky udi sky $logfile
	ambientParamsFile_sky=$custom_ambientParamsFile_sky
    fi
else
    if [ "$3" == "-i" ]; then
	mv $root_path/tmp/*.cfg $path_to_module/config
    else
	if $expert_mode; then
	    grad="false"
	    # GET FALSECOLOR OPTIONS (IN THE CASE OF UDI DIVISIONS AND PALETTE)
	    palette="mono_r"
	    get_falsecolor_cfg_options $falsecolorFile $custom_falsecolorFile udi
	    echo -e "\tFalsecolor image options are: "$(less $custom_falsecolorFile | awk '{print NF}') $(less $custom_falsecolorFile) >> $logfile
	    falsecolorFile=$custom_falsecolorFile

	    ## DEFAULT RESOLUTION FOR RENDERING OF COEFFICIENT IMAGES
	    resol=512
	    
	    ## CHECK IF THERE IS A COEFFICIENT FILE
	    check_coeffs
	    
	    ## GET THE UDI THRESHOLDS
	    get_thresholds_udi
	    
	    ## CHECK IF THERE ARE COEFFICIENT IMAGES
	    check_coeff_images
	    
	    ## GET RESOLUTION FOR RENDERING OF COEFFICIENT IMAGES AND GET AMBIENT PARAMETERS
	    get_resolution
	    if [[ "$resol" > 0 ]]; then
		ambientParamsFile_sun=$lib_path"/udi_sun_ambient_params.cfg"
		ambientParamsFile_sky=$lib_path"/udi_sky_ambient_params.cfg"
	    else
		ambientParamsFile_sun=$lib_path"/udi_sun_ambient_params_grid.cfg"
		ambientParamsFile_sky=$lib_path"/udi_sky_ambient_params_grid.cfg"
	    fi
	    if [ "$coeffs" == "y" -o "$coeffs" == "Y"  ]; then
		get_amb_cfg_options $ambientParamsFile_sun $custom_ambientParamsFile_sun udi sun $logfile
		ambientParamsFile_sun=$custom_ambientParamsFile_sun
		get_amb_cfg_options $ambientParamsFile_sky $custom_ambientParamsFile_sky udi sky $logfile
		ambientParamsFile_sky=$custom_ambientParamsFile_sky
	    fi
	fi	
    fi
fi

## GET DETAILS OF SCENE LOCATION
location_line=`head -n 1 $climate_file`
a=`echo $location_line | awk '{print $1}'`
o=`echo $location_line | awk '{print $2}'`
m=`echo $location_line | awk '{print $3}'`


if [ "$existing_coeffs" == "y" -o "$existing_coeffs" == "Y" ]; then
    if [ -z "$3" ]; then
	schedule_for_coeffs
    fi
    w="-w "$sched_file
    geninput=$(echo -a $a -o $o -m $m $w)
    echo -e "\tArguments for genrepresentativesuns: "$geninput >> $logfile
    $RADIVBINS/genrepresentativesuns $geninput > $path_to_module/tmp/suns
    echo $base_climate $path_to_module | $RADIVSCRIPTS/gen_sundat.py
else
    rm -f $path_to_module/out/*
    if [ "$3" == "-e" ]; then
	schedule="n"
	set_schedule udi
    fi
    echo $climate_file $sched_file | $RADIVSCRIPTS/update_climatefile.py &> $climate_updated
    climate_file=$climate_updated
    w="-w "$sched_file
    headerUDI
    echo -e "\n\n\n\n\n\n\n\n\n"
    echo "  Generating representative suns for "$city
    
    geninput=$(echo -a $a -o $o -m $m $w)
    echo -e "\tArguments for genrepresentativesuns: "$geninput >> $logfile
    $RADIVBINS/genrepresentativesuns $geninput > $path_to_module/tmp/suns
    echo $base_climate $path_to_module | $RADIVSCRIPTS/gen_sundat.py
    headerUDI
    echo -e "\n\n\n  Generating Sky and Sun coefficients (in parallel).... "
    echo -e "\tGenerating Sky and Sun coefficients (in parallel).... " >> $logfile
    echo " "
    echo -e -n "  This could take some time, please have a coffee and relax... \n\n\n\n\n  "
    $RADIVSCRIPTS/calc_sky_coeffs.sh $climate_file $path_to_module &> $path_to_module/tmp/calc_sky_coeff.log  &
    $RADIVSCRIPTS/calc_sun_coeffs.sh $climate_file $sun_ind $sun_mod $path_to_module &> $path_to_module/tmp/calc_sun_coeffs.log &
    sleep 1
    prog_bar $climate_file $path_to_module/tmp/calc_sky_coeff.log 1
    wait
    echo -e "\t\tErrors and details can be found here: "$path_to_module"/tmp/calc_sky_coeff.log\n\t\tand " $path_to_module"/tmp/calc_sun_coeff.log\n" >> $logfile 
    fix_errors_coeffs
fi

if [ "$coeffs" == "y" -o "$coeffs" == "Y"  ]; then
    rm -f $path_to_module/coefficients/*
    headerUDI
    echo -e "\n\n\n\n\n  Generating Sky and Sun coefficients images (in parallel). This could "
    echo -e -n "  again take some time, maybe you can do some other work in the meantime...\n\n\n\n  "
    echo -e "\tGenerating Sky and Sun coefficients images" >> $logfile
    $RADIVSCRIPTS/calc_sky_dc_coeffs.sh $path_to_module $root_path $resol $ambientParamsFile_sky &> $path_to_module/tmp/calc_sky_dc_coeffs.log &
    $RADIVSCRIPTS/calc_sun_dc_coeffs.sh $sun_mod $sun_rep $path_to_module $root_path $resol $ambientParamsFile_sun &> $path_to_module/tmp/calc_sun_dc_coeffs.log &
    spinner $!
    wait
    echo -e "\t\tErrors and details can be found here: "$path_to_module"/tmp" >> $logfile
fi

headerUDI
echo -e "\n\n\n\n\n\n  Calculating the UDI images. This will take some time...\n\n\n\n  "
echo -e "\tCalculating the UDI images.\n" >> $logfile
$RADIVSCRIPTS/calc_udi.sh $path_to_module/out/all_coefficients $root_path $path_to_module $resol $thresholds &> $path_to_module/tmp/calc_udi.log &
spinner $!
wait
echo -e "\t\tErrors and details can be found here: "$path_to_module"/tmp\n" >> $logfile


#time_run=$(echo $(date) | sed -e 's/, /_/g;s/ /_/g;s/:/-/g')
time_run=$(date +%F_%H-%M-%S)

headerUDI
echo -e "\n\n\n\n\n\n  Creating UDI images...\n\n\n\n  "
echo -e "\tCreating UDI images." >> $logfile
if [[ "$resol" > 0 ]]; then
    outd=$root_path/out/"udi_images_"$time_run
    mkdir $outd
    $RADIVSCRIPTS/get_images.sh $path_to_module $root_path $resol $lines $falsecolorFile $grad $outd &> $path_to_module/tmp/get_udi_percentages.log &
else
    outd=$root_path/out/"udi_grid_images_"$time_run
    mkdir $outd
    $RADIVSCRIPTS/get_grid_images.sh udi $path_to_module $root_path $lines $outd &> $path_to_module/tmp/get_udi_percentages.log &
fi
spinner $!
wait
echo -e "\t\tErrors and details can be found here: "$path_to_module"/tmp/get_udi_percentages.log\n" >> $logfile

runtime_final=$(date +"%s")
runtime_diff=$(($runtime_final-$runtime_initial))
echo -e "\n\n\tUDI took $(($runtime_diff / 60)) minutes and $((runtime_diff % 60)) seconds to run." >> $logfile


num_out_files=$(ls $outd | wc | awk '{print $1}')
size_out_folder=$(du $outd | awk '{print $1}')

ave_outfile_size=$(echo $size_out_folder $num_out_files | awk '{print $1/$2}')

echo -e "\tOutput folder: "$outd".\n" >> $logfile
if $(echo $ave_outfile_size | awk '{if ($1 > 10) {print "true"} else {print "false"}}'); then 
    echo -e "\tUDI successfully finished!\n" >> $logfile
else
    echo -e "\tUDI finished with errors!\n" >> $logfile
    echo -e "\n\n\n"
    headerUDI
    echo -e "\n\n  ******************************************************************"
    echo -e -n "  *\n  * \033[00;31mUDI finished with errors!\033[00m\n  * Please check log files\n  * (located in "$path_to_module"/tmp).\n  *\n  *"
    echo -e "*****************************************************************\n"
    echo -e "  Press [Enter] to exit.."
    read -p ""
fi
exit
