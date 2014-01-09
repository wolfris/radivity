#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_da.sh

runtime_initial=$(date +"%s")

# SET PATHS
path_to_module=$PWD"/modules/da/illum"
root_path=$PWD
lib_path=$HOME/bin/radivity/lib
outd=$path_to_module/out
view_d=$root_path/views/parallel
scene_d=$root_path/scenes
filter_d=$root_path/filter/parallel
tmpd=$path_to_module/tmp
falsecolor_log=$tmpd/falsecolor.log

logfile=$1
fullusername=$2
epw_climate_file=$3
expert_mode=false

#  INPUT FILE MODE HAS NOT BEEN IMPLEMENTED FOR ILLUM ANALYISIS.
if [ ! -z $4 ]; then
    case $4 in
	-e)
	    expert_mode=true
	    echo "expert mode";;
	-i)
	    echo "input file mode";;
    esac
fi

time_run=$(date +%F_%H-%M-%S)

header_selector 9 illum

refinish="n"
# 'do_refinish' WILL CHECK IF NECESSARY FILES ARE PRESENT, AND IF SO SET THE 'refinish' VARIABLE TO 'y'.
do_refinish illum

if [ "$refinish" == "n" -o "$refinish" == "N"  ]; then
    # CREATE AND CLEAN UP WORKING DIRECTORIES.
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
    
    # SET OPTIONS FOR THE ILLUM ANALYSIS.    
    illum_options

    # CREATE OUTPUT FILES.
    echo -e "Date,Level,Facade,Room" > $outd/analysis_1.out
    echo -e "Illum_ave,Illum_min_over_ave,%_"$lower"-"$upper",%_>"$upper",%_<"$lower > $outd/analysis_2.out
fi

for i in $(eval echo {1.."$number_dates"});do
    month=$(echo $corrected_date | awk -v date=$i '{print $date}' | awk -F/ '{print $2}')
    day=$(echo $corrected_date | awk -v date=$i '{print $date}' | awk -F/ '{print $1}')
    if [ "$refinish" == "n" -o "$refinish" == "N"  ]; then
	hour=$(echo $hours | awk -v date=$i '{print $date}')
	sky_cond=$(echo $sky_conds | awk -v date=$i '{print $date}')
	# GENERATE THE SKY FOR SELECTED LOCATION (BRIGHTNESS CAN BE CALCULATED USING STATISTICAL ANALYSIS, OR DIRECTLY BY RADIANCE)
	if [ "$sky_cond" == "-c" -a -n "$design_illum" ]; then
     	    brightness=$(echo $design_illum | awk '{print $1/179}')
     	    echo -e "\tThe calculated brightness of the sky is "$brightness" [W/m2]" >> $logfile
     	    gensky $month $day $hour $sky_cond -a $a -o $o -m $m -B $brightness > $path_to_module"/tmp/this_sky_"$day"_"$month".rad"
	else
     	    gensky $month $day $hour $sky_cond -a $a -o $o -m $m > $path_to_module"/tmp/this_sky_"$day"_"$month".rad"
	fi
    fi
    
    for scene in $(ls $scene_d/*.rad 2> /dev/null); do
	scenename=$(basename $scene .rad)
	casename=$(basename $scene .rad)"_"$day"_"$month
	if [ "$refinish" == "n" -o "$refinish" == "N"  ]; then
	    header_selector 9 illum
	    echo -e -n  "  Creating octree for scene '"$scenename"', please wait...\n\n  "
	    oconv $path_to_module"/tmp/this_sky_"$day"_"$month".rad" $lib_path/sky_source.rad $scene > $path_to_module/octrees/$casename.oct 2> $tmpd/oconv_$casename.log
	fi
	if $use_views; then
	    for view in $(ls $view_d/*.vf); do
		viewname=$(basename $view .vf)
		image_prefix=$casename"_"$viewname
		if [ "$refinish" == "n" -o "$refinish" == "N"  ]; then
		    parallel_view=$tmpd/$(basename $view .vf)_parallel.vf
		    # MAKE SURE THE VIEW IS PARALLEL:
		    sed -e 's/vtv/vtl/g' $view > $parallel_view
		    header_selector 9 illum
		    echo -e -n  "  Computing scene '"$scenename"' with view '"$viewname"' for "$day"/"$month" at "$hour", please wait...\n\n  "
    		    oconv $filter_d/$viewname"_filter".rad > $path_to_module/octrees/$viewname"_filter".oct
		    rpict -t 10 -w -vf $parallel_view -av 1 1 1 -ab 0 -x $resol -y $resol $path_to_module/octrees/$viewname"_filter".oct | pfilt > $outd/$viewname"_filter".pic
		    vwrays -fa -x $resol -y $resol -vf $parallel_view | rcalc -e '$1=$1;$2=$2;$3=$3;$4=$4;$5=$5;$6=1' \
			| rtrace `vwrays -d -x $resol -y $resol -vf $parallel_view` -fac @$option_file $path_to_module/octrees/$casename.oct \
			| pvalue -d -h >    $outd/$image_prefix"_vals"
		    tail -n +2 $outd/$image_prefix"_vals" | rcalc -e '$1=179*(.265*$1+.67*$2+.065*$3);$2=179*(.265*$1+.67*$2+.065*$3);$3=179*(.265*$1+.67*$2+.065*$3)' \
		    > $outd/$image_prefix"_illum_vals"
		    echo $(head -n 1 $outd/$image_prefix"_vals") | cat - $outd/$image_prefix"_illum_vals" | pvalue -r -h -d > $outd/$image_prefix".pic"
		fi
		header_selector 9 illum
		echo -e -n  "  Finishing image for '"$scenename"' with view '"$viewname"' for "$day"/"$month" at "$hour", please wait..\n\n  "
		oconv -w | rpict -x 1 -y 1 -ab 0  | falsecolor_bdsp.py $(cat $falsecolorFile) | ra_tiff - $outd/scale.tif
		falsecolor_bdsp.py $(cat $falsecolorFile) -lw 0 -i $outd/$image_prefix".pic"  > $tmpd/$image_prefix"_falsecolor.pic" 2>> $falsecolor_log
		pcomb -e 'ro=if(ri(2),ri(1),ri(2));go=if(gi(2),gi(1),gi(2));bo=if(bi(2),bi(1),bi(2))' $tmpd/$image_prefix"_falsecolor.pic" $outd/$viewname"_filter".pic \
		    > $outd/$image_prefix"_comb.pic"
		pcomb -e 'ro=if(ri(2),if(ri(1)-'$upper',0.0,1.0),ri(2));bo=if(bi(2),0.0,bi(2));go=if(gi(2),if(gi(1)-'$lower',1.0,0.0),gi(2))' $outd/$image_prefix".pic" \
		    $outd/$viewname"_filter".pic > $outd/$image_prefix"_traffic_light.pic" 2> $tmpd/traffic
		ra_tiff $outd/$image_prefix"_comb.pic" $outd/$image_prefix"_Illum.tif"
		ra_tiff $outd/$image_prefix"_traffic_light.pic" $outd/$image_prefix"_Illum_traffic_light.tif"
		get_percentages_da $outd/$viewname"_filter".pic $outd/$image_prefix"_illum_vals" $lower $upper	
		text1=$(echo $viewname | awk -F_ '{print $1}')
		text2=$(echo $viewname | awk -F_ '{print $2}')
		echo $day/$month, $text1, $scenename, $text2 >> $outd/analysis_1.out
		echo $ave_da, $min_over_ave, $perc_1, $perc_2, $perc_3 >> $outd/analysis_2.out
	    done
	else    
	    for grid in $(ls $root_path/grids/*.pts); do
		gridname=$(basename $grid .pts)
		image_prefix=$casename"_"$gridname
		echo -e "\n\n"
		headerIllum 
		echo -e "\n\n\n\n\n\n\n\n "
		echo -e -n  "  Computing scene '"$scenename"' with grid '"$gridname"' for "$day"/"$month", please wait...\n\n  "
		rtrace @$option_file -af $tmpd/amb/$casename.amb $path_to_module/octrees/$casename.oct < $grid  2> $tmpd/rtrace_$image_prefix.log \
		    | tee $outd/imp_ecotect_$image_prefix.dat | rcalc -e '$1=179*(.265*$1+.67*$2+.065*$3)'> $outd/$image_prefix.out
		cut -f 1 -d ' ' $grid > $tmpd/$gridname"_x" 
		cut -f 2 -d ' ' $grid > $tmpd/$gridname"_y"
		# JOINING X- AND Y-COORDINATES WITH RESULTS:
		paste $tmpd/$gridname"_x" $tmpd/$gridname"_y" $outd/$image_prefix.out > $tmpd/$image_prefix.plot
		# CREATING THE INPUT FILE FOR GNUPLOT (AND CALCULATING PERCENTAGES):
		percents=$(echo $tmpd/$image_prefix.plot $tmpd/tmp.plot illum $lower $upper | transgrid.py)
		echo $percents >> $outd/analysis_2.out
		sep_percents=$(echo $percents | sed -e 's/,/ /g')
		text1=$(echo $gridname | awk -F_ '{print $1}')
		text2=$(echo $gridname | awk -F_ '{print $2}')
		echo $day/$month, $text1, $scenename, $text2 >> $outd/analysis_1.out
		if [ "$prod_images" == "y" -o "$prod_images" == "Y" ]; then
		    # SETTING INPUT PARAMETERS FOR GNUPLOT (IN ORDER TO MAKE A 'NICE' IMAGE):
		    min_x=$(cat $grid | awk '{print $1}' | sort -n -u | head -n 1)
		    max_x=$(cat $grid | awk '{print $1}' | sort -n -u | tail -n 1)
		    min_y=$(cat $grid | awk '{print $2}' | sort -n -u | head -n 1)
		    max_y=$(cat $grid | awk '{print $2}' | sort -n -u | tail -n 1)
		    range_x=$(echo $max_x $min_x | awk '{print $1-$2}')
		    range_y=$(echo $max_y $min_y | awk '{print $1-$2}')
		    canvas_x=$(echo $range_y $range_x | awk '{print (1250*$2/$1)+650}')
		    c_rat=$(echo $canvas_x 650 | awk '{print $1/($1+$2)}')
		    l_off=$(echo $c_rat 1.2 | awk '{if ($1<0.77) {print $2+(0.77-$1)} else {print $2}}')
		    plot_var=$(echo $tmpd/tmp.plot $outd/$image_prefix.plot | tognuplot.py)
		    if $(echo $canvas_x | awk '{if ($1>1050) {print "true"} else {print "false"}}'); then
			plot_illum.sh $outd"/Illum_"$image_prefix $outd/$image_prefix.plot $lower $incr $upper $sep_percents $canvas_x $c_rat $l_off
			plot_illum_ns.sh $outd"/Illum_"$image_prefix"_ns" $outd/$image_prefix.plot $lower $incr $upper $sep_percents $canvas_x $c_rat $l_off
		    else
			plot_illum.sh $outd"/Illum_"$image_prefix $outd/$image_prefix.plot $lower $incr $upper $sep_percents 1150 0.7 1.2
			plot_illum_ns.sh $outd"/Illum_"$image_prefix"_ns" $outd/$image_prefix.plot $lower $incr $upper $sep_percents 1150 0.7 1.2
		    fi
		fi
	    done
	fi
    done
done


paste -d , $outd/analysis_1.out $outd/analysis_2.out > $outd/analysis.csv
rm -f $outd/analysis_*.out
cp $outd/analysis.csv $root_path/out/analysis_Illum_$time_run.csv
if [ "$prod_images" == "y" -o "$prod_images" == "Y" ]; then
    mkdir -p $root_path/out/Illum_images_$time_run
    cp $outd/*.png $root_path/out/Illum_images_$time_run/
elif $use_views; then
    mkdir -p $root_path/out/Illum_images_$time_run/renderings
    cp $outd/*.tif $root_path/out/Illum_images_$time_run/
    cp $outd/*.pic $root_path/out/Illum_images_$time_run/renderings
    cp $outd/*_vals $root_path/out/Illum_images_$time_run/renderings
fi

ecotect_dir=$root_path/out/Illum_ecotect_import_$time_run
mkdir $ecotect_dir

for file in $(ls $outd/imp_ecotect*); do
    cp $file $ecotect_dir/$(basename $file .dat)".dat"
done

runtime_final=$(date +"%s")
runtime_diff=$(($runtime_final-$runtime_initial))
echo -e "\n\n\tThe Illuminance analysis took $(($runtime_diff / 60)) minutes and $((runtime_diff % 60)) seconds to run." >> $logfile

echo -e "\tThe Illuminance analysis successfully finished!\n" >> $logfile
