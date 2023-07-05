class: CommandLineTool
cwlVersion: v1.2
id: dp3_target_phaseup
label: dp3_target_phaseup

baseCommand: DP3

inputs:
    - id: parset
      type: File[] 
      doc: Input parset file.
      default: ndppp_explode.parset 
      inputBinding:
        position: 0
    - id: msin
      type: Directory
      doc: Input measurement set.
      inputBinding:
        position: 1
        prefix: msin=
        separate: false
        shellQuote: false
    - id: delay_solset
      type: File
      doc: Input delay solution set.
      inputBinding:
        position: 2
        prefix: applycal.parmdb=
        separate: false
        shellQuote: false
    - id: max_dp3_threads
      type: int?
      default: 8
      doc: Maximum number of threads to use for DP3.
      inputBinding:
        position: 3
        prefix: numthreads=
        separate: false
        shellQuote: false

outputs:
    - id: msout
      type: Directory[]
      outputBinding:
        glob: "*.mstargetphaseup"
    - id: logfile
      type: File
      outputBinding:
        glob: dp3_target_phaseup.log
    - id: errorfile
      type: File
      outputBinding:
        glob: dp3_target_phaseup_err.log



hints:
  - class: DockerRequirement
    dockerPull: vlbi-cwl
  - class: ResourceRequirement
    coresMax: $(inputs.max_dp3_threads)
    coresMin: 2
  

stdout: dp3_target_phaseup.log
stderr: dp3_target_phaseup_err.log