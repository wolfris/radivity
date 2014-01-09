#!/bin/bash
gnuplot <<EOF

reset
set terminal pngcairo enhanced size ${11},1250
set output '$1.png'



#set grid
#set size ratio -1
set size ${12},1

#set palette rgb 33,13,10
#set palette defined (0 '#4b4b4b', 2 '#fbff00', 10 '#fbff00')
#set palette function (1-(1/exp(10*gray))), (1-(1/exp(10*gray))), 0


set pm3d interpolate 4,4 at bst
set pm3d map

set contour surface
set cntrparam levels incremental $3,$4,$5
unset surface
set table 'tmp/cont.dat'
splot '$2' u 1:2:3 w pm3d notitle
unset table
unset contour

!awk -f $HOME/bin/radivity/scripts/label_contours.awk -v center=0 textcolor=0 inclt=1 tmp/cont.dat > $PWD/tmp/tmp.gp

set surface

unset cblabel
set cbtics font ",20"
set cbrange[0:10]
load 'tmp/tmp.gp'


set xtics font ",20"
set ytics font ",20"

unset label


set label 1 at graph 1.2 , graph 0.4  font ",22"
set label 1 "Average DF:         $6" 
set label 2 at graph 1.2, graph 0.35  font ",22"
set label 2 "Min/Average DF:  $7" 
set label 3 at graph 1.2, graph 0.3  font ",22"
set label 3 "% ($3-$5):              $8" 
set label 4 at graph 1.2, graph 0.25  font ",22"
set label 4 "% > $5:                $9" 
set label 5 at graph 1.2, graph 0.2  font ",22"
set label 5 "% < $3:                ${10}" 

splot '$2' u 1:2:3 with pm3d notitle, '$PWD/tmp/cont.dat' u 1:2:(0.0) lc rgb "black" with lines notitle
#splot '$2' u 1:2:3 with pm3d notitle


EOF
