#! /usr/bin/python

import toecotect_mod

inputdata=raw_input()



inputfile=inputdata.split(' ')[0]
outputfile=inputdata.split(' ')[1]
resx=int(inputdata.split(' ')[2])
resy=int(inputdata.split(' ')[3])

f = open(inputfile, "r")
data = f.readlines()
f.close()

toecotect_mod.write_to_file(outputfile, data)
