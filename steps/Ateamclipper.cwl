class: CommandLineTool
cwlVersion: v1.2
id: Ateamclipper
label: Ateamclipper

baseCommand:
  - Ateamclipper.py

inputs:
  - id: msin
    type:
      - Directory
      - type: array
        items: Directory
    inputBinding:
      position: 0
    doc: Input measurement set

outputs:
  - id: msout
    doc: Output MS
    type: Directory
    outputBinding:
      glob: $(inputs.msin.basename)
  - id: logfile
    type: File[]
    outputBinding:
      glob: Ateamclipper.log
  - id: output
    type: File
    outputBinding:
      glob: Ateamclipper.txt

hints:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: InplaceUpdateRequirement
    inplaceUpdate: true
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: InlineJavascriptRequirement
  - class: ResourceRequirement
    coresMin: 12

stdout: Ateamclipper.log
stderr: Ateamclipper_err.log
