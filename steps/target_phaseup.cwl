class: CommandLineTool
cwlVersion: v1.2
id: target_phaseup
label: target_phaseup

baseCommand: ndppp_explode.py

inputs:
    - id: msin
      type: Directory
      inputBinding:
        position: 1
        shellQuote: false
    - id: image_cat
      type: File
      inputBinding:
        position: 2
        shellQuote: false
    - id: number_cores
      type: int
      inputBinding:
        position: 3
        prefix: --ncpu


outputs:
  - id: parset
    doc: Output DP3 Parset
    type: File
    outputBinding:
      glob: ndppp_explode.parset
  - id: logfile
    type: File[]
    outputBinding:
      glob: target_phaseup*.log


stdout: target_phaseup.log
stderr: target_phaseup_err.log

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl:latest