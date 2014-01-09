#! /usr/bin/python



def write_sundat(data, repsuns, sunmod, sunind):
    for line in data:
        if (line[0:20] == 'Representative suns:'):
            f = open(repsuns, "w")
        elif (line[0:14] == 'Sun modifiers:'):
            f.close()
            f = open(sunmod, "w")
        elif (line[0:9] == 'Sun index'):
            f.close()
            f = open(sunind, "w")
        else:
            f.writelines(line)
