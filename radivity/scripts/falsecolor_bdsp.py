#!/usr/bin/env python

import os
import sys
import tempfile
import time
import shlex, shutil
import math
import traceback
from subprocess import Popen, PIPE

import falsecolor_mod




if __name__ == "__main__":
    # create falsecolor image and write to stdout - like falsecolor.csh
    print >> sys.stderr, "CREATING FALSECOLOR IMAGES:"
    fc_img = falsecolor_mod.FalsecolorImage(sys.argv[1:])
    fc_img.doFalsecolor()
    if os.name == 'nt':
        import msvcrt
        msvcrt.setmode(1,os.O_BINARY)
    sys.stdout.write(fc_img.data)

    if fc_img.error:
        print >>sys.stderr, "falsecolor.py error:", fc_img.error
        sys.exit(1)
    else:
        sys.exit(0)


