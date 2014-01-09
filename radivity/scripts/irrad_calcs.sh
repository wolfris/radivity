#!/bin/bash

. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_irrad.sh

echo -e "\n\n\n"
headerIrrad
echo -e "\n\n\n\n\nRunning simulations...\n"


root_path=$1
sky_rotation_file=$2
path_to_module=$3
create_octrees=$4
insolation_hours=$5
lib_path=$6
run_simulation=$7
reuse_cache=$8
falsecolorFile=$9
ambientParamsFile=${10}
imageSizeFile=${11}
generate_filters=${12}
climate_file=${13}
do_sky=${14}

scene_d=$root_path/scenes
view_d=$root_path/views/perspective
filter_d=$root_path/filter


echo $ambientParamsFile

gensuns_log=$path_to_module"/tmp/gensuns.log"
temp_clim=$path_to_module"/tmp/temp_climate_file.dat"
clim_log=$path_to_module"/tmp/climate_file_processing.log"
falsecolor_log=$path_to_module"/tmp/falsecolor.log"

function finalise_image {
	image_casename=$1
	
	input_image_name=$path_to_module"/out/"$image_casename".pic"
	falsecolored_image_name=$path_to_module"/out/"$image_casename"_falsecolor.pic"

	echo "falsecoloring..."
	timeout 10m falsecolor_bdsp.py -d $(cat $falsecolorFile) -lw 0 -i $input_image_name > $falsecolored_image_name 2>> $falsecolor_log
	if [ "$?" -eq 124 ]; then
	    echo "falsecolor exited due to timeout (it took over 10 minutes)." >> $falsecolor_log
	fi
	echo "converting picture..."
	ra_gif -n 1 $falsecolored_image_name > $path_to_module"/out/"$image_casename"_falsecolor.gif"
}

function finalise_image_with_filter {
	image_casename=$1
	view_file=$2
	filter_octree=$3

	# echo $image_casename
	# echo $view_file
	
	input_image_name=$path_to_module"/out/"$image_casename".pic"
	filter_image_name=$path_to_module"/out/"$image_casename"_filter.pic"
	sky_filter_image_name=$path_to_module"/out/"$image_casename"_skyfilter.pic"
	background_image_name=$path_to_module"/out/"$image_casename"_background.pic"
	falsecolored_image_name=$path_to_module"/out/"$image_casename"_falsecolor.pic"
	final_image_name=$path_to_module"/out/"$image_casename"_final.pic"

	if $generate_filters; then
	    rpict -w -vf $view_file @$ambientParamsFile @$imageSizeFile -ab 0 -av 1 1 1 $filter_octree > $filter_image_name
	    rpict -w -vf $view_file @$ambientParamsFile @$imageSizeFile -i+ -ab 0 -av 0 0 0 $filter_octree > $sky_filter_image_name
	fi

	pfilt -h 1e10 $input_image_name > $background_image_name
	echo "falsecolouring..."
	timeout 10m falsecolor_bdsp.py -d $(cat $falsecolorFile) -lw 0 -i $input_image_name > $falsecolored_image_name 2>> $falsecolor_log
	if [ "$?" -eq 124 ]; then
	    echo "falsecolor exited due to timeout (it took over 10 minutes)." >> $falsecolor_log
	fi

	echo "filtering..."
	pcomb -e 'ro=if(ri(4),1,if(ri(1),ri(2),ri(3)));go=if(gi(4),1,if(gi(1),gi(2),gi(3)));bo=if(bi(4),1,if(bi(1),bi(2),bi(3)))' $filter_image_name $falsecolored_image_name $background_image_name $sky_filter_image_name  > $final_image_name

	echo "converting picture..."
	ra_gif -n 1 $final_image_name > $path_to_module"/out/"$(basename $final_image_name .pic).gif
}


function generate_suns {
	sunfilename=$1
	latitude=$2
	longitude=$3
	meridian=$4
	gensuns -a $latitude -o $longitude -m $meridian 2> $path_to_module/tmp/gensuns.log | 
		awk 'BEGIN {i=0} {if ($1!="") {print "void light sol"i"\n0\n0\n3 1 1 1\nsol"i" source sun"i"\n0\n0\n4 "$1" "$2" "$3" 0.5\n"; ++i}}' > $sunfilename

}

module_path_sed=$(echo $path_to_module | sed 's/\//\\\//g')




if $do_sky; then
    if $insolation_hours; then
	if test -z "$climate_file"; then
	    echo "Enter site latitude (degN): "
	    read latitude
	    
	    echo "Enter site longitude (degE): "
	    read longitude
	    
	    echo "Enter site meridian (degE): "
	    read meridian
	elif !(test -e "$climate_file"); then
	    echo "Enter site latitude (degN): "
	    read latitude
	    
	    echo "Enter site longitude (degE): "
	    read longitude
	    
	    echo "Enter site meridian (degE): "
	    read meridian
	fi
	latitude=$(head -n 1 "$climate_file" | awk '{print $1}')
	longitude=$(head -n 1 "$climate_file" | awk '{print $2}')
	meridian=$(head -n 1 "$climate_file" | awk '{print $3}')
	
	generate_suns $path_to_module/tmp/lights.rad $latitude $longitude $meridian 2>> $gensuns_log
	check_gensuns_errors $gensuns_log
	location_line=$(echo $latitude $longitude $meridian | awk '{print "-a "$1" -o "$2" -m "$3}')
	tail -n +2 $climate_file > $temp_clim 
	
	# ADD -l OPTION (lowercase letter l) AND REPLACE +s1 WITH +s2 
	# TO GENERATE ILLUMINANCE INSTEAD OF IRRADIANCE
	gendiscreteskyOptions="+s1 -G $location_line -h 0.5 "$temp_clim
	gendiscretesky $gendiscreteskyOptions > $path_to_module/rotated_sky/discrete.cal 2> $clim_log
	check_sun_up_errors $clim_log
	discrete_file=$module_path_sed"\/rotated_sky\/discrete.cal"
	sed -e "s/discrete.cal/$discrete_file/g" $lib_path/discretesky_base.rad > $path_to_module/rotated_sky/discretesky.rad
    else
	if test -z "$climate_file"; then
	    echo "No climate file specified - exiting."
	    exit
	elif !(test -e "$climate_file"); then
	    echo "Unknown climate file: "$climate_file
	    exit
	fi
	
	climate_file_location_line=$(head -n 1 "$climate_file")
	
	if !(test `echo $climate_file_location_line | wc -w` -eq 3); then
	    echo "Climate file location format invalid - exiting"
	    exit
	fi
	
	location_line=$(echo $climate_file_location_line | awk '{print "-a "$1" -o "$2" -m "$3}')
	
	tail -n +2 $climate_file > $temp_clim 
	
	# ADD -l OPTION (lowercase letter l) AND REPLACE +s1 WITH +s2 
	# TO GENERATE ILLUMINANCE INSTEAD OF IRRADIANCE
	gendiscreteskyOptions="+s1 -G $location_line -h 0.5 "$temp_clim
	gendiscretesky $gendiscreteskyOptions > $path_to_module/rotated_sky/discrete.cal 2> $clim_log
	check_sun_up_errors $clim_log
	discrete_file=$module_path_sed"\/rotated_sky\/discrete.cal"
	sed -e "s/discrete.cal/$discrete_file/g" $lib_path/discretesky_base.rad > $path_to_module/rotated_sky/discretesky.rad
    fi
fi


echo -e "\n\n\n"
headerIrrad
echo -e "\n\n\n\n\n\n  Creating falsecolor scale...\n"
echo ""
falseclog=$path_to_module"/tmp/falsecolor_scale.log"
oconv -w | rpict -x 1 -y 1 -ab 0  2> $falseclog | falsecolor_bdsp.py $(cat $falsecolorFile) 2>> $falseclog | ra_bmp > $path_to_module/tmp/scale.bmp 2>> $falseclog



for scene in $(ls "$scene_d"/*.rad ); do
    rotations=$(tail -n $(wc $sky_rotation_file | awk '{print $1-5}') $sky_rotation_file)
    for rotation in $rotations; do
	octreename=$(basename $scene .rad)_$rotation".oct"
	octree=$path_to_module/octrees/$octreename
	
	skyname=$path_to_module"/rotated_sky/sky_"$(basename $scene .rad)_$rotation".rad"
	echo "!xform -rz "$rotation $path_to_module"/rotated_sky/discretesky.rad" > $skyname
	
	visible_geometry_filter=$path_to_module"/visible_geometry/"$(basename $scene .rad)"_visible.rad"
	visible_geometry_octree=$path_to_module"/octrees/"$(basename $scene .rad)"_visible.oct"
	
	if $create_octrees; then
	    echo "Creating octree..."
	    if $insolation_hours; then
	 	oconv -w $path_to_module/tmp/lights.rad $scene > $octree
	    else
	 	oconv -w $skyname $scene > $octree
	    fi

	    if test -e $visible_geometry_filter; then
		echo "Using visible geometry filter"
		oconv -w $visible_geometry_filter > $visible_geometry_octree
		octree_no_light=$visible_geometry_octree
	    else
		if $insolation_hours; then
		    octree_no_light=$path_to_module/octrees/$(basename $scene .rad)_$rotation"_no_light.oct"
		    oconv -w $scene > $octree_no_light
		fi
	    fi
	    
	fi

	casename=$(basename $octree .oct)
	echo $casename
	
	outputDir=$path_to_module"/out"
	ambientCache=$path_to_module"/out/"$casename".amb"
	
	if $run_simulation; then
	    if $reuse_cache; then
		echo "REUSING AMBIENT CACHE"
	    else
		# delete any existing ambient file 
		rm -f $ambientCache
	    fi
	fi

	filter_filename=$(echo $casename | awk -F _ '{printf "'$filter_d'/"; for (i=1; i<NF-1; ++i) {printf $i"_"}; printf $(NF-1)"_filter.rad\n"}')
	filter_octree=$path_to_module/octrees/$casename"_filter.oct"
	if test -e $filter_filename; then
	    oconv -w $filter_filename $skyname > $filter_octree
	fi
		
	for viewfile in $(ls "$view_d"/*.vf); do
 	    viewname=$(basename $viewfile .vf)
	    echo $viewname

	    if $insolation_hours; then
	 	image_casename=$casename"_"$viewname"_insolation"
	    else
	 	image_casename=$casename"_"$viewname
	    fi

	    finalImage=$outputDir"/"$image_casename".pic"
	    if $run_simulation; then
	 	if $insolation_hours; then
	 	    size_string=$(cat $imageSizeFile)
		    vwrays $size_string -vf $viewfile -ff | rtrace -ab 0 -opn -w -h -ff $octree_no_light > $path_to_module/tmp/rtracetest
	 	    vwrays $size_string -vf $viewfile -ff | rtrace -ab 0 -opn -w -h -ff $octree_no_light | rtrace  -I+  -ab 0 -dt 0 -h -o~TV -ff $octree | \
	 	    insolation_hour_counter `vwrays $size_string -vf $viewfile -d` > $finalImage 2>> $path_to_module/tmp/insolation_hours.log
	 	else
	 	    if test -e $visible_geometry_octree; then
	 		# overture calculation
	 		if $do_overture; then
	 		    echo "Overture"
			    vwrays -fd -vf $viewfile -x 64 -y 64 | 
	 		    rtrace -w -h -fd -opn $visible_geometry_octree | 
	 		    rtrace -af $ambientCache @$ambientParamsFile -I+ -fdc `vwrays -d -vf $viewfile -x 64 -y 64` $octree > $path_to_module"/tmp/overture.pic"
	 		fi
						
	 		# main calculation
	 		echo "Main"
	 		size_string=$(cat $imageSizeFile)
	 		vwrays -fd -vf $viewfile $size_string | 
	 		rtrace -w -h -fd -opn $visible_geometry_octree | 
	 		rtrace -af $ambientCache @$ambientParamsFile -I+ -fdc `vwrays -d -vf $viewfile $size_string` $octree > $finalImage
		    else
	 		# overture calculation
	 		if $do_overture; then
	 		    rpict -af $ambientCache -t 10 -w -i+ -x 64 -y 64 -vf $viewfile @$ambientParamsFile $octree > $path_to_module"/tmp/overture.pic"
	 		fi
						
	 		# main calculation
	 		rpict -af $ambientCache -t 10 -w -i+ @$imageSizeFile -vf $viewfile @$ambientParamsFile $octree > $finalImage
	 	    fi
	 	fi
	    fi

	    if test -e $filter_filename; then
	 	finalise_image_with_filter $image_casename $viewfile $filter_octree
	    else 
	 	finalise_image $image_casename 
	    fi
	done

	# if $run_simulation; then
 	#     if test -e $ambientCache; then
	#  	cp $ambientCache $outputDir
	#     fi
	# fi

    done
done
