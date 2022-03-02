class: CommandLineTool
cwlVersion: v1.2
id: make_sourcedb
label: make_sourcedb_ateam

baseCommand:
  - makesourcedb

inputs:
  - id: sky_model
    type:
      - File?
      - string?
    default: '$PREFACTOR_DATA_ROOT/skymodels/Ateam_LBA_CC.skymodel'
    inputBinding:
      position: 0
      prefix: in=
      separate: false
      shellQuote: false
  - id: output_file_name
    type: string?
    default: Ateam.sourcedb
    inputBinding:
      position: 1
      prefix: out=
      separate: false
      valueFrom: $(inputs.output_file_name)
      shellQuote: false
  - id: outtype
    type: string?
    default: blob
    inputBinding:
      position: 2
      prefix: outtype=
      separate: false
      shellQuote: false
  - id: format
    type: string?
    default: '"<"'
    inputBinding:
      position: 3
      prefix: format=
      separate: false
      shellQuote: false
  - id: logname
    type: string?
    default: make_sourcedb.log

outputs:
  - id: sourcedb
    type:
      - Directory
      - File
    outputBinding:
      glob: $(inputs.output_file_name)
  - id: log
    type: File
    outputBinding:
      glob: $(inputs.logname)

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl:latest

stdout: $(inputs.logname)

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
