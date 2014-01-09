#! /usr/bin/python


from platform import system
import calc_percentage_time_mod


inputdata = raw_input()
inputfile = inputdata.split(' ')[0]
xres = int(inputdata.split(' ')[1])
yres = xres

f = open(inputfile, "r")
data = f.readlines()
f.close()

calc_percentage_time_mod.write_percentages(xres,yres,data)

