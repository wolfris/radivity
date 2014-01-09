#!/bin/bash
coefficient_file=$1
root_path=$2
path_to_module=$3
resol=$4
range1=$5
range2=$6
range3=$7

imd=$path_to_module/images/
tmpd=$path_to_module/tmp/
coeffd=$path_to_module/coefficients/
scene_d=$root_path/scenes

if [[ "$resol">0 ]]; then
	vdir=$root_path/views/parallel/*.vf
	file_end=".vf"
else
	vdir=$root_path/grids/*.pts
	file_end=".pts"
fi

pics=(udio udia udis udis_scaled udiu)
pics_d=(udio udia udis udiu)

tmp_coefficient_file=$coefficient_file"_tmp"
tail -n $(($(cat $coefficient_file | wc -l)-1)) $coefficient_file > $tmp_coefficient_file


echo -e "Executing udi_vv\n"
echo $coefficient_file $range1 $root_path
for scene in $(ls $scene_d/*.rad); do
    casename=$(basename $scene .rad)
    for view in $(ls $vdir); do
	image_prefix=$casename"_"$(basename $view $file_end)
	if [[ -z "$range1" ]]
	then
	    echo "-s 100 -a 2000 -g 10000"
	    $RADIVBINS/udi_vv $coeffd$image_prefix"_p"*.pic $coeffd$image_prefix"_solar"*.pic -f  $tmp_coefficient_file -s 100 -a 2000 -g 10000
	else
	    echo "-s "$range1" -a "$range2" -g "$range3
	    $RADIVBINS/udi_vv $coeffd$image_prefix"_p"*.pic $coeffd$image_prefix"_solar"*.pic -f  $tmp_coefficient_file -s $range1 -a $range2 -g $range3
	fi
	for item in ${pics[*]}; do
	    mv $item".pic" $imd$image_prefix$item".pic" 
	done
	for item in ${pics_d[*]}; do
	    mv $item"_d.dat" $tmpd$image_prefix$item".dat"
	done
    done
done
rm $tmp_coefficient_file

