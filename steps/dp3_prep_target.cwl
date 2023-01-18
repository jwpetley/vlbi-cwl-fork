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
      type: Directory
      inputBinding:
        position: 0
        prefix: msin=
        separate: false
      doc: Input measurement set.
    - id: msout_name
      type: string?
      default: "."
      inputBinding:
        position: 0
        prefix: msout=
        separate: false
    - id: solset
      type: File
      doc: Input solutions file.
    - id: collect_flag_statistics_before
      default: true
      type: boolean?
      inputBinding:
        position: 0
        prefix: count1.savetojson=True
    - id: flag_statistics_filename_before
      type: string?
      default: 'out1.json'
      inputBinding:
        prefix: count1.jsonfilename=
        separate: false
    - id: collect_flag_statistics_after
      default: true
      type: boolean?
      inputBinding:
        position: 0
        prefix: count2.savetojson=True
    - id: flag_statistics_filename_after
      type: string?
      default: 'out2.json'
      inputBinding:
        prefix: count2.jsonfilename=
        separate: false
    #- id: error_tolerance
    #  type: boolean?
    #  doc: Indicates whether the pipeline should stop if one subband fails.
    #  default: false
    #- id: max_processes_per_node
    #  type: int?
    #  default: 6
    #  doc: Number of processes per step per node.

arguments:
    - applyPA.parmdb=$(inputs.solset.path)
    - applybandpass.parmdb=$(inputs.solset.path)
    - applyclock.parmdb=$(inputs.solset.path)
    - applyRM.parmdb=$(inputs.solset.path)
    - applyphase.parmdb=$(inputs.solset.path)

requirements:
  - class: InlineJavascriptRequirement
#  - class: InitialWorkDirRequirement
#    listing:
#      - entry: $(inputs.msin)
#        writable: true
#      - entry: $(inputs.solset)
#        writable: true

outputs:
    - id: logfile
      type: File[]
      outputBinding:
        glob: 'dp3_prep_target*.log'
    - id: msout
      doc: Output Measurement Set.
      type: Directory
      outputBinding:
        glob: '$(inputs.msout_name=="." ? inputs.msin.basename : inputs.msout_name)'
    - id: flag_statistics_before
      type: string
      outputBinding:
        glob: $(inputs.flag_statistics_filename_before)
        outputEval: $(JSON.parse(self[0].contents).flagged_fraction_dict)
    - id: flag_statistics_after
      type: string
      outputBinding:
        glob: $(inputs.flag_statistics_filename_after)
        outputEval: $(JSON.parse(self[0].contents).flagged_fraction_dict)

hints:
  DockerRequirement:
    dockerPull: vlbi-cwl:latest

stdout: dp3_prep_target.log
stderr: dp3_prep_target_err.log
