#! /usr/bin/python

inputdata=raw_input()
import sys
import smooth_udi_mod


inputfile=inputdata.split(' ')[0]
outputfile=inputdata.split(' ')[1]
xres=int(inputdata.split(' ')[2])
yres=xres
factor = 4

f = open(inputfile, "r")
data = f.readlines()
f.close()

smooth_udi_mod.write_smoothed(xres,yres,data,outputfile,factor)

