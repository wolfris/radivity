#!/bin/bash
. $RADIVSCRIPTS/funcs/functions_radivity.sh
. $RADIVSCRIPTS/funcs/functions_mod.sh


root_path=$PWD

lib_path=$HOME/bin/radivity/lib

#logfile=$1
#fullusername=$2
expert_mode=false
if [ ! -z $3 ]; then
    case $3 in
	-e)
	    expert_mode=true
	    echo "expert mode";;
    esac
fi
view_d=$root_path/views/parallel
filter_d=$root_path/filter/parallel

resol=300

echo -e "\n\n"
header
echo -e "\n\n\n\n\n\n\n\n "
echo -e -n  "  Producing filter image...\n\n  "

tmpd=$root_path/tmp
rm -f $tmpd/*
for view in $(ls $view_d/*.vf); do
    viewname=$(basename $view .vf)
    parallel_view=$tmpd/$viewname"_parallel.vf"
    sed -e 's/vtv/vtl/g' $view > $parallel_view
    oconv $filter_d/$viewname"_filter".rad > $tmpd/$viewname"_filter".oct 2> /dev/null
    rpict -t 10 -w -vf $parallel_view -av 1 1 1 -ab 0 -x $resol -y $resol $tmpd/$viewname"_filter".oct | pfilt > $tmpd/$viewname"_filter.pic"  2> /dev/null
    ra_tiff $tmpd/$viewname"_filter.pic" $tmpd/$viewname"_filter.tiff"
done
