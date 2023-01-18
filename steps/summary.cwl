class: CommandLineTool
cwlVersion: v1.2
id: summary
label: summary

baseCommand:
  - make_summary.py

inputs:
  - id: flagFiles
    type:
      - File[]
      - File
    inputBinding:
      position: 1
    doc: List of files with flag information (JSON)
  - id: pipeline
    type: string?
    default: 'VLBI'
    inputBinding:
      position: 0
      prefix: --pipeline
    doc: Name of the pipeline
  - id: run_type
    default: 'calibrator'
    type: string?
    inputBinding:
      position: 0
      prefix: --run_type
    doc: Type of the pipeline
  - id: filter
    default: '*&'
    type: string?
    inputBinding:
      position: 0
      prefix: --filtered_antennas
    doc: Filter these antenna string from the processing.
  - id: bad_antennas
    default: '*&'
    type: string?
    inputBinding:
      position: 0
      prefix: --bad_antennas
    doc: Antenna string to be processed
  - id: structure_file
    default: false
    type: 
      - boolean?
      - File?
    inputBinding:
      position: 0
      prefix: --structure_file
  - id: Ateam_separation_file
    default: false
    type: 
      - boolean?
      - File?
    inputBinding:
      position: 0
      prefix: --Ateam_separation_file
  - id: solutions
    default: false
    type: 
      - boolean?
      - File?
    inputBinding:
      position: 0
      prefix: --solutions
  - id: clip_sources
    default: false
    type: 
      - string?
      - boolean?
    inputBinding:
      position: 0
      prefix: --clip_sources
      separate: true
      itemSeparator: ','
      valueFrom: '$(self)'
  - id: demix_sources
    default: false
    type:
      - string?
      - boolean?
    inputBinding:
      position: 0
      prefix: --demix_sources
      separate: true
      itemSeparator: ','
      valueFrom: '$(self)'
  - id: removed_bands
    default: false
    type:
      - string?
      - boolean?
    inputBinding:
      position: 0
      prefix: --removed_bands
      separate: true
      itemSeparator: ','
      valueFrom: '$(self)'
  - id: min_unflagged_fraction
    default: 0.5
    type: float?
    inputBinding:
      position: 0
      prefix: --min_unflagged
    doc: minimum fraction of unflagged data per band to continue
  - id: demix
    default: "False"
    type: string?
    inputBinding:
      position: 0
      prefix: --demix
      shellQuote: false
      separate: true
  - id: refant
    default: ''
    type: string?
    inputBinding:
      position: 0
      prefix: --refant
    doc: Reference antenna used
  - id: output_fname
    type: 
      - boolean?
      - string?
    default: false
    inputBinding:
      position: 0
      prefix: --output_fname
    doc: Name of the output file

outputs:
  - id: summary_file
    doc: Summary File in JSON format
    type: File
    outputBinding:
      glob: '*.json'
  - id: logfile
    type: File[]
    outputBinding:
      glob: 'summary*.log'

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl:latest

stdout: summary.log
stderr: summary_err.log
