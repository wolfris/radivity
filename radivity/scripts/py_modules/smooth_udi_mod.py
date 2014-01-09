#! /usr/bin/python


from math import *
from array import *


def write_smoothed(xres,yres,data,outputfile,factor):
    udio = array('d',(xres*yres)*[0])
    udia = array('d',(xres*yres)*[0])
    udis = array('d',(xres*yres)*[0])
    udiu = array('d',(xres*yres)*[0])
    fil = array('d',(xres*yres)*[0])


    i=0
    for line in data:
        udio[i]=float(line.split('\t')[0])
        udia[i]=float(line.split('\t')[1])
        udis[i]=float(line.split('\t')[2])
        udiu[i]=float(line.split('\t')[3])
        tmp_str=line.split('\t')[4]
        tmp_str=tmp_str.lstrip().split(' ')[0]
        if float(tmp_str) > 0.0:
            fil[i] = 1.0
        i+=1

    f = open(outputfile, "w")
    average = array('d', 4*[0])
		
    for j in range(i):
        div = 0
        for jj in range(4):
            average[jj]=0.0
        for k in range(-factor,factor+1):
            for kk in range(-factor,factor+1):
                if ((j+k+kk*xres)>=0 and (j+k+kk*xres)<(xres*yres) and floor(float(j+k)/xres)==floor(float(j)/xres)):
                    div+=fil[j+k+kk*xres]
                    average[0]+=fil[j+k+kk*xres]*udio[j+k+kk*xres]
                    average[1]+=fil[j+k+kk*xres]*udia[j+k+kk*xres]
                    average[2]+=fil[j+k+kk*xres]*udis[j+k+kk*xres]
                    average[3]+=fil[j+k+kk*xres]*udiu[j+k+kk*xres]
        if (div>0.0):
            for jj in range(4):
                average[jj]=average[jj]/div
                if average[jj]==0.0:
                    average[jj]=0.1
        f.write(str(fil[j]*average[0])+"\t"+str(fil[j]*average[1])+"\t"+str(fil[j]*average[2])+"\t"+str(fil[j]*average[3])+"\n")
                
    f.close()
