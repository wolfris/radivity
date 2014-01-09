#! /usr/bin/python

from math import floor
import sys



def update(climate_data,sched_data):
    counter = 0
    for line in climate_data:
        counter += 1

    if (counter < 8761):
        print("This is not a complete climate file, it has less than 8760 entries.")
        exit()

    sys.stdout.write(climate_data[0])
    for i in range(1,counter):
	if (float(sched_data[i-1])>0.0):
            sys.stdout.write(climate_data[i])
