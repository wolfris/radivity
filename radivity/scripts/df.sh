#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_da.sh

runtime_initial=$(date +"%s")

# SET PATHS
path_to_module=$PWD"/modules/da/df"
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
expert_mode=false


#  INPUT FILE MODE HAS NOT BEEN IMPLEMENTED FOR DF ANALYISIS.
if [ ! -z $3 ]; then
    case $3 in
	-e)
	    expert_mode=true
	    echo "expert mode";;
	-i)
	    echo "input file mode";;
    esac
fi

time_run=$(date +%F_%H-%M-%S)

header_selector 9 df

refinish="n"
# 'do_refinish' WILL CHECK IF NECESSARY FILES ARE PRESENT, AND IF SO SET THE 'refinish' VARIABLE TO 'y'.
do_refinish df

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

    
    # SET OPTIONS FOR THE DF ANALYSIS.
    df_options

    # CREATE OUTPUT FILES.
    echo -e "Level,Facade,Room" > $outd/analysis_1.out
    echo -e "DF_ave,DF_min_over_ave,%_"$lower"-"$upper",%_>"$upper",%_<"$lower > $outd/analysis_2.out

    # GENERATE THE SKY FOR SELECTED LOCATION (DATE AND HOUR ARE ARBITRARY NUMBERS, AS DF USES OVERCAST SKY)
    gensky $month $day $hour -c -a $a -o $o -m $m -B 55.8659 > $path_to_module/tmp/this_sky.rad 2> $tmpd/gensky.log
fi
    
for scene in $(ls $scene_d/*.rad 2> /dev/null); do
    casename=$(basename $scene .rad)
    if [ "$refinish" == "n" -o "$refinish" == "N"  ]; then
	header_selector 9 df
	echo -e -n  "  Creating octree for scene '"$casename"', please wait...\n\n  "
	oconv $path_to_module/tmp/this_sky.rad $lib_path/sky_source.rad $scene > $path_to_module/octrees/$casename.oct 2> $path_to_module/tmp/oconv_$casename.log
    fi
    if $use_views; then
	for view in $(ls $view_d/*.vf); do
	    viewname=$(basename $view .vf)
	    image_prefix=$casename"_"$viewname
	    if [ "$refinish" == "n" -o "$refinish" == "N"  ]; then
		parallel_view=$tmpd/$(basename $view .vf)_parallel.vf
		# MAKE SURE THE VIEW IS PARALLEL:
		sed -e 's/vtv/vtl/g' $view > $parallel_view
		header_selector 9 df
		echo -e -n  "  Computing scene '"$casename"' with view '"$viewname"', please wait...\n\n  "
		oconv $filter_d/$viewname"_filter".rad > $path_to_module/octrees/$viewname"_filter".oct
		rpict -t 10 -w -vf $parallel_view -av 1 1 1 -ab 0 -x $resol -y $resol $path_to_module/octrees/$viewname"_filter".oct \
		    | pfilt > $outd/$viewname"_filter".pic 2> $tmpd/rpict.log
		vwrays -fa -x $resol -y $resol -vf $parallel_view | rcalc -e '$1=$1;$2=$2;$3=$3;$4=$4;$5=$5;$6=1'| rtrace `vwrays -d -x $resol -y $resol -vf $parallel_view` -fac \
		    @$option_file  $path_to_module/octrees/$casename.oct | pvalue -d -h >    $outd/$image_prefix"_vals"
		tail -n +2 $outd/$image_prefix"_vals" | rcalc -e \
		    '$1=17900*(.265*$1+.67*$2+.065*$3)/10000;$2=17900*(.265*$1+.67*$2+.065*$3)/10000;$3=17900*(.265*$1+.67*$2+.065*$3)/10000' > $outd/$image_prefix"_df_vals"
		echo $(head -n 1 $outd/$image_prefix"_vals") | cat - $outd/$image_prefix"_df_vals" | pvalue -r -h -d > $outd/$image_prefix".pic"
	    fi
	    header_selector 9 df
	    echo -e -n  "  Finishing image for '"$casename"' with view '"$viewname"', please wait...\n\n  "
	    oconv -w | rpict -x 1 -y 1 -ab 0  | falsecolor_bdsp.py $(cat $falsecolorFile) | ra_tiff - $outd/scale.tif
	    falsecolor_bdsp.py $(cat $falsecolorFile) -lw 0 -i $outd/$image_prefix".pic" > $outd/$image_prefix"_falsecolor.pic" 2>> $falsecolor_log
	    pcomb -e 'ro=if(ri(2),ri(1),ri(2));go=if(gi(2),gi(1),gi(2));bo=if(bi(2),bi(1),bi(2))' $outd/$image_prefix"_falsecolor.pic" $outd/$viewname"_filter".pic \
		> $outd/$image_prefix"_comb.pic"
	    pcomb -e 'ro=if(ri(2),if(ri(1)-'$upper',0.0,1.0),ri(2));bo=if(bi(2),0.0,bi(2));go=if(gi(2),if(gi(1)-'$lower',1.0,0.0),gi(2))' $outd/$image_prefix".pic" \
		$outd/$viewname"_filter".pic 	> $outd/$image_prefix"_traffic_light.pic" 2> $tmpd/pcomb.log
	    ra_tiff $outd/$image_prefix"_comb.pic" $outd/$image_prefix"_DF.tif"
	    ra_tiff $outd/$image_prefix"_traffic_light.pic" $outd/$image_prefix"_DF_traffic_light.tif"
	    get_percentages_da $outd/$viewname"_filter".pic $outd/$image_prefix"_df_vals" $lower $upper
	    text1=$(echo $viewname | awk -F_ '{print $1}')
	    text2=$(echo $viewname | awk -F_ '{print $2}')
	    echo $text1, $casename, $text2 >> $outd/analysis_1.out
	    echo $ave_da, $min_over_ave, $perc_1, $perc_2, $perc_3 >> $outd/analysis_2.out
	done
    else
	for grid in $(ls $root_path/grids/*.pts); do
	    gridname=$(basename $grid .pts)
	    header_selector 9 df
	    echo -e -n  "  Computing scene '"$casename"' with grid '"$gridname"', please wait...\n\n  "
	    rtrace @$option_file $path_to_module/octrees/$casename.oct < $grid  2> $path_to_module/tmp/rtrace_$casename"_"$gridname.log \
		| tee $outd/imp_ecotect_$casename"_"$gridname.dat | rcalc -e '$1=17900*(.265*$1+.67*$2+.065*$3)/10000'> $outd/$casename"_"$gridname.out
	    cut -f 1 -d ' ' $grid > $path_to_module/tmp/$gridname"_x" 
	    cut -f 2 -d ' ' $grid > $path_to_module/tmp/$gridname"_y"
	    # JOINING X- AND Y-COORDINATES WITH RESULTS:
	    paste $path_to_module/tmp/$gridname"_x" $path_to_module/tmp/$gridname"_y" $outd/$casename"_"$gridname.out > $path_to_module/tmp/$casename"_"$gridname.plot
	    # CREATING THE INPUT FILE FOR GNUPLOT (AND CALCULATING PERCENTAGES):
	    percents=$(echo $path_to_module/tmp/$casename"_"$gridname.plot $path_to_module/tmp/tmp.plot df $lower $upper | transgrid.py)
	    echo $percents >> $outd/analysis_2.out
	    sep_percents=$(echo $percents | sed -e 's/,/ /g')
	    text1=$(echo $gridname | awk -F_ '{print $1}')
	    text2=$(echo $gridname | awk -F_ '{print $2}')
	    echo $text1, $casename, $text2 >> $outd/analysis_1.out
	    if [ "$prod_images" == "y" -o "$prod_images" == "Y" ]; then
		# SETTING INPUT PARAMETERS FOR GNUPLOT (IN ORDER TO MAKE A 'NICE' IMAGE):
		min_x=$(cat $grid | awk '{print $1}' | sort -n -u | head -n 1)
		max_x=$(cat $grid | awk '{print $1}' | sort -n -u | tail -n 1)
		min_y=$(cat $grid | awk '{print $2}' | sort -n -u | head -n 1)
		max_y=$(cat $grid | awk '{print $2}' | sort -n -u | tail -n 1)
		range_x=$(echo $max_x $min_x | awk '{print $1-$2}')
		range_y=$(echo $max_y $min_y | awk '{print $1-$2}')
		canvas_x=$(echo $range_y $range_x | awk '{print (1250*$2/$1)+500}')
		c_rat=$(echo $canvas_x 500 | awk '{print $1/($1+$2)}')
		plot_var=$(echo $path_to_module/tmp/tmp.plot $outd/$casename"_"$gridname.plot | tognuplot.py)
		less $outd/$casename"_"$gridname.plot | awk -v lo="$lower" -v \
		    up="$upper" '{if($1!="") {if($3<=lo) {print $1"\t"$2"\t0.0"} else if($3>lo && $3<=up) {print $1"\t"$2"\t0.5"} else {print $1"\t"$2"\t1.0"}} else {print ""}}' \
		    > $outd/$casename"_"$gridname"_traffic.plot"
		if $(echo $canvas_x | awk '{if ($1>1500) {print "true"} else {print "false"}}'); then
		    plot_df.sh $outd/"DF_"$casename"_"$gridname $outd/$casename"_"$gridname.plot $lower $incr $upper $sep_percents $canvas_x $c_rat 2>> $tmpd/gnuplot1.log
		    plot_df_ns.sh $outd/"DF_"$casename"_"$gridname"_ns" $outd/$casename"_"$gridname.plot $lower $incr $upper $sep_percents $canvas_x $c_rat 2>> $tmpd/gnuplot1.log
		    plot_df_yas.sh $outd/"DF_"$casename"_"$gridname"_yas" $outd/$casename"_"$gridname.plot $lower $incr $upper $sep_percents $canvas_x $c_rat 2>> $tmpd/gnuplot1.log
		    plot_df_traffic.sh $outd/"DF_"$casename"_"$gridname"_traffic" $outd/$casename"_"$gridname"_traffic.plot" $lower $incr $upper $sep_percents $canvas_x $c_rat 2>>\
			$tmpd/gnuplot1.log
		else
		    plot_df.sh $outd/"DF_"$casename"_"$gridname $outd/$casename"_"$gridname.plot $lower $incr $upper $sep_percents 1500 0.667 2>> $tmpd/gnuplot.log
		    plot_df_ns.sh $outd/"DF_"$casename"_"$gridname"_ns" $outd/$casename"_"$gridname.plot $lower $incr $upper $sep_percents 1500 0.667 2>> $tmpd/gnuplot.log
		    plot_df_yas.sh $outd/"DF_"$casename"_"$gridname"_yas" $outd/$casename"_"$gridname.plot $lower $incr $upper $sep_percents 1500 0.667 2>> $tmpd/gnuplot.log
		    plot_df_traffic.sh $outd/"DF_"$casename"_"$gridname"_traffic" $outd/$casename"_"$gridname"_traffic.plot" $lower $incr $upper $sep_percents 1500 0.667 \
			2>> $tmpd/gnuplot.log
		fi
	    fi
	done
    fi
done


paste -d , $outd/analysis_1.out $outd/analysis_2.out > $outd/analysis.csv
rm -f $outd/analysis_*.out
cp $outd/analysis.csv $root_path/out/analysis_DF_$time_run.csv
if [ "$prod_images" == "y" -o "$prod_images" == "Y" ]; then
    mkdir -p $root_path/out/DF_images_$time_run
    cp $outd/*.png $root_path/out/DF_images_$time_run
elif $use_views; then
    mkdir -p $root_path/out/DF_images_$time_run/renderings    
    cp $outd/*.tif $root_path/out/DF_images_$time_run/
    cp $outd/*.pic $root_path/out/DF_images_$time_run/renderings
    cp $outd/*_vals $root_path/out/DF_images_$time_run/renderings    
fi

ecotect_dir=$root_path/out/DF_ecotect_import_$time_run
mkdir $ecotect_dir

for file in $(ls $outd/imp_ecotect*); do
    cp $file $ecotect_dir/$(basename $file .dat)".dat"
done

runtime_final=$(date +"%s")
runtime_diff=$(($runtime_final-$runtime_initial))
echo -e "\n\n\tDaylight factor analysis took $(($runtime_diff / 60)) minutes and $((runtime_diff % 60)) seconds to run." >> $logfile

echo -e "\tDaylight factor analysis successfully finished!\n" >> $logfile
