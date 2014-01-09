#!/bin/bash

type_calc=$1
if [ "$type_calc" == "udi" ]; then
	perc="time"
elif [ "$type_calc" == "leed_ieq" ]; then
	perc="area"
else
	echo "I/O error"
	exit
fi

path_to_module=$2
root_path=$3
lines=$4
final_outd=$5
tmpd=$path_to_module/tmp/dc/
outd=$path_to_module/out/
scene_d=$root_path/scenes
coeff_d=$path_to_module/coefficients/

pics=(udio udia udis udiu)

for scene in $(ls $scene_d/*.rad); do
    casename=$(basename $scene .rad)
    for grid in $(ls $root_path/grids/*.pts); do
	image_prefix=$casename"_"$(basename $grid .pts)
	cut -f 1 $tmpd$image_prefix"_p001_ss" > $tmpd"x"
	cut -f 2 $tmpd$image_prefix"_p001_ss" > $tmpd"y"
	for item in ${pics[*]}; do
	    awk '{print $1"\t"$2"\t"100*$3/'$lines'"\t"100*$4/'$lines'"\t"100*$5'$lines'}' $path_to_module/tmp/$image_prefix$item".dat" > $tmpd$item"_perc"
	    touch $tmpd"grid_resol"
	    for pic in $(ls $coeff_d$image_prefix*.pic); do
		pvalue $coeff_d$image_prefix"_p001.pic" | head -n 6 | tail -n 1 | awk '{print $2","$4}' > $tmpd$item".plot"
		if [[ -s $tmpd"grid_resol" ]]; then
		    break
		fi
	    done
	    cut -f 3 $tmpd$item"_perc" > $tmpd$item
	    paste $tmpd$image_prefix"_p001_s_recover_coord" $tmpd$item | awk '{if ($1==0) {print 0.0} else {print $2}}' > $tmpd$item"_full"
	    paste $tmpd"x" $tmpd"y" $tmpd$item"_full" >> $tmpd$item".plot"
	    echo $tmpd$item".plot" $outd$item".plot" | tognuplot.py
	    plot_udi.sh $outd$item $outd$item".plot"
	done
    done
    
done

mv $outd/*.png $final_outd
