#!/bin/bash

. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh


root_path=$PWD

for scene in $(ls $root_path/scenes/*.rad); do
    scene_name=$(basename $scene .rad)
    echo $scene $root_path/tmp/$scene_name | clean_cylinders.py
    mv $root_path/tmp/$scene_name $scene
done
