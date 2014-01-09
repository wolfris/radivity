#! /usr/bin/python


import update_climate_mod

input=raw_input()

climatefile=input.split(' ')[0]
schedule=input.split(' ')[1]

f = open(climatefile, "r")
climate_data = f.readlines()
f.close()

f = open(schedule, "r")
sched_data = f.readlines()
f.close()


update_climate_mod.update(climate_data,sched_data)

