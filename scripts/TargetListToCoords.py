import os
import numpy as np
import pyrap.tables, math
from astropy import units as u
from astropy.coordinates import SkyCoord
from astropy.table import Table

def plugin_main(**kwargs):
    """
    Takes in a catalogue with a target and returns appropriate coordinates
    
    Parameters
    ----------
    filename: str
        Name of output mapfile
    target_file: str
        file containing target info

    Returns
    -------
    result : dict
        Output coordinates
    
    """
    # parse the input
    target_file = kwargs['target_file']
    
    # read in the catalogue to get source_id, RA, and DEC
    t = Table.read(target_file, format='csv')
    RA_val = t['RA_LOTSS'].data[0]
    DEC_val = t['DEC_LOTSS'].data[0]
    Source_id = t['Source_id'].data[0]
    if str(Source_id)[0:1] == 'I':
        pass
    elif str(Source_id)[0:1] == 'S':
        pass
    else:
        Source_id = 'S' + str(Source_id)
    # make a string of coordinates for the NDPPP command
    ss = '["' + str(RA_val) + 'deg","' + str(DEC_val) + 'deg"]'
    result = {'name' : Source_id, 'coords' : ss}
    return result
