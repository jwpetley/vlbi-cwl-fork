class: Workflow
cwlVersion: v1.2
id: clipAteam
label: clipAteam

inputs:
  - id: msin
    type: 'Directory[]'
    doc: Input Measurement Set
 
steps:
  - id: predictAteam
    in:
      - id: msin
        linkMerge: merge_flattened
        source: 
          - msin
    out:
      - id: msout
      - id: predict_logfile
      - id: cliptar_logfile
    run: ./subworkflows/predictAteam.cwl
    scatter: msin
    label: predictAteam
  - id: concat_logfiles_predict
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: predictAteam/predict_logfile
      - id: file_prefix
        default: predict
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
    label: concat_logfiles_predict
  - id: concat_logfiles_cliptar
    in:
      - id: file_list
        linkMerge: merge_flattened
        source: predictAteam/cliptar_logfile
      - id: file_prefix
        default: Ateamcliptar
    out:
      - id: output
    run: ../steps/concatenate_files.cwl
    label: concat_logfiles_cliptar
  - id: save_logfiles
    in:
      - id: files
        linkMerge: merge_flattened
        source:
          - concat_logfiles_predict/output
          - concat_logfiles_cliptar/output
      - id: sub_directory_name
        default: clipAteam
    out:
      - id: dir
    run: ../steps/collectfiles.cwl
    label: save_logfiles

outputs:
  - id: logdir
    outputSource: save_logfiles/dir
    type: Directory
  - id: msout
    outputSource: predictAteam/msout
    type: Directory[]

requirements:
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
