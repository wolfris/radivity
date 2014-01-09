#! /usr/bin/python

import designsky_mod

inputdata=raw_input()

inputfile=inputdata.split(' ')[0]
d_interval=int(inputdata.split(' ')[1])


f = open(inputfile,"r")
data = f.readlines()
f.close()

designsky_mod.calc_design_sky(data,d_interval)
