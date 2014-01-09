#!/bin/bash

. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh
. $RADIVSCRIPTS/funcs/functions_irrad.sh
. $RADIVSCRIPTS/funcs/progbar.sh

runtime_initial=$(date +"%s")
expert_mode=false

path_to_module=$PWD"/modules/irrad"
root_path=$(echo $PWD)
logfile=$1
fullusername=$2
if [ ! -z $3 ]; then
    expert_mode=true
fi    



#time_run=$(echo $(date) | sed -e 's/, /_/g;s/ /_/g;s/:/-/g')
time_run=$(date +%F_%H-%M-%S)
outd=$root_path/out/"irrad_images_"$time_run
mkdir $outd



echo -e "******************\nIrradiation Mapping:\n******************" >> $logfile

if [ ! -d $path_to_module ];then
    mkdir -p $path_to_module/tmp
fi
if [ ! -d $path_to_module/tmp ];then
    mkdir $path_to_module/tmp
else
    rm -fr $path_to_module/tmp/*
fi
if [ ! -d $path_to_module/climate ];then
    mkdir $path_to_module/climate
else
    rm -fr $path_to_module/climate/*
fi

if [ ! -d $path_to_module/rotated_sky ];then
    mkdir $path_to_module/rotated_sky
fi
if [ ! -d $path_to_module/config ];then
    mkdir $path_to_module/config
fi
if [ ! -d $path_to_module/octrees ];then
    mkdir $path_to_module/octrees
fi
if [ ! -d $path_to_module/out ];then
    mkdir $path_to_module/out
fi


get_climate irr

climate_file=$(ls $path_to_module/climate/*.dat)
climate_irrad=$path_to_module"/climate/"$(basename $climate_file .dat)"_irrad.dat"


get_options_irrad $climate_irrad $logfile

irrad_options.sh $options --log $logfile --expert $expert_mode  2> /dev/null
if [ "$?" -eq 666 ]; then
    exit 666
fi

cp $path_to_module/tmp/scale.bmp $outd
mkdir $outd/renderings
cp $path_to_module/out/*.pic $outd/renderings
mv $path_to_module/out/*.gif $outd
