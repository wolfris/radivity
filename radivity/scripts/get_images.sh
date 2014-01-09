#!/bin/bash


path_to_module=$1
root_path=$2
resol=$3
multi=$((512/$resol))
lines=$4
falsecolorFile=$5
grad=$6
outd=$7
frac=$(echo 1 $lines | awk '{print 100*($1/$2)}')

imd=$path_to_module/images/
tmpd=$path_to_module/tmp/
scene_d=$root_path/scenes
view_d=$root_path/views/parallel
filter_d=$root_path/filter/parallel

pics=(udio udia udis udiu)

for i in {1..4};do
    if [ $palette=="mono_r" ]; then
	echo ",,under 50%, over 50%" > $outd"/percentages"${pics[$((i-1))]}".csv"
    fi
done

echo $frac

for scene in $(ls $scene_d/*.rad); do
    casename=$(basename $scene .rad)
    for view in $(ls $view_d/*.vf); do
	viewname=$(basename $view .vf)
	parallel_view=$tmpd"dc/"$(basename $view .vf)_parallel.vf
	sed -e 's/vtv/vtl/g' $view > $parallel_view	    
	echo $parallel_view
	oconv -w $filter_d/$viewname"_filter".rad > $path_to_module/octrees/$viewname"_filter".oct
	rpict -t 10 -w -vf $parallel_view -av 1 1 1 -ab 0 -x 512 -y 512 $path_to_module/octrees/$viewname"_filter".oct | pfilt > $tmpd$viewname"_filter".pic
	pvalue -h -H +b -o -d $tmpd$viewname"_filter".pic > $tmpd$viewname"_filter_values"
	image_prefix=$casename"_"$viewname
	for item in ${pics[*]}; do
	    pvalue -h -H -b -o -d $imd$image_prefix$item".pic" > $imd$image_prefix"_"$item
	    if [ $resol -lt 512 ]; then
		mv $imd$image_prefix"_"$item $imd$image_prefix"_lr_"$item
		echo $imd$image_prefix"_lr_"$item $imd$image_prefix"_"$item $multi $resol | $RADIVSCRIPTS/resize_udi.py
	    fi
	done
	paste $imd$image_prefix"_udio" $imd$image_prefix"_udia" $imd$image_prefix"_udis" $imd$image_prefix"_udiu" $tmpd$viewname"_filter_values" > $imd$image_prefix"_total_udi"
	echo $imd$image_prefix"_total_udi" $imd"smooth" 512 | $RADIVSCRIPTS/smooth_udi.py
	for i in {1..4}; do 
	    cut -f $i $imd"smooth" > $imd"smooth_"$i
	    pvalue -h -H -r -b -d -x 512 -y 512 $imd"smooth_"$i > $imd"smooth_"$i.pic
	    $RADIVSCRIPTS/falsecolor_bdsp.py -i $imd"smooth_"$i.pic -m $frac -s 100 $(cat $falsecolorFile) -cl -lw 150 -z -mask 0.0001 > $imd"smooth_fc_1_"$i.pic
	    $RADIVSCRIPTS/falsecolor_bdsp.py -i $imd"smooth_"$i.pic -m $frac -s 100 $(cat $falsecolorFile) -cb  -lw 150 -z -mask 0.0001 > $imd"smooth_fc_2_"$i.pic
	    pcomb $imd"smooth_fc_1_"$i.pic $imd"smooth_fc_2_"$i.pic > $imd"smooth_fc_"$i.pic
	    ra_tiff $imd"smooth_fc_"$i.pic  $outd/$image_prefix"_"${pics[$((i-1))]}.tif
	    if [ "$grad" == "true" ]; then
		$RADIVSCRIPTS/falsecolor_bdsp.py -i $imd"smooth_"$i.pic -m $frac -s 100 $(cat $falsecolorFile) -lw 150 -z -mask 0.0001 > $imd"smooth_fc_3_"$i.pic
		pcomb $imd"smooth_fc_1_"$i.pic $imd"smooth_fc_3_"$i.pic > $imd"smooth_fc_grad_"$i.pic
		ra_tiff $imd"smooth_fc_grad_"$i.pic $outd/$image_prefix"_grad_"${pics[$((i-1))]}.tif
	    fi
	    $RADIVSCRIPTS/falsecolor_bdsp.py -i $imd"smooth_"$i.pic -m $frac -s 100 $(cat $falsecolorFile) -n 2 -cl -lw 0 -z -mask 0.0001 > $imd"smooth_fc_1b_"$i.pic
	    $RADIVSCRIPTS/falsecolor_bdsp.py -i $imd"smooth_"$i.pic -m $frac -s 100 $(cat $falsecolorFile) -n 2 -cb -lw 0 -z -mask 0.0001 > $imd"smooth_fc_2b_"$i.pic
	    pcomb $imd"smooth_fc_1b_"$i.pic $imd"smooth_fc_2b_"$i.pic > $imd"smooth_fc_b_"$i.pic
	    ra_tiff $imd"smooth_fc_b_"$i.pic $outd/$image_prefix"_b_"${pics[$((i-1))]}.tif
	    occu=$(pvalue -h $imd"smooth_fc_b_"$i.pic | awk '{if($3!=0.0000 && $4!=0.0000 && $5!=0.0000) print ($3+$4+$5)/3}' | sort | uniq -c | head -n 2 | awk '{print $1}')
	    sum=$(echo $occu | awk '{print $1+$2}')
	    echo $occu $sum $casename $viewname | awk '{print $4", "$5", "$1/$3", "$2/$3}' >> $outd"/percentages"${pics[$((i-1))]}".csv"
	done
	for item in ${pics[*]}; do
	    rm $imd$image_prefix"_"$item
	done
    done
    rm $path_to_module/tmp/$viewname"_filter_values"
done

