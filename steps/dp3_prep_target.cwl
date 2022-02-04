class: CommandLineTool
cwlVersion: v1.2
id: dp3_prep_target
label: dp3_prep_target

baseCommand: DP3

inputs:
    - id: parset
      type: File
      inputBinding:
        position: -1
      doc: DP3 parset file.
    - id: msin
      type: Directory[]
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
      doc: input measurement set.
    - id: msout_name
      type: string?
      default: "prepped"
      inputBinding:
        position: 0
        prefix: msout=
        separate: false
    - id: solset
      type: File
      doc: input solutions file.
    #- id: error_tolerance
    #  type: boolean?
    #  default: false
    #- id: max_processes_per_node
    #  type: int?
    #  default: 6

outputs:
    - id: msout
      doc: Output measurement set.
      type: Directory
      outputBinding:
        glob: '$(inputs.msout)'
    - id: logfile
      type: File[]
      outputBinding:
        glob: 'DP3_prep_target*.log'

stdout: dp3_prep_target.log
stderr: dp3_prep_target_err.log

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
