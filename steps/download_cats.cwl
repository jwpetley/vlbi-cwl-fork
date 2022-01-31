class: CommandLineTool
cwlVersion: v1.2
id: download_cats
label: download_cats

baseCommand: 
    - downloadCats.py

inputs:
    - id: msin # mapfile_in = kwargs['mapfile_in']
      type: Directory[]
      inputBinding:
        position: 0
    - id: lotss_radius
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
    - id: lotss_catalogue
      type:
        - File?
        - string?
      default: "lotss_catalogue.csv"
    - id: lbcs_catalogue
      type:
        - File?
        - string?
      default: "lbcs_catalogue.csv"
    - id: image_catalogue_name
      type: string? 
      default: "image_catalogue.csv"
    - id: delay_catalogue_name
      type: string?
      default: "delay_catalogue.csv"
    - id: subtract_catalogue_name
      type: string?
      default: "subtract_sources.csv"

requirements:
    - class: NetworkAccess
      networkAccess: true

outputs:
    #- id: lotss_skymodel
    #  type: File
    #  outputBinding:
    #    glob: $(inputs.lotss_skymodel_name)
    #- id: lbcs_skymodel
    #  type: File
    #  outputBinding:
    #    glob: $(inputs.lbcs_skymodel_name)
    - id: best_delay_catalogue
      type: File
      outputBinding:
        glob: best_delay_*.csv
    - id: image_catalogue
      type: File
      outputBinding:
        glob: $(inputs.image_catalogue_name)
    #- id: delay_catalogue
    #  type: File
    #  outputBinding:
    #    glob: $(inputs.delay_catalogue_name)
    #- id: subtract_catalogue
    #  type: File
    #  outputBinding:
    #    glob: $(inputs.subtract_catalogue_name)
    #- id: lotss_result_file
    #  type: File
    - id: logfile
      type: File[]
      outputBinding:
        glob: 'downloadCats*.log'


hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

stdout: downloadCats.log
stderr: downloadCats_err.log
