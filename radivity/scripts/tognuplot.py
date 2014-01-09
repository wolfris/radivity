#! /usr/bin/python


import tognuplot_mod

inputdata=raw_input()

inputfile=inputdata.split(' ')[0]
outputfile=inputdata.split(' ')[1]

f = open(inputfile, "r")
data = f.readlines()
f.close()

#tognuplot_mod.write_plotdata(outputfile, data)

tognuplot_mod.write_plotdata_nonrect(outputfile, data)