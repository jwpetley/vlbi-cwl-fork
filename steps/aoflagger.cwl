class: CommandLineTool
cwlVersion: v1.2
id: aoflagging
label: aoflagging

baseCommand: DP3

inputs:
    - id: msin
      type: Directory
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
        shellQuote: false
      doc: Input Measurement Set
    - id: msin_datacolumn
      type: string?
      default: DATA
      inputBinding:
        position: 0
        prefix: msin.datacolumn=
        separate: false
        shellQuote: true
      doc: Input data Column
    - id: memoryperc
      type: int?
      default: 15
      inputBinding:
        position: 0
        prefix: aoflagger.memoryperc=
        separate: false
        shellQuote: false
      doc: Indicates the percentage of pc memory to use
    - id: keepstatistics
      type: boolean?
      default:  true
      inputBinding:
        prefix: aoflagger.keepstatistics=True
      doc: Indicates whether statistics should be written to file.
    - id: strategy
      type:
        - File?
        - string?
      default: $PREFACTOR_DATA_ROOT/rfistrategies/lofar-default.lua
      inputBinding:
        position: 0
        prefix: aoflagger.strategy=
        separate: false
        shellQuote: false
      doc: specifies a customized strategy

arguments:
    - steps=[aoflagger]
    - aoflagger.type=aoflagger
    - msout=.

outputs:
  - id: msout
    doc: Output Measurement Set
    type: Directory
    outputBinding:
      glob: $(inputs.msin.basename)
  - id: logfile
    type: File[]
    outputBinding:
      glob: aoflag*.log

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: ShellCommandRequirement

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

stdout: aoflag.log
stderr: aoflag_err.log
