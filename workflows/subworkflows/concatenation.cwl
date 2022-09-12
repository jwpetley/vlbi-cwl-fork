class: Workflow
cwlVersion: v1.2
id: concatenation
label: concatenation

inputs:
  - id: msin
    type: Directory[]
  - id: group_id
    type: string
  - id: groups_specification
    type: File
  - id: do_flagging
    type: boolean?
    default: true

steps:
  - id: filter_ms_group
    in:
      - id: group_id
        source: group_id
      - id: groups_specification
        source: groups_specification
      - id: measurement_sets
        source: msin
    out:
      - id: selected_ms
    run: ../../steps/filter_ms_group.cwl
    label: filter_ms_group
  - id: dp3_concat
    in:
      - id: msin
        source: msin
      - id: msin_filenames
        source: filter_ms_group/selected_ms
      - id: msout_name
        source: group_id
    out:
      - id: msout
      - id: logfile
    run: ../../steps/dp3_concat.cwl
    label: dp3_concat
  - id: AOflagging
    in:
      - id: msin
        source: dp3_concat/msout
      - id: do_flagging
        source: do_flagging
    out:
      - id: msout
      - id: logfile
    when: $(inputs.do_flagging)
    run: ../../steps/aoflagger.cwl
    label: AOflagging
  - id: concat_logfiles_aoflagging
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: AOflagging/logfile
      - id: file_prefix
        default: AOflagging
      - id: do_flagging
        source: do_flagging
    out:
      - id: output
    when: $(inputs.do_flagging)
    run: ../../steps/concatenate_files.cwl
    label: concat_logfiles_AOflagging
  - id: dp3_concatenate_logfiles
    in:
      - id: file_list
        source:
            - dp3_concat/logfile
      - id: file_prefix
        default: dp3_concatenation
    out:
      - id: output
    run: ../../steps/concatenate_files.cwl
    label: dp3_concatenate_logfiles

outputs:
  - id: msout
    outputSource:
        - AOflagging/msout
        - dp3_concat/msout
    pickValue: first_non_null
    type: Directory
  - id: concatenate_logfile
    outputSource: dp3_concatenate_logfiles/output
    type: File
  - id: aoflag_logfile
    outputSource:
        - concat_logfiles_aoflagging/output
    pickValue: all_non_null
    type: File
