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


echo -e "\n\n"
header
echo -e "\n\n\n\n\n\n\n\n "
echo -e -n  "  Please enter the resolution for the grids:\n\n  "
read resol

tmpd=$root_path/tmp
rm -f $tmpd/*
for view in $(ls $view_d/*.vf); do
    viewname=$(basename $view .vf)
    parallel_view=$tmpd/$viewname"_parallel.vf"
    sed -e 's/vtv/vtl/g' $view > $parallel_view
    vwrays -x $resol -y $resol -vf $parallel_view | rcalc -e '$1=$1;$2=$2;$3=$3;$4=$4;$5=$5;$6=1' > $tmpd/$viewname"_full.pts"
    oconv $filter_d/$viewname"_filter".rad > $tmpd/$viewname"_filter".oct 2> /dev/null
    rpict -t 10 -w -vf $parallel_view -av 1 1 1 -ab 0 -x $resol -y $resol $tmpd/$viewname"_filter".oct | pfilt > $tmpd/$viewname"_filter.pic" 2> /dev/null
    pvalue -h -d $tmpd/$viewname"_filter.pic" | tail -n +2 > $tmpd/$viewname"_filter_values"
    paste $tmpd/$viewname"_full.pts" $tmpd/$viewname"_filter_values" | awk '{if($7!=0.00) print $2" "$1" "$3" "$4" "$5" "$6}' | sed '1!G;h;$!d' > $tmpd/$viewname".pts"
    mv $tmpd/$viewname".pts" $root_path/grids/$viewname".pts"
done
