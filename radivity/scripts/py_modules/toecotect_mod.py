#! /usr/bin/python



def write_to_file(outputfile, data):
    f = open(outputfile, "w")
    i=0
    for line in data:
        illu=float(line)
        i+=1
        if (i==30):
            f.write(str(illu)+",\n")
        else:
            f.write(str(illu)+", ")
