#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_shadow.sh

runtime_initial=$(date +"%s")


path_to_module=$PWD"/modules/shadow"
root_path=$PWD

lib_path=$HOME/bin/radivity/lib

logfile=$1
fullusername=$2
epw_climate_file=$3


time_run=$(echo $(date) | sed -e 's/, /_/g;s/ /_/g;s/:/-/g')
time_run=$(date +%F_%H-%M-%S)
mkdir $root_path/out/ShadowSequence_images_$time_run

echo -e "\n\n"
headerShadow
echo -e "\n\n\n\n\n\n\n\n\n "

if [ ! -d $path_to_module ];then
    mkdir -p $path_to_module
fi
if [ ! -d $path_to_module/tmp ];then
    mkdir $path_to_module/tmp
else
    rm -fr $path_to_module/tmp/*
fi
mkdir $path_to_module/tmp/amb
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
if [ ! -d $path_to_module/out ];then
    mkdir $path_to_module/out
else
    rm -fr $path_to_module/out/*
fi
outd=$path_to_module/out
scene_d=$root_path/scenes
view_d=$root_path/views/perspective
filter_d=$root_path/filter/perspective

get_climate 

location_line=$(head -n 1 $climate_file)
a=$(echo $location_line | awk '{print $1}')
o=$(echo $location_line | awk '{print $2}')
m=$(echo $location_line | awk '{print $3}')

get_dates shadow
get_daylighthours
get_minutes

hour_stack=""
minute_stack=""
for hr in $(eval echo {$hour_init..$hour_final});do
    hour_stack="${hour_stack} $hr"
done
mnt="0"
intervals_m_one=$(echo $intervals | awk '{print $1-1}')
for i in $(eval echo {0..$intervals_m_one});do
    minute_stack="${minute_stack} $mnt"
    mnt=$(echo $mnt | awk -v intrvl=$intervals '{print int($1+(60/intrvl))}')
done

sky_cond="+s"

option_file=$path_to_module/tmp/custom.opt
ambparams_file=$path_to_module/tmp/amb_custom.cfg
get_accuracy shadow
if [ "$accuracy" == "high" ]; then
	cp $lib_path/render_amb_high.cfg $ambparams_file
elif  [ "$accuracy" == "low" ]; then
	cp $lib_path/render_amb_low.cfg $ambparams_file
elif  [ "$accuracy" == "custom" ]; then
    get_amb_cfg_options $lib_path/df_amb_low.cfg $ambparams_file render $logfile
fi

echo "-w -t 10 " | paste -d ' ' - $ambparams_file > $option_file
multiplier=179

echo -e "\tLevel of accuracy: "$accuracy"." >> $logfile
echo -e "\t\t radiance options: "$(cat $option_file)"." >> $logfile


imageSizeFile=$lib_path"/image_size_shadow.cfg"
custom_imageSizeFile=$path_to_module"/tmp/size.cfg"
get_image_size_options $imageSizeFile $custom_imageSizeFile shadow
imageSizeFile=$custom_imageSizeFile
falseclog=$path_to_module"/tmp/falsecolor.log"

for i in $(eval echo {1.."$number_dates"});do
    month=$(echo $corrected_date | awk -v date=$i '{print $date}' | awk -F/ '{print $2}')
    day=$(echo $corrected_date | awk -v date=$i '{print $date}' | awk -F/ '{print $1}')
    for hour in ${hour_stack[*]};do
	for minute in ${minute_stack[*]};do
	    time=$(echo $hour $minute | awk '{print $1":"$2}')
	    time_name=$(echo $hour $minute | awk '{print $1"_"$2}')
	    skyname=$path_to_module"/tmp/this_sky_"$day"_"$month"_"$time_name".rad"
	    skylog=$path_to_module"/tmp/sky_"$day"_"$month"_"$time_name".log"
     	    gensky $month $day +$time $sky_cond -a $a -o $o -m $m > $skyname 2> $skylog
	    brghtn_vl1=$(cat $skyname | grep -A2 'skybr' | tail -n 1 | awk '{print $3}')
	    brghtn_vl2=$(cat $skyname | grep -A2 'skybr' | tail -n 1 | awk '{print $4}')
	    if [ "$brghtn_vl1" != "0.00e+00" ] && [ "$brghtn_vl1" != "0.00e+00" ]; then
		for scene in $(ls $scene_d/*.rad); do
	    	    scenename=$(basename $scene .rad)
	    	    filter=$filter_d"/"$(basename $scene .rad)"_filter.rad"
	    	    casename=$(basename $scene .rad)"_"$day"_"$month"_at_"$time_name
	    	    octreename=$path_to_module/octrees/$casename.oct
	    	    octreefiltername=$path_to_module/octrees/$casename"_filter.oct"
	    	    oclog=$path_to_module/tmp/oconv_$casename.log
	    	    oconv $path_to_module"/tmp/this_sky_"$day"_"$month"_"$time_name".rad" $lib_path/sky_source.rad $scene > $octreename 2>> $oclog
	    	    if [ -e $filter ]; then
	    		oconv $path_to_module"/tmp/this_sky_"$day"_"$month".rad" $filter > $octreefiltername 2>> $oclog
	    	    fi
	    	    for view in $(ls $view_d/*.vf); do
	    		viewname=$(basename $view .vf)
	    		imagename=$outd/$casename"_"$viewname.pic
	    		bgimagename=$outd/$casename"_"$viewname"_bg.pic"
	    		finalimagename=$outd/$casename"_"$viewname"_final.pic"
	    		fcimagename=$outd/$casename"_"$viewname"_fc.pic"
	    		filterimagename=$outd/$casename"_"$viewname"_filter.pic"
	    		skyfilterimagename=$outd/$casename"_"$viewname"_skyfilter.pic"
	    		rpictlog=$path_to_module/tmp/rpict_$casename"_"$viewname.log
	    		rpictfilterlog=$path_to_module/tmp/rpict_$casename"_"$viewname"_filter.log"
	    		echo -e "\n\n"
	    		headerRender
	    		echo -e "\n\n\n\n\n\n "
	    		echo -e -n  "  Rendering scene '"$scenename"' with view '"$viewname"' for "$day"/"$month" at "$time" hours,\n  please wait...\n\n  "
	    		rpict @$option_file @$imageSizeFile -vf $view -af $path_to_module/tmp/amb/$casename.amb $path_to_module/octrees/$casename.oct 2> $rpictlog \
	    		    | pfilt -e 0.5 > $imagename
	    		falsecolor_bdsp.py -n 10 -m $multiplier -z -s 0.5e3 -lw 0 -ip $imagename -cb > $fcimagename 2>> $falseclog
	    		pfilt -h 1e10 $imagename > $bgimagename
	    		if [ -e $filter ]; then
	    	    	    rpict -w -vf $view @$option_file @$imageSizeFile -ab 0 -av 1 1 1 $octreefiltername > $filterimagename 2> $rpictfilterlog
	    	    	    rpict -w -vf $view @$option_file @$imageSizeFile -i+ -ab 0 -av 0 0 0 $octreefiltername > $skyfilterimagename 2>> $rpictfilterlog
	    	    	    pcomb -e 'ro=if(ri(4),1,if(ri(1),ri(2),ri(3)));go=if(gi(4),1,if(gi(1),gi(2),gi(3)));bo=if(bi(4),1,if(bi(1),bi(2),bi(3)))' \
	    	    		$filterimagename $fcimagename $bgimagename $skyfilterimagename  > $finalimagename
	    		else
	    	    	    less $imagename > $finalimagename
	    		fi
	    		ra_tiff $finalimagename $root_path/out/ShadowSequence_images_$time_run/$casename"_"$viewname.tif
	    	    done
		done
	    fi
	done
    done
done
exit
	
	
	
runtime_final=$(date +"%s")
runtime_diff=$(($runtime_final-$runtime_initial))
echo -e "\n\n\tThe rendering took $(($runtime_diff / 60)) minutes and $((runtime_diff % 60)) seconds to complete." >> $logfile

echo -e "\tThe rendering successfully finished!\n" >> $logfile
