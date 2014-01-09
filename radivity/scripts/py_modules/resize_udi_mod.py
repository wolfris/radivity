#! /usr/bin/python


from math import *
from array import *


def write_resized(xres, yres, data, multi, outputfile):

    udi = array('d',(xres*yres)*[0])


    i=0
    for line in data:
        udi[i]=float(line)
        i+=1


    f = open(outputfile, "w")
    for i in range(yres):
        for k in range(multi):
            for j in range(xres):
                for kk in range(multi):
                    f.write(" "+str(udi[i*xres+j])+"\n")
    f.close()
