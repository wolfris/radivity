#!/usr/bin/python

inputdata = raw_input()

inputfile = inputdata.split(' ')[0]
outputfile = inputdata.split(' ')[1]

f = open(inputfile, "r")
data = f.readlines()
f.close()

f = open(outputfile, "w")

counter = 0
for line in data:
    counter += 1

boo = 0

for i in range(counter):
    if (boo > 0):
        boo -= 1
    if (len(data[i].split(' '))>2 and data[i].split(' ')[1]=='cylinder'):
        if (data[i+4]==data[i+5]):
            boo = 9
        elif (float(data[i+6])==0.0):
            boo = 9
        else:
            f.write(data[i])            
    elif (boo==0):
        f.write(data[i])
        
