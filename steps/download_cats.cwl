class: CommandLineTool
cwlVersion: v1.2
id: download_cats
label: download_cats

baseCommand: 
    - scripts/DownloadCats.py

inputs:
    - id: mapfile_in
      type: Directory
    - id: lotts_radius
      type: float?
      default: 2.0
    - id: lbcs_radius
      type: float?
      default: 2.0
    - id: bright_limit_Jy
      type: float
      default: 5.0
    - id: match_tolerance
      type: float?
      default: 5.0
    - id: subtract_limit
      type: float?
      default: 0.5
    - id: image_limit_Jy
      type: float?
      default: 0.05
    - id: continue_no_lotss
      type: boolean?
      default: true

    mapfile_in = kwargs['mapfile_in']
    lotss_radius = kwargs['lotss_radius']
    lbcs_radius  = kwargs['lbcs_radius']
    bright_limit_Jy = float(kwargs['bright_limit_Jy'])
    lotss_result_file = kwargs['lotss_result_file']
    delay_cals_file = kwargs['delay_cals_file']
    subtract_file = kwargs['subtract_file']
    match_tolerance = float(kwargs['match_tolerance'])
    subtract_limit = float(kwargs['subtract_limit'])
    image_limit_Jy = float(kwargs['image_limit_Jy'])
    fail_lotss_ok = kwargs['continue_no_lotss'].lower().capitalize()


outputs:
    - id: lotss_skymodel
    - id: lbcs_skymodel
    - id: image_cat
    - id: delay_cat
    - id: subtract_cat

    lotss_catalogue = kwargs['lotss_catalogue']
    lbcs_catalogue = kwargs['lbcs_catalogue']

#requirements:
hints:
  DockerRequirement:
    dockerPull: vlbi-cwl
