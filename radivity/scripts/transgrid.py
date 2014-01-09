#! /usr/bin/python

import transgrid_mod

inputdata=raw_input()


inputfile=inputdata.split(' ')[0]
outputfile=inputdata.split(' ')[1]
type_calc=inputdata.split(' ')[2]
lower=float(inputdata.split(' ')[3])
upper=float(inputdata.split(' ')[4])

f = open(inputfile, "r")
data = f.readlines()
f.close()


transgrid_mod.write_new_grid(outputfile, data, lower, upper)


