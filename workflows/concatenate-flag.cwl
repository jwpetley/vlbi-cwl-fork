class: Workflow
cwlVersion: v1.2
id: sort-concat-flag
label: sort-concat-flag

inputs:
  - id: msin
    type: Directory[]
  - id: numbands
    type: int?
    default: 10
    doc: The number of files that have to be grouped together.
  - id: DP3fill
    type: boolean?
    default: True
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: stepname
    type: string?
    default: '.dp3-concat'
    doc: Add this stepname into the file names of the output files.
  - id: mergeLastGroup
    type: boolean?
    default: False
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: truncateLastSBs
    type: boolean?
    default: True
    doc: Add dummy file names for missing frequencies, so that DP3 can fill the data with flagged dummy data.
  - id: firstSB
    type: int?
    default: null
    doc: If set, reference the grouping of files to this station subband.

steps:
  - id: sort_concatenate
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
        source: sort_concatenate/groupnames
      - id: groups_specification
        source: sort_concatenate/filenames
    out:
      - id: msout
      - id: concat_flag_statistics
      - id: aoflag_logfile
      - id: concatenate_logfile
    run: ./subworkflows/concatenation.cwl
    scatter: group_id
    label: concatenation-flag
  - id: concat_flags_join
    in:
      - id: flagged_fraction_dict
        source:
          - concatenate-flag/concat_flag_statistics
      - id: filter_station
        default: ''
      - id: state
        default: concat
    out:
      - id: flagged_fraction_antenna
      - id: logfile
    run: ../steps/findRefAnt_join.cwl
    label: initial_flags_join
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
            - sort_concatenate/logfile
            - concatenate_logfiles_concatenate/output
            - concatenate_logfiles_aoflagging/output
            - concat_flags_join/logfile
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
    - id: concat_flags
      type: File
      outputSource: concat_flags_join/flagged_fraction_antenna

requirements:
    - class: SubworkflowFeatureRequirement
    - class: ScatterFeatureRequirement
    - class: MultipleInputFeatureRequirement
