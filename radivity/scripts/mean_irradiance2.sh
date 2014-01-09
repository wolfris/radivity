#!/bin/bash 

function error_exit {
 echo "exiting because of error"
 exit 1
}
trap error_exit ERR


for image in `ls processed_images/*_final.pic`; do
	casename=$(basename $image _final.pic)
	
	filter_image=processed_images/$casename"_filter.pic"
	raw_image=images/$casename".pic"
	sky_filter_image=processed_images/$casename"_skyfilter.pic"
	
	echo $casename | awk '{printf $1"\t"}'
	pcomb -e 'ro=if(ri(1)-ri(3),ri(2),0);go=if(gi(1)-gi(3),gi(2),0);bo=if(bi(1)-bi(3),bi(2),0)' $filter_image $raw_image $sky_filter_image| 
		pvalue -h -H -b -d -o+ | grep -v 0.000 | total -m

done	
