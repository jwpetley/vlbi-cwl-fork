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
    outputSource: dp3_concat/msout
    type: Directory
  - id: logfile
    outputSource: dp3_concatenate_logfiles/output
    type: File
