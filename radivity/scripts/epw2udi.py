#! /usr/bin/python

import math
import os

import epw2udi_mod

path="./climate"
files=os.listdir(path)

epw2udi_mod.write_udi_clim(path,files)

