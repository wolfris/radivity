#! /usr/bin/python

import sundat_mod


inputdata=raw_input()
dd=inputdata.split(' ')
repsuns=dd[0]+'_representative_suns.rad'
sunmod=dd[0]+'_sun_modifiers.dat'
sunind=dd[0]+'_sun_indices.dat'

sunsfile=dd[1]+'/tmp/suns'

f = open(sunsfile, "r")
data = f.readlines()
f.close()


sundat_mod.write_sundat(data, repsuns, sunmod, sunind)
