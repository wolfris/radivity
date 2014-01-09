#! /usr/bin/python

import sys
from array import *




def write_new_grid(outputfile, data, lower_threshold, upper_threshold):
    min_x=100000000000.
    min_y=100000000000.
    max_x=-100000000000.
    max_y=-100000000000.
    min_val=100000000000.
    ave_val=0.

    cnt_lines=0
    cnt_perc_between=0
    cnt_perc_upper=0
    cnt_perc_lower=0
    for line in data:
        if float(line.split('\t')[0])< min_x:
            min_x = float(line.split('\t')[0])
        elif float(line.split('\t')[0])> max_x:
            max_x = float(line.split('\t')[0])
        if float(line.split('\t')[1])< min_y:
            min_y = float(line.split('\t')[1])
        elif float(line.split('\t')[1])> max_y:
            max_y = float(line.split('\t')[1])
        if float(line.split('\t')[2])< min_val:
            min_val = float(line.split('\t')[2])
        if float(line.split('\t')[2]) > lower_threshold and float(line.split('\t')[2]) < upper_threshold:
            cnt_perc_between+=1
        elif float(line.split('\t')[2]) >= upper_threshold:
            cnt_perc_upper+=1
        elif float(line.split('\t')[2]) <= lower_threshold:
            cnt_perc_lower+=1
        ave_val+=float(line.split('\t')[2])
        cnt_lines+=1

    ave_val=ave_val/cnt_lines

    dx=1000000
    for i in range(cnt_lines-1):
        if (data[i].split('\t')[0] != data[i+1].split('\t')[0] and data[i].split('\t')[1] == data[i+1].split('\t')[1]):
            if(abs(float(data[i+1].split('\t')[0])-float(data[i].split('\t')[0]))<dx):
                dx=abs(float(data[i+1].split('\t')[0])-float(data[i].split('\t')[0]))

    xres=int(round(1+((max_x-min_x)/dx),0))
                  
    dy=1000000
    for i in range(cnt_lines-1):
        if data[i].split('\t')[1] != data[i+1].split('\t')[1]:
            if(abs(float(data[i+1].split('\t')[1])-float(data[i].split('\t')[1]))<dy):
                dy=abs(float(data[i+1].split('\t')[1])-float(data[i].split('\t')[1]))
            
    yres=int(round(1+((max_y-min_y)/dy),0))


    
    x_coords = array('d',(xres)*[0])
    y_coords = array('d',(yres)*[0])

    for i in range(xres):
        x_coords[i]=min_x+i*((max_x-min_x)/(xres-1))

    for i in range(yres):
        y_coords[i]=min_y+i*((max_y-min_y)/(yres-1))

    f = open(outputfile, "w")
    outputfile2 = outputfile+"_recover_coord"
    ff = open(outputfile2, "w")

    f.write(str(xres)+","+str(yres)+"\n")
    counter = 0

    for j in range(yres):
        for i in range(xres):
            if counter<cnt_lines:
                if abs(float(data[counter].split('\t')[0])-x_coords[i])<0.0001 and abs(float(data[counter].split('\t')[1])-y_coords[j])<0.0001 :
                    f.write(str(x_coords[i])+"\t"+str(y_coords[j])+"\t"+str(float(data[counter].split('\t')[2]))+"\n")
                    ff.write(str(1)+"\n")
                    counter+=1
                else:
                    f.write(str(x_coords[i])+"\t"+str(y_coords[j])+"\t"+str(0.0000)+"\n")
                    ff.write(str(0)+"\n")
            else:
                f.write(str(x_coords[i])+"\t"+str(y_coords[j])+"\t"+str(0.0000)+"\n")
                ff.write(str(0)+"\n")

    if ave_val == 0.0:
        sys.stdout.write(str(round(ave_val,2))+",-,"+str(round((100*(float(cnt_perc_between)/cnt_lines)),2))+","+str(round((100*(float(cnt_perc_upper)/cnt_lines)),2))+","+
                         str(round((100*(float(cnt_perc_lower)/cnt_lines)),2))+"\n")
    else:
        sys.stdout.write(str(round(ave_val,2))+","+str(round((min_val/ave_val),2))+","+str(round((100*(float(cnt_perc_between)/cnt_lines)),2))+","+
                         str(round((100*(float(cnt_perc_upper)/cnt_lines)),2))+","+str(round((100*(float(cnt_perc_lower)/cnt_lines)),2))+"\n")

    ff.close()
