#!/bin/bash
gnuplot <<EOF

reset
set terminal pngcairo enhanced size 1750,1250
set output '$1.png'



#set grid
#set size ratio -1
set size 0.77,1

#set palette rgb 33,13,10

set pm3d interpolate 4,4 at bst
set pm3d map

#set contour surface
#set cntrparam levels incremental $3
#unset surface
#set table 'tmp/cont.dat'
#splot '$2' u 1:2:3 w pm3d notitle
#unset table
#unset contour

#!awk -f $HOME/bin/radivity/scripts/label_contours.awk -v center=0 textcolor=0 inclt=1 tmp/cont.dat > $PWD/tmp/tmp.gp

#set surface

unset cblabel
set cbtics font ",20"
set cbrange[0:100]
#load 'tmp/tmp.gp'


set xtics font ",20"
set ytics font ",20"

#unset label



#splot '$2' u 1:2:3 with pm3d notitle, '$PWD/tmp/cont.dat' u 1:2:(0.0) lc rgb "black" with lines notitle
splot '$2' u 1:2:3 with pm3d notitle


EOF