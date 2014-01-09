#! /usr/bin/python

import math
import os

def write_udi_clim(path,files):
    for city in files:
        if (city.rfind("epw")+3 == len(city)):
            f = open(path+"/"+city, "r")
            data = f.readlines()
            f.close()
        
            counter = 0
            for line in data:
                counter += 1
            
            datfile = path+"/"+city[0:city.rfind("epw")-1]+".dat"
            f = open(datfile, "w")
            b=data[0].split(',')
            f.write(str(float(b[6])))
            f.write("\t")
            f.write(str(float(b[7])))
            f.write("\t")
            f.write(str(int(float(b[8])*15)))
            f.write("\n")
            for i in range(8,counter):
                a = data[i].split(',')
                f.write(str(int(a[1])))
                f.write("\t")
                f.write(str(int(a[2])))
                f.write("\t")
                f.write(str(int(a[3])-0.5))
                f.write("\t")
                f.write(a[13])
                f.write("\t")
                f.write(a[15])
                f.write("\n")
            f.close()
