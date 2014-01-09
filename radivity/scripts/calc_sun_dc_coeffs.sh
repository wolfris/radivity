#!/bin/bash

sun_modifier_list=$1
suns=$2
path_to_module=$3
root_path=$4
resol=$5
amb_params_file=$6
tmp_d=$path_to_module/tmp/dc/
coeff_d=$path_to_module/coefficients/
oct_d=$path_to_module/octrees/
scene_d=$root_path/scenes/
view_d=$root_path/views/parallel/
grid_d=$root_path/grids/



if [[ -z $resol ]]; then
	resol=512
fi


for scene in $(ls $scene_d*.rad); do
    casename=$(basename $scene .rad)
    octree=$oct_d"suns_"$casename".oct"
    oconv $suns $scene > $octree
    
    if [[ "$resol" > 0 ]]; then
	for view in $(ls $view_d*.vf); do
	    parallel_view=$tmp_d/$(basename $view .vf)_parallel.vf
	    sed -e 's/vtv/vtl/g' $view > $parallel_view	    
	    ambient_params=$(echo $(cat $amb_params_file)" -i+")
	    image_prefix=$casename"_"$(basename $view .vf)
	    # vwrays -ff -x $resol -y $resol -vf $view | rtcontrib `vwrays -d -x $resol -y $resol -vf $view` -ffc $ambient_params -o $coeff_d$image_prefix"_%s.pic" \
	    # 	-M $sun_modifier_list -n 1 $octree 
	    vwrays -fa -x $resol -y $resol -vf $parallel_view | rcalc -e '$1=$1;$2=$2;$3=$3;$4=$4;$5=$5;$6=1' | rtcontrib `vwrays -d -x $resol -y $resol -vf $parallel_view` \
	    	-fac $ambient_params -o $coeff_d$image_prefix"_%s.pic" -M $sun_modifier_list -n 1 $octree 
	done
    else
	for grid in $(ls $grid_d*.pts); do
	    ambient_params="-ab 6 -ad 1024 -ar 128 -ad 512 -i+"
	    image_prefix=$casename"_"$(basename $grid .pts)
	    rtcontrib $ambient_params  -o $tmp_d$image_prefix"_%s.dat" -M $sun_modifier_list -n 1 $octree < $grid
	    cut -f 1 -d ' ' $grid > $tmp_d$image_prefix"s_x"
	    cut -f 2 -d ' ' $grid > $tmp_d$image_prefix"s_y"
	    for file in $(ls $tmp_d$image_prefix"_s"*".dat"); do
		filename=$tmp_d$(basename $file .dat)"_d"
		filename2=$tmp_d$(basename $file .dat)"_a"
		filename3=$tmp_d$(basename $file .dat)"_s"
		filename4=$tmp_d$(basename $file .dat)"_ss"
		picname=$coeff_d$(basename $file .dat)".pic"
		tail -n $(($(wc $file | awk '{print $1}')-9)) $file > $filename
		paste $tmp_d$image_prefix"s_x" $tmp_d$image_prefix"s_y" $filename > $filename2
		echo $filename2 $filename3 coeffs 2 5 | transgrid.py
		grid_resol_x=$(head -n 1 $filename3 | awk -F\, '{print $1}')
		grid_resol_y=$(head -n 1 $filename3 | awk -F\, '{print $2}')
		tail -n $(($(wc $filename3 | awk '{print $1}')-1)) $filename3 > $filename4
		cut -f 3 $filename4 | pvalue -r -h -H -d -b  -x $grid_resol_x -y $grid_resol_y > $picname
	    done
	    rm $tmp_d*s_x
	    rm $tmp_d*s_y
	done
    fi	
    
done
