#!/bin/bash

. $HOME/.bash_rad.inc
shopt -s expand_aliases



get_thresholds_da() {
    header_selector 7 $1
    case $1 in
	df)
	    echo -e "  Please indicate two thresholds for DF analysis  (default thresholds "
	    echo -e "  are 1.0 and 1.5). Enter the two numbers separated by space"
	    ;;
	illum)
	    echo -e "  Please indicate two thresholds for Illuminance  (default thresholds "
	    echo -e "  are 300 and 1000). Enter the two numbers separated by space"
	    ;;
    esac
    echo -e -n "  before pressing Enter.\n\n  "
    read thresholds
    if [ -z $threshold ];then
	case $1 in
	    df)
		lower=1.0
		upper=1.5
		;;
	    illum)
		lower=300.
		upper=1000.
		;;
	esac
    else
	lower=$(echo $thresholds | awk '{print $1}')
	upper=$(echo $thresholds | awk '{print $2}')
	rest=$(echo $thresholds | awk '{print $3}')
	
	counter=0
	while [[ ! -z "$rest" || "$lower" -gt "$upper" ]]; do
	    if [ $counter == 3 ]; then
		echo -e "\n\n  $fullusername!! You don't seem to take this seriously! This script will now exit!\n\n"
		sleep 3
		exit
	    fi
	    if [[ ! -z "$rest" ]]; then
		header_selector 9 $1
		echo -e -n "  Please enter only two values!\n\n  "
	    elif [[ "$lower" -gt "upper" ]]; then
		header_selector 9 $1
		echo -e -n "  The thresholds have to be in ascending order. Please enter two values.\n\n  "
	    fi
	    read thresholds
	    lower=$(echo $thresholds | awk '{print $1}')
	    upper=$(echo $thresholds | awk '{print $2}')
	    rest=$(echo $thresholds | awk '{print $3}')
	    let counter=counter+1
	done
    fi
}


illum_options(){
    
    get_climate illum
    
    design_illum=""
    
    location_line=$(head -n 1 $climate_file)
    a=$(echo $location_line | awk '{print $1}')
    o=$(echo $location_line | awk '{print $2}')
    m=$(echo $location_line | awk '{print $3}')
    
    get_dates illum
    get_hours illum
    
    echo -e "\tThe analysis is run for "$corrected_date" at "$hours" hours (respectively)." >> $logfile
    
    get_skyconds illum
    
    echo -e "\tSky condition used (for the respective date): "$sky_conds"." >> $logfile
    
    for sky_cond in $sky_conds;do
	if [ "$sky_cond" == "-c" ]; then
	    echo "checking "$sky_cond
	    get_overcast_options $root_path"/climate/"$epw_climate_file 100 illum
	    break
	fi
    done
    
    
    get_thresholds_da illum
    
    if [[ -z "$threshold1" || -z "$threshold2" ]]; then
	threshold1=300
	threshold2=1000
    fi
    
    echo -e "\tThe analysis is run with the following thresholds: "$threshold1" and "$threshold2"." >> $logfile
    
    incr=$(echo $threshold2 $threshold1 | awk '{print $1-$2}')
    
    
    option_file=$tmpd/custom.opt
    ambparams_file=$tmpd/amb_custom.cfg
    get_accuracy illum
    if [ "$accuracy" == "high" ]; then
	cp $lib_path/df_amb_high.cfg $ambparams_file
    elif  [ "$accuracy" == "low" ]; then
	cp $lib_path/df_amb_low.cfg $ambparams_file
    elif  [ "$accuracy" == "custom" ]; then
	get_amb_cfg_options $lib_path/df_amb_low.cfg $ambparams_file illum $logfile
    fi
    
    echo "-h -w -I+" | paste -d ' ' - $ambparams_file > $option_file
    
    echo -e "\tLevel of accuracy: "$accuracy"." >> $logfile
    echo -e "\t\t radiance options: "$(cat $option_file)"." >> $logfile
    
    use_views=false
    if [ ! -z "$(ls $root_path/grids/*.pts 2> /dev/null)" ]; then
	header_selector 9 illum
	echo -e -n  "  Do you want to produce images [y/n]?\n\n  "
	read prod_images
	echo -e "\tProduce GNUplot images: "$prod_images"." >> $logfile
    elif [ -z "$(ls $view_d/*.vf 2> /dev/null)" -o -z "$(ls $filter_d/*.rad 2> /dev/null)" ]; then
	header_selector 9 illum
	echo -e "\tInput files are missing." >> $logfile	
	echo -e "  \033[00;31mInput files are missing!\033[00m\n  You need to specify either a view (with filter) or a grid.\n"
	sleep 5
	ls $filter_d/*.vf 2> /dev/null > /dev/null
	if [ "$?" -gt 0 ]; then
	    print_error_message
	fi
	ls $view_d/*.vf 2> /dev/null > /dev/null
	if [ "$?" -gt 0 ]; then
	    print_error_message
	fi
	exit
    else
	use_views=true
	header_selector 9 illum
	echo -e -n  "  Please enter the resolution for the images to be rendered:\n\n  "
	read resol_in
	resol=$(echo $resol_in | awk '{print $1}')
	falsecolorFile=$lib_path"/illum_falsecolor.cfg"
	custom_falsecolorFile=$path_to_module"/tmp/falsecolor.cfg"
	palette=mono_r
	get_falsecolor_cfg_options $falsecolorFile $custom_falsecolorFile illum
	echo -e "\tFalsecolor image options are: "$(less $custom_falsecolorFile | awk '{print NF}') $(less $custom_falsecolorFile) >> $logfile
	falsecolorFile=$custom_falsecolorFile
	echo "-I+" | paste -d ' ' - $ambparams_file > $option_file
    fi
}


df_options(){
    

    get_climate df
    
    location_line=$(head -n 1 $climate_file)
    a=$(echo $location_line | awk '{print $1}')
    o=$(echo $location_line | awk '{print $2}')
    m=$(echo $location_line | awk '{print $3}')
    
    day=21
    month=6
    hour=12.
    
    lower=1
    upper=1.5
    if $expert_mode; then
	get_thresholds_da df
    fi
    incr=$(echo $upper $lower | awk '{print $1-$2}')

	
    option_file=$path_to_module/tmp/custom.opt
    ambparams_file=$path_to_module/tmp/amb_custom.cfg
    get_accuracy df
    if [ "$accuracy" == "high" ]; then
	cp $lib_path/df_amb_high.cfg $ambparams_file
    elif  [ "$accuracy" == "low" ]; then
	cp $lib_path/df_amb_low.cfg $ambparams_file
    elif  [ "$accuracy" == "custom" ]; then
	get_amb_cfg_options $lib_path/df_amb_low.cfg $ambparams_file df $logfile
    fi
    
    echo "-h -w -I+" | paste -d ' ' - $ambparams_file > $option_file
    
    echo -e "\tLevel of accuracy: "$accuracy"." >> $logfile
    echo -e "\t\t radiance options: "$(cat $option_file)"." >> $logfile
    
    use_views=false
    prod_images=n
    if [ ! -z "$(ls $root_path/grids/*.pts 2> /dev/null)" ]; then
	header_selector 9 df
	echo -e -n  "  Do you want to produce GNUplot images [y/n]?\n\n  "
	read prod_images
	echo -e "\tProduce GNUplot images: "$prod_images"." >> $logfile
    elif [ -z "$(ls $view_d/*.vf 2> /dev/null)" -o -z "$(ls $filter_d/*.rad 2> /dev/null)" ]; then
	echo -e "\tInput files are missing." >> $logfile	
	header_selector 9 df
	echo -e "  \033[00;31mInput files are missing!\033[00m\n  You need to specify either a view (with filter) or a grid.\n"
	sleep 5
	ls $filter_d/*.vf 2> /dev/null > /dev/null
	if [ "$?" -gt 0 ]; then
	    print_error_message
	fi
	ls $view_d/*.vf 2> /dev/null > /dev/null
	if [ "$?" -gt 0 ]; then
	    print_error_message
	fi
	exit
    else
	use_views=true
	header_selector 9 df
	echo -e -n  "  Please enter the resolution for the images to be rendered:\n\n  "
	read resol_in
	resol=$(echo $resol_in | awk '{print $1}')
	falsecolorFile=$lib_path"/df_falsecolor.cfg"
	custom_falsecolorFile=$path_to_module"/tmp/falsecolor.cfg"
	palette=mono_r
	get_falsecolor_cfg_options $falsecolorFile $custom_falsecolorFile df
	falsecolorFile=$custom_falsecolorFile
	echo -e "\tFalsecolor image options are: "$(less $custom_falsecolorFile | awk '{print NF}') $(less $custom_falsecolorFile) >> $logfile
	echo "-I+" | paste -d ' ' - $ambparams_file > $option_file
    fi
    
}

get_percentages_da(){

    filterpic=$1
    da_vals=$2
    low=$3
    up=$4
    value_occurence=$tmpd/$image_prefix"_value_occurence"
    perc_log=$tmpd/perc.log
    
    pvalue -h $filterpic | tail -n +2 | paste $da_vals - | awk '{if($6!=0.00 && $7!=0.00 && $8!=0.00) print $1}' | sort -n | uniq -c > $value_occurence
    total_occ=$(less $value_occurence | awk '{s+=$1} END {print s}') 2>> $perc_log
    sum_da=$(less $value_occurence | awk '{s+=$1*$2} END {print s}') 2>> $perc_log
    ave_da=$(echo $sum_da $total_occ | awk '{print $1/$2}') 2>> $perc_log
    min_da=$(less $value_occurence | awk 'BEGIN {s=1e9} {if(s>$2) {s=$2}} END {print s}') 2>> $perc_log
    min_over_ave=$(echo $min_da $ave_da | awk '{print $1/$2}') 2>> $perc_log
    occ1=$(less $value_occurence | awk -v lo="$low" '{if($2<lo) print $1}' | awk '{s+=$1} END {print s}')
    if [ -z $occ1 ]; then occ1=0; fi
    perc_1=$(echo $occ1 $total_occ | awk '{print 100*$1/$2}') 2>> $perc_log
    occ2=$(less $value_occurence | awk -v u="$up" '{if($2>u) print $1}' | awk '{s+=$1} END {print s}')
    if [ -z $occ2 ]; then occ2=0; fi
    perc_2=$(echo $occ2 $total_occ | awk '{print 100*$1/$2}') 2>> $perc_log
    occ3=$(less $value_occurence | awk -v lo="$low" -v u="$up" '{if($2>lo && $2<u) print $1}' | awk '{s+=$1} END {print s}')
    if [ -z $occ3 ]; then occ3=0; fi
    perc_3=$(echo $occ3 $total_occ | awk '{print 100*$1/$2}') 2>> $perc_log
}



do_refinish(){

    for scene in $(ls $scene_d/*.rad 2> /dev/null); do
	casename=$(basename $scene .rad)
	for view in $(ls $view_d/*.vf); do
	    viewname=$(basename $view .vf)
	    image_prefix=$casename"*"$viewname
	    rad_picture=$outd/$image_prefix".pic"
	    filter_picture=$outd/$viewname"_filter.pic"
	    rad_values=$outd/$image_prefix"_vals"
	    rad_da_values=$outd/$image_prefix"_"$1"_vals"
	    exist_rad_picture=$(echo $rad_picture | grep '\*')
	    exist_filter_picture=$(echo $filter_picture | grep '\*')
	    exist_rad_values=$(echo $rad_values | grep '\*')
	    exist_rad_da_values=$(echo $rad_da_values | grep '\*')
	    if [ -z "$exist_rad_picture" ] && [ -z "$exist_filter_picture" ] && [ -z "$exist_rad_values" ] && [ -z "$exist_rad_da_values" ];then
	     	header_selector 9 $1
	     	echo -e -n  "  Images exist, do you want to refinish? [y/n]:\n\n  "
	     	read refinish
	     	break 2
	    fi
	done
    done

    

    if [ "$refinish" == "y" -o "$refinish" == "Y"  ]; then
	expert_mode=true
	palette=mono_r
	get_thresholds_da $1
	falsecolorFile=$lib_path"/"$1"_falsecolor.cfg"
	custom_falsecolorFile=$path_to_module"/tmp/falsecolor.cfg"
	get_falsecolor_cfg_options $falsecolorFile $custom_falsecolorFile $1
	falsecolorFile=$custom_falsecolorFile
	echo -e "\tFalsecolor image options are: "$(less $custom_falsecolorFile | awk '{print NF}') $(less $custom_falsecolorFile) >> $logfile
	palette=mono_r
	ask_palette $1
	corrected_date=""
	for scene in $(ls $scene_d/*.rad 2> /dev/null); do
	    casename=$(basename $scene .rad)
	    for view in $(ls $view_d/*.vf); do
		viewname=$(basename $view .vf)
		image_prefix=$casename"*"$viewname
		rad_picture=$outd/$image_prefix".pic"
		number_dates=$(echo $rad_picture | awk '{print NF}')
		for picture in $(echo $rad_picture);do
		    day_rf=$(echo $(basename $picture .pic) | sed 's/'$casename'//g' | sed 's/'$viewname'//g' | awk -F_ '{print $2}')
		    month_rf=$(echo $(basename $picture .pic) | sed 's/'$casename'//g' | sed 's/'$viewname'//g' | awk -F_ '{print $3}')
		    corrected_date="${corrected_date} $day_rf/$month_rf"
		done
		break 2
	    done
	done
    fi

}

