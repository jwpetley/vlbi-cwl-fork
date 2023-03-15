class: CommandLineTool
cwlVersion: v1.2
id: dp3concat

baseCommand:
  - DP3

inputs:
  - id: msin
    type: Directory[]
    doc: Input measurement sets
  - id: msin_filenames
    doc: Input measurement set string (including dummy.ms)
    type: string[]
    inputBinding:
      position: 0
      prefix: msin=
      separate: false
      itemSeparator: ','
      valueFrom: "[$(self.join(','))]"
  - id: msout_name
    type: string
    inputBinding:
      position: 0
      prefix: msout=
      separate: false
      shellQuote: false
  - id: storagemanager
    type: string?
    default: 'dysco'
    inputBinding:
      prefix: msout.storagemanager=
      separate: false
      shellQuote: false
      position: 0
  - id: datacolumn_in
    type: string?
    default: 'DATA'
    inputBinding:
      prefix: msin.datacolumn=
      separate: false
      shellQuote: false
      position: 0
  - id: datacolumn_out
    type: string?
    default: 'DATA'
    inputBinding:
      prefix: msout.datacolumn=
      separate: false
      shellQuote: false
      position: 0

outputs:
  - id: msout
    doc: Output Measurement Set
    type: Directory
    outputBinding:
      glob: $(inputs.msout_name)
  - id: flagged_statistics
    type: string
    outputBinding:
        loadContents: true
        glob: out.json
        outputEval: $(JSON.parse(self[0].contents).flagged_fraction_dict)
  - id: logfile
    type: 'File[]'
    outputBinding:
      glob: dp3_concat*.log

arguments:
  - 'steps=[count]'
  - msin.orderms=False
  - msin.missingdata=True
  - msout.overwrite=True
  - msout.writefullresflag=True
  - count.savetojson=True
  - count.jsonfilename=out.json

requirements:
  - class: ShellCommandRequirement
  - class: InlineJavascriptRequirement
#    expressionLib:
#      - { $include: 'utils.js' }

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl:latest
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: ResourceRequirement
    coresMin: 6

stdout: dp3_concat.log
stderr: dp3_concat_err.log
