#! /usr/bin/python

import resize_udi_mod

inputdata=raw_input()

inputfile=inputdata.split(' ')[0]
outputfile=inputdata.split(' ')[1]
multi=int(inputdata.split(' ')[2])
xres=int(inputdata.split(' ')[3])
yres=xres

f = open(inputfile, "r")
data = f.readlines()
f.close()


resize_udi_mod.write_resized(xres, yres, data, multi, outputfile)

