class: CommandLineTool
cwlVersion: v1.2
id: download_cats
label: download_cats

baseCommand: 
    - downloadCats.py

inputs:
    - id: msin
      type: Directory[]
      inputBinding:
        position: 0
    - id: lotss_radius
      type: float?
      default: 1.5
    - id: lbcs_radius
      type: float?
      default: 1.5
    - id: im_radius
      type: float?
      default: 1.24
    - id: bright_limit_Jy
      type: float
      default: 5.0
    - id: match_tolerance
      type: float?
      default: 5.0
    - id: image_limit_Jy
      type: float?
      default: 0.01
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
      default: "delay_calibrators.csv"
    - id: subtract_catalogue_name
      type: string?
      default: "subtract_sources.csv"

requirements:
    - class: NetworkAccess
      networkAccess: true

outputs:
    - id: delay_catalogue
      type: File
      outputBinding:
        glob: $(inputs.delay_catalogue_name)
    - id: logfile
      type: File[]
      outputBinding:
        glob: downloadCats*.log

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

stdout: downloadCats.log
stderr: downloadCats_err.log
