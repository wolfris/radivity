#! /usr/bin/python

import sys


def write_plotdata(outputfile, data):
	f = open(outputfile, "w")
	i=0
	counter=0
	minval=100000000000
	maxval=-100000000000
	for line in data:
		if counter==0:
			resx=int(line.split(',')[0])
			resy=int(line.split(',')[1])
			counter+=1
		else:
			if float(line.split('\t')[2]) < minval and float(line.split('\t')[2])>0.0:
				minval=float(line.split('\t')[2])
			if float(line.split('\t')[2]) > maxval:
				maxval=float(line.split('\t')[2])
			i+=1
			if (i==resx):
				f.write(line+"\n")
				i=0
			else:
				f.write(line)
	f.close()

	sys.stdout.write(str(round((maxval-minval)/3,0))+","+str(round((maxval-minval)/3,0))+","+str(3*round((maxval-minval)/3,0)))

	
def write_plotdata_nonrect(outputfile, data):
	f = open(outputfile, "w")
	counter=0

	for line in data:
		if counter==0:
			resx=int(line.split(',')[0])
			resy=int(line.split(',')[1])
		elif counter ==1:
			f.write(line)
		else:
			if float(data[counter-1].split('\t')[1])==float(line.split('\t')[1]):
				f.write(line)
			else:
				f.write("\n"+line)
		counter+=1
		sys.stdout.write(str(counter)+"\n")
	f.close()