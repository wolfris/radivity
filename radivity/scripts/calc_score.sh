#!/bin/bash

for scene in `ls scenes/*.rad`; do
	casename=$(basename $scene .rad)
	for view in `ls views`; do
		view_file=views/$view
		image_prefix=$casename"_"$(basename $view .vf)

		pcomb -s 1 images/$image_prefix"udis_scaled.pic" images/$image_prefix"udia.pic" > images/$image_prefix"udi_score.pic"
	done
done

