#! /usr/bin/python

from array import *
import math


def calc_design_sky(data,d_interval):
 
    counter = 0
    max_illum = 0
    for line in data:
        counter += 1
    
    illum = array('i',(counter)*[-1])

    j = 0
    for i in range(8,counter):
        values=data[i].split(',')
        if (int(values[3])>=9  and int(values[3])<=17):
            illum[j]=int(values[16])
            if(illum[j] > max_illum):
                max_illum = illum[j]
            j += 1

    interval = array('i',((max_illum/d_interval)+2)*[0])
    counter = 0


    for illum_vals in illum:
        if (illum_vals >= 0):
            j = 0
            while (illum_vals >= d_interval*j):
                j += 1
            for jj in range(0,j):
                interval[jj] += 1


    counter = 0
    for intervals in interval:
        if (intervals <= 0.85*interval[0]):
            print(counter*d_interval)
            break
        counter += 1

    
