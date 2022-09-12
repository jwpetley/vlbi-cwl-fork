class: CommandLineTool
cwlVersion: v1.2
id: dp3_phaseup
label: dp3_phaseup

baseCommand: DP3

arguments:
    - 'steps=[shift, average1, applybeam, average2]'
    - shift.type=phaseshift
    - average1.type=averager
    - applybeam.type=applybeam
    - average2.type=averager
    - numthreads=5
    - msout.overwrite=True
    - applybeam.beammode=full
    - average2.freqresolution=390.56kHz
    - average2.timeresolution=32.0

inputs:
    - id: msin
      type: Directory
      doc: Input measurement set.
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
        shellQuote: false
    - id: msout_name
      type: string?
      default: "dp3-phaseup-"
      inputBinding:
        position: 0
        prefix: msout=
        separate: false
        valueFrom: |
          $(self + inputs.msin.basename)
    - id: storagemanager
      type: string?
      doc:
      default: 'dysco'
      inputBinding:
        position: 1
        prefix: msout.storagemanager=
        separate: false
        shellQuote: false
    - id: datacolumn_in
      type: string?
      default: 'DATA'
      doc: Data column input measurement set.
      inputBinding:
        position: 1
        prefix: msin.datacolumn=
        separate: false
        shellQuote: false
    - id: datacolumn_out
      type: string?
      default: 'DATA'
      doc: Data column output measurement set.
      inputBinding:
        position: 1
        prefix: msout.datacolumn=
        separate: false
        shellQuote: false
    - id: phase_center
      type: string
      doc: 'source RA and DEC.'
      inputBinding:
        position: 1
        prefix: shift.phasecenter=
    - id: freqresolution
      type: string?
      default: '48.82kHz'
      inputBinding:
        position: 1
        prefix: average1.freqresolution=
    - id: timeresolution
      type: float?
      default: 4.0
      inputBinding:
        position: 1
        prefix: average1.timeresolution=
    - id: beam_direction
      type: string
      doc: 'source RA and DEC.'
      inputBinding:
        position: 1
        prefix: applybeam.direction=

outputs:
    - id: msout
      type: Directory
      outputBinding:
        glob: $("dp3-phaseup-" + inputs.msin.basename)
    - id: logfile
      type: File
      outputBinding:
        glob: 'dp3_phaseup.log'
    - id: errorfile
      type: File
      outputBinding:
        glob: 'dp3_phaseup_err.log'

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl

requirements:
  - class: InlineJavascriptRequirement

stdout: dp3_phaseup.log
stderr: dp3_phaseup_err.log
