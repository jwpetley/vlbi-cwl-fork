class: CommandLineTool
cwlVersion: v1.2
id: delay_cal_model
label: delay_cal_model

baseCommand: skynet.py

inputs:
    - id: msin
      type: Directory
      doc: Input measurement set.
      inputBinding:
        position: 0
    - id: delay_calibrator
      type: File
      doc: Coordinates of best delay calibrator.
      inputBinding:
        position: 1
        prefix: --delay-cal-file
        separate: true

outputs:
    - id: msout
      type: Directory
      outputBinding:
        glob: $(inputs.msin.basename)
    - id: logfile
      type: File[]
      outputBinding:
        glob: delay_cal_model*.log

hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl

requirements:
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.msin)
        writable: true
  - class: InplaceUpdateRequirement
    inplaceUpdate: true

stdout: delay_cal_model.log
stderr: delay_cal_model_err.log
