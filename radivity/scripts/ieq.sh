#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh


runtime_initial=$(date +"%s")


logfile=$1
fullusername=$2



path_to_module=$PWD"/modules/leed_ieq"
root_path=$PWD

lib_path=$HOME/bin/radivity/lib

#time_run=$(echo $(date) | sed -e 's/, /_/g;s/ /_/g;s/:/-/g')
time_run=$(date +%F_%H-%M-%S)

echo -e "\n\n"
headerIeq
echo -e "\n\n\n\n\n\n\n\n\n\n "

if [ ! -d $path_to_module ];then
    mkdir -p $path_to_module
fi
if [ ! -d $path_to_module/tmp ];then
    mkdir $path_to_module/tmp
else
    rm -fr $path_to_module/tmp/*
fi
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
view_d=$root_path/views/parallel
scene_d=$root_path/scenes
filter_d=$root_path/filter/parallel
tmp_d=$path_to_module/tmp

get_climate ieq

location_line=$(head -n 1 $climate_file)
a=$(echo $location_line | awk '{print $1}')
o=$(echo $location_line | awk '{print $2}')
m=$(echo $location_line | awk '{print $3}')

echo -e "\n\n"
headerIeq
echo -e "\n\n\n\n\n\n\n\n "
echo -e -n  "  Do you want high, low or costumized level of accuracy [high/low/custom]?\n\n  "
read accuracy

while [ "$accuracy" != "high" -a  "$accuracy" != "low" -a "$accuracy" != "custom" ]; do
	echo -e "\n\n"
	headerIllum 
	echo -e "\n\n\n\n\n\n\n\n "
	echo -e -n  "  Do you want high, low or costumized level of accuracy [high/low/custom]?\n\n  "
	read accuracy
done
echo -e "\tLevel of accuracy: "$accuracy"." >> $logfile

#get_accuracy ieq
if [ "$accuracy" == "high" ]; then
	option_file=$lib_path/ieq_high.opt
elif  [ "$accuracy" == "low" ]; then
	option_file=$lib_path/ieq_low.opt
elif  [ "$accuracy" == "custom" ]; then
#	get_amb_cfg_options $lib_path/df_amb_low.cfg $ambparams_file df $logfile
	create_options_df
	option_file=$tmp_d/df_custom.opt
fi

echo -e "Level,Facade,Room" > $tmp_d/analysis_1.out
echo -e "Percentage of area compliant with IEQ 8.1 at 9am, Percentage of area compliant with IEQ 8.1 at 3pm" > $tmp_d/analysis_2.out

sky_cond="+s"
palette="mono_r"
thresh_high=5400
thresh_low=108

exp1="ro=if(((ri(1)*0.265+gi(1)*0.670+bi(1)*0.065)*179)-"$thresh_low",(if(("$thresh_high"-((ri(1)*0.265+gi(1)*0.670+bi(1)*0.065)*179)),0,0.7)),0.7);go=if(((ri(1)*0.265+gi(1)*0.670+bi(1)*0.065)*179)-"$thresh_low",(if(("$thresh_high"-((ri(1)*0.265+gi(1)*0.670+bi(1)*0.065)*179)),0.7,0)),0);bo=if(((ri(1)*0.265+gi(1)*0.670+bi(1)*0.065)*179)-"$thresh_low",0.0000,0.00000)"


gensky 09 21 9 $sky_cond -a $a -o $o -m $m -B 55.8659 > $tmp_d/this_sky_9am.rad
gensky 09 21 15 $sky_cond -a $a -o $o -m $m -B 55.8659 > $tmp_d/this_sky_3pm.rad

for scene in $(ls $scene_d/*.rad); do
    casename=$(basename $scene .rad)
    oconv $tmp_d/this_sky_9am.rad $lib_path/sky_source.rad $scene > $path_to_module/octrees/$casename"_9am.oct" 2> $tmp_d/oconv_$casename"_9am.log"
    oconv $tmp_d/this_sky_3pm.rad $lib_path/sky_source.rad $scene > $path_to_module/octrees/$casename"_3pm.oct" 2> $tmp_d/oconv_$casename"_3pm.log"
    

    for grid in $(ls $root_path/grids/*.pts); do
	gridname=$(basename $grid .pts)
	echo -e "\n\n"
	headerIeq
	echo -e "\n\n\n\n\n\n\n "
	echo -e -n  "  Computing percentages for scene '"$casename"' \n  with grid '"$gridname"', please wait...\n\n  "
	rtrace -h @$option_file $path_to_module/octrees/$casename"_9am.oct" < $grid  2> $tmp_d/rtrace_$casename"_"$gridname"_9am.log" | \
	    rcalc -e '$1=179*(.265*$1+.67*$2+.065*$3)'> $tmp_d/$casename"_"$gridname"_val_9am"
	rtrace -h @$option_file $path_to_module/octrees/$casename"_3pm.oct" < $grid  2> $tmp_d/rtrace_$casename"_"$gridname"_3pm.log" | \
	    rcalc -e '$1=179*(.265*$1+.67*$2+.065*$3)'> $tmp_d/$casename"_"$gridname"_val_3pm"
	for line in $(less $tmp_d/$casename"_"$gridname"_val_9am"); do
	    echo $line $thresh_low $thresh_high | awk '{if ($1 > $2) if ($1 < $3) print 1}' >> $tmp_d/winrange_$casename"_"$gridname"_9am"
	done
	for line in $(less $tmp_d/$casename"_"$gridname"_val_3pm"); do
	    echo $line $thresh_low $thresh_high | awk '{if ($1 > $2) if ($1 < $3) print 1}' >> $tmp_d/winrange_$casename"_"$gridname"_3pm"
	done
	
	perc1=$(echo $(wc -l < $tmp_d/winrange_$casename"_"$gridname"_9am") $(wc -l < $tmp_d/$casename"_"$gridname"_val_9am") | awk '{print 100*$1/$2}')
	perc2=$(echo $(wc -l < $tmp_d/winrange_$casename"_"$gridname"_3pm") $(wc -l < $tmp_d/$casename"_"$gridname"_val_3pm") | awk '{print 100*$1/$2}')
	echo $perc1 "," $perc2 >> $tmp_d/analysis_2.out
	text1=$(echo $gridname | awk -F_ '{print $1}')
	text2=$(echo $gridname | awk -F_ '{print $2}')
	echo $text1, $casename, $text2 >> $tmp_d/analysis_1.out
    done

    for view in $(ls $view_d/*.vf); do
    	viewname=$(basename $view .vf)
	parallel_view=$tmp_d/$(basename $view .vf)_parallel.vf
	sed -e 's/vtv/vtl/g' $view > $parallel_view
	
    	oconv $filter_d/$viewname"_filter".rad > $path_to_module/octrees/$viewname"_filter".oct
    	rpict -t 2 -w -vf $parallel_view -av 1 1 1 -ab 0 -x 512 -y 512 $path_to_module/octrees/$viewname"_filter".oct | pfilt > $tmp_d/$viewname"_filter".pic
    	echo -e "\n\n"
    	headerIeq
    	echo -e "\n\n\n\n\n\n\n\n "
    	echo -e -n  "  Rendering scene '"$casename"' with view '"$viewname"', please wait...\n\n  "
    	vwrays -fa -x 512 -y 512 -vf $parallel_view | rcalc -e '$1=$1;$2=$2;$3=$3;$4=$4;$5=$5;$6=1' | \
	    rtrace @$option_file -fac $(vwrays -d -x 512 -y 512 -vf $parallel_view) $path_to_module/octrees/$casename"_9am.oct" \
	    2> $tmp_d/rtrace_$casename"_"$viewname"_9am.log" > $tmp_d/$casename"_"$viewname"_9am.pic"
    	vwrays -fa -x 512 -y 512 -vf $parallel_view | rcalc -e '$1=$1;$2=$2;$3=$3;$4=$4;$5=$5;$6=1' | \
	    rtrace @$option_file -fac $(vwrays -d -x 512 -y 512 -vf $parallel_view) $path_to_module/octrees/$casename"_3pm.oct" \
	    2> $tmp_d/rtrace_$casename"_"$viewname"_3pm.log" > $tmp_d/$casename"_"$viewname"_3pm.pic"
	
    	pcomb -e $exp1 $tmp_d/$casename"_"$viewname"_9am.pic" > $tmp_d/$casename"_"$viewname"_9am_threshold.pic"
    	pcomb -e $exp1 $tmp_d/$casename"_"$viewname"_3pm.pic" > $tmp_d/$casename"_"$viewname"_3pm_threshold.pic"

    	pcomb -e "ro=if(ri(2)-(1e-5),ri(1),0);go=if(gi(2)-(1e-5),gi(1),0);bo=if(bi(2)-(1e-5),bi(1),0)" $tmp_d/$casename"_"$viewname"_9am_threshold.pic" \
	    $tmp_d/$viewname"_filter".pic >  $path_to_module/out/$casename"_"$viewname"_9am.pic"
    	pcomb -e "ro=if(ri(2)-(1e-5),ri(1),0);go=if(gi(2)-(1e-5),gi(1),0);bo=if(bi(2)-(1e-5),bi(1),0)" $tmp_d/$casename"_"$viewname"_3pm_threshold.pic" \
	    $tmp_d/$viewname"_filter".pic >  $path_to_module/out/$casename"_"$viewname"_3pm.pic"

    	ra_tiff $path_to_module/out/$casename"_"$viewname"_9am.pic" $path_to_module/out/$casename"_"$viewname"_9am.tif"
    	ra_tiff $path_to_module/out/$casename"_"$viewname"_3pm.pic" $path_to_module/out/$casename"_"$viewname"_3pm.tif"
	
    done


done


paste -d , $tmp_d/analysis_1.out $tmp_d/analysis_2.out > $path_to_module/out/analysis.csv
cp $path_to_module/out/analysis.csv $root_path/out/analysis_LEED_IEQ_$time_run.csv
mkdir $root_path/out/LEED_images_$time_run
cp $path_to_module/out/*.tif $root_path/out/LEED_images_$time_run/

runtime_final=$(date +"%s")
runtime_diff=$(($runtime_final-$runtime_initial))
echo -e "\n\n\tLEED IEQ 8.1 analysis took $(($runtime_diff / 60)) minutes and $((runtime_diff % 60)) seconds to run." >> $logfile
