class: Workflow
cwlVersion: v1.2
id: sort-concat-flag
label: sort-concat-flag

inputs:
  - id: msin
    type: Directory[]

steps:
  - id: sort_concatmap
    in:
      - id: msin
        source: msin
    out:
      - id: filenames
      - id: groupnames
      - id: logfile
    run: ../steps/sort_concatmap.cwl
    label: sort_concatmap
  - id: concatenate-flag
    in:
      - id: msin
        source:
          - msin
      - id: group_id
        source: sort_concatmap/groupnames
      - id: groups_specification
        source: sort_concatmap/filenames
    out:
      - id: msout
      - id: aoflag_logfile
      - id: concatenate_logfile
    run: ./subworkflows/concatenation.cwl
    scatter: group_id
    label: concatenation-flag
  - id: concatenate_logfiles_concatenate
    in:
      - id: file_list
        source:
          - concatenate-flag/concatenate_logfile
      - id: file_prefix
        default: concatenate
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
    label: concatenate_logfiles_concatenate
  - id: concatenate_logfiles_aoflagging
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: concatenate-flag/aoflag_logfile
      - id: file_prefix
        default: AOflagging
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
    label: concat_logfiles_AOflagging
  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
            - sort_concatmap/logfile
            - concatenate_logfiles_concatenate/output
            - concatenate_logfiles_aoflagging/output
      - id: sub_directory_name
        default: 'sort-concat-flag'
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
    - id: logdir
      outputSource: save_logfiles/dir
      type: Directory
    - id: msout
      outputSource: concatenate-flag/msout
      type: Directory[]

requirements:
    - class: SubworkflowFeatureRequirement
    - class: ScatterFeatureRequirement
    - class: MultipleInputFeatureRequirement
