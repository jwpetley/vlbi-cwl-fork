#!/usr/bin/env python
# -* coding: utf-8 -*-

"""
Create NDPPP concat parset based on input catalogue

Created 7 July 2023

@author: James Petley (jwpetley@gmail.com) 
(Based on code from Leah Morabito)
"""

import argparse
import numpy as np
import os
import logging
from astropy.io import ascii
import datetime
from glob import glob

from sort_times_into_freqGroups import main as sort_times_into_freqGroups
import sys 
import json 

def main(cat_file):
    mycat = ascii.read(cat_file)
    ralist = np.array(mycat['RA'])
    declist = np.array(mycat['DEC'])
    srclist = np.array(mycat['Source_id'])

    for i in range(0,len(srclist)):
        # Find all MS for that src
        mslist = glob('*'+str(srclist[i])+'*')
        # Sort times into freq groups
        print(mslist)
        output = sort_times_into_freqGroups(mslist)

        filenames = output['filenames']
        groupnames = output['groupnames']

        # Write NDPPP concat parset

        with open( 'ndppp_concat_'+str(srclist[i])+'.parset', 'w') as f:
            f.write( 'msin = {:s}\n'.format(str(filenames)))
            f.write( 'msin.missingdata = True\n')
            
            f.write( 'steps = [count]\n')

            f.write( 'msout = {:s}\n'.format(str(srclist[i]) + '_concat' + os.path.split(filenames[0].replace('msdpppconcat','msdpppconcat'))[1]))
            f.write( 'msout.overwrite = True\n')
            f.write( 'msout.storagemanager = dysco\n')

            f.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create NDPPP concat parset based on input catalogue')
    parser.add_argument('cat_file', type=str, help='Input catalogue file')
    args = parser.parse_args()
    main(args.cat_file)


