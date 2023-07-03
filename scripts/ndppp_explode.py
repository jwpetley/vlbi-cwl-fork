#!/usr/bin/env python
# -* coding: utf-8 -*-

"""
Create NDPPP explode parset based on input catalogue

Created 11 Feb 2019

@author: Leah Morabito (lmorabit@gmail.com)
"""

import argparse
import numpy as np
import os
import logging
from astropy.io import ascii
import datetime

def main( msin, cat_file, delay_solset, phaseup_cmd="{ST001:'CS*'}", flag_cmd='', filter_cmd="'!CS*&*'", freqres='390.56kHz', timeres=32., ncpu=16 ):

    timeres = str(timeres)
    ncpu = str(ncpu)

    mycat = ascii.read(cat_file)
    ralist = np.array(mycat['RA'])
    declist = np.array(mycat['DEC'])
    srclist = np.array(mycat['Source_id'])

    phasecenter = '['
    msout = '['
    for i in range(0,len(srclist)):
        msout = msout + str(srclist[i]) + '_' + os.path.split(msin.replace('msdpppconcat','mstargetphaseup'))[1] + ','
        phasecenter = phasecenter + '[' + str(ralist[i]) + 'deg,' + str(declist[i]) + 'deg],'
    msout = msout.rstrip(', ') + ']'
    phasecenter = phasecenter.rstrip(',') + ']'

    if len(srclist) < int(ncpu):
	    ncpu = str(len(srclist))

    with open( 'ndppp_explode.parset', 'w') as f:
        #f.write( 'msin = {:s}\n'.format(str(msin))) This will get written in the workflow
        f.write( 'steps = [split]\n' )
        f.write( 'split.replaceparms = [phaseshift.phasecenter, applybeam.direction, msout.name]\n' )
        f.write( 'split.steps = [phaseshift, averager1, applybeam, averager2, applycal, averager3, msout]\n' )
        f.write( 'phaseshift.type = phaseshift\n' )
        f.write( 'phaseshift.phasecenter = {:s}\n'.format(phasecenter) )
        f.write( 'averager1.type = averager\n' )
        f.write( 'averager1.freqresolution = 48.82kHz\n' )
        f.write( 'averager1.timeresolution = 4.\n' )
        f.write( 'applybeam.type = applybeam\n')
        f.write( 'applybeam.direction = {:s}\n'.format(phasecenter) )
        f.write( 'applybeam.beammode = full\n' )
        f.write( 'averager2.type = averager\n' )                                       
        f.write( 'averager2.freqresolution = 390.56kHz\n' )
        f.write( 'averager2.timeresolution = 32.\n' )
        
        # Apply solutions and more average_target

        f.write( 'applycal.type = applycal\n')
        #f.write( 'applycal.parmdb = {:s}\n'.format(str(delay_solset)) )
        f.write( 'applycal.correction = fulljones\n')
        f.write( 'applycal.soltab = [amplitude000,phase000]\n')

        f.write( 'averager3.type = averager\n' )
        f.write( 'averager3.freqresolution = {:s}\n'.format(freqres) )
        f.write( 'averager3.timeresolution = {:s}\n'.format(timeres) )

        f.write( 'msout.storagemanager = dysco\n')
        f.write( 'msout.name ={:s}\n'.format(str(msout)) )
        f.write( 'msout.overwrite=True\n' )
        #f.write( 'numthreads ={:s}\n'.format(ncpu))
        f.close()

    

    # for testing
    #starttime = datetime.datetime.now()
    #os.system( 'DP3 ndppp_explode.parset msin={:s}'.format(msin) )
    #endtime = datetime.datetime.now()
    #timediff = endtime - starttime
    #print( 'total time (sec):%s'%str(timediff.total_seconds()) )

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Creates an NDPPP explode parset based on a catalogue file.')

    parser.add_argument('msin', type=str,
			help='Measurement set')
    parser.add_argument('cat_file', type=str,
                        help='Catalogue file to use.')
    parser.add_argument('delay_solset', type=str, 
                        help = 'Delay calibrator solutions')
    parser.add_argument('--ncpu', type=int, default = 4,
			help='Number of CPUs to use.')

    args = parser.parse_args()

    format_stream = logging.Formatter("%(asctime)s\033[1m %(levelname)s:\033[0m %(message)s","%Y-%m-%d %H:%M:%S")
    format_file   = logging.Formatter("%(asctime)s %(levelname)s: %(message)s","%Y-%m-%d %H:%M:%S")
    logging.root.setLevel(logging.INFO)

    log = logging.StreamHandler()
    log.setFormatter(format_stream)
    logging.root.addHandler(log)

    main( args.msin, args.cat_file, args.delay_solset, phaseup_cmd="{ST001:'CS*'}", filter_cmd="'!CS*&*'", freqres='390.56kHz', timeres=32., ncpu=args.ncpu)

