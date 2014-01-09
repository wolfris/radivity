#! /usr/bin/python


from array import *
import math

def write_percentages(xres,yres,data):

    percentage_over = array('d',(xres*yres)*[0])
    percentage_adequate = array('d',(xres*yres)*[0])
    percentage_suppl = array('d',(xres*yres)*[0])
    percentage_under = array('d',(xres*yres)*[0])

    i = 0
    for line in data:
        columns  = line.split()
        line_sum = (int(math.ceil(float(columns[0]))) + int(math.ceil(float(columns[1]))) + int(math.ceil(float(columns[2]))) 
                + int(math.ceil(float(columns[3]))))
        if float(columns[4])!= 0.0:
            percentage_over[i] = float(float(columns[0])/line_sum)
            percentage_adequate[i] = float(float(columns[1])/line_sum)
            percentage_suppl[i] = float(float(columns[2])/line_sum)
            percentage_under[i] = float(float(columns[3])/line_sum)
            i += 1
    no_lines = i


    ave_over = 0.0
    ave_adequate = 0.0
    ave_suppl = 0.0
    ave_under = 0.0
    for i in range(0,no_lines-1):
        ave_over = ave_over + percentage_over[i]
        ave_adequate = ave_adequate + percentage_adequate[i]
        ave_suppl = ave_suppl + percentage_suppl[i]
        ave_under = ave_under + percentage_under[i]

    ave_over = ave_over/no_lines
    ave_adequate = ave_adequate/no_lines
    ave_suppl = ave_suppl/no_lines
    ave_under = ave_under/no_lines

    print(100*ave_over, 100*ave_adequate, 100*ave_suppl, 100*ave_under)
