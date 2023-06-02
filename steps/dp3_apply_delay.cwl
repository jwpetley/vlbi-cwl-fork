cwlVersion: v1.2
class: CommandLineTool
id: dp3_apply_delay
label: dp3_apply_delay

baseCommand: DP3

arguments:
    - steps=[applysols,count]
    - applysols.type=applycal
    - applysols.soltab=[amplitude000,phase000]
    - applysols.correction=fulljones
    - applysols.updateweights=false

inputs:
    - id: msin
      type: Directory
      doc: Input measurement set.
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
    - id: h5parm
      type: File
      doc: Delay calibrator solution set.
      inputBinding:
        position: 0
        prefix: applysols.parmdb=
        separate: false
    - id: solset
      type: string?
      default: sol000
      doc: solution set in the h5parm to be used.
      inputBinding:
        position: 0
        prefix: applysols.solset=
        separate: false
    - id: max_dp3_threads
      type: int?
      default: 5
      inputBinding:
        prefix: numthreads=
        separate: false
    - id: msin_datacolumn
      type: string?
      default: DATA
      inputBinding:
        prefix: msin.datacolumn=
        separate: false
        shellQuote: false
    - id: baseline
      type: string?
      default: '*&'
      inputBinding:
        prefix: msin.baseline=
        separate: false
    - id: msout_datacolumn
      type: string?
      default: CORRECTED_DATA
      inputBinding:
        prefix: msout.datacolumn=
        separate: false
    - id: storagemanager
      type: string?
      default: dysco
      inputBinding:
        prefix: msout.storagemanager=
        separate: false
    - id: fullresflags
      type: boolean?
      default: False
      inputBinding:
        prefix: msout.writefullresflag=
        separate: false
    - id: save2json
      default: true
      type: boolean?
      inputBinding:
        position: 0
        prefix: count.savetojson=True
    - id: jsonfilename
      type: string?
      default: 'out.json'
      inputBinding:
        prefix: count.jsonfilename=
        separate: false

outputs:
    - id: msout
      type: Directory
      outputBinding:
        glob: $(msin.basename)
    - id: logfile
      type: File[]
      outputBinding:
        glob: dp3_apply_delay*.log
    - id: flagged_fraction_dict
      type: File
      outputBinding:
          loadContents: true
          glob: $(inputs.jsonfilename)

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
  - class: ResourceRequirement
    coresMin: 6

stdout: dp3_apply_delay.log
stderr: dp3_apply_delay_err.log
